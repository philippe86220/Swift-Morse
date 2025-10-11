import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var currentCharIndex: Int? = nil
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isListening = false

    // Vitesse (durée du point)
    @State private var unit: Double = 0.07

    // Observe le player pour le voyant
    @ObservedObject private var morse = MorsePlayer.shared

    var body: some View {
        VStack(spacing: 16) {
            // --- Section vitesse + voyant lumineux ---
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(morse.isBlinking ? Color.green : Color.gray.opacity(0.4))
                        .frame(width: 20, height: 20)
                        .shadow(color: morse.isBlinking ? Color.green.opacity(0.8) : .clear,
                                radius: morse.isBlinking ? 10 : 0)
                        .scaleEffect(morse.isBlinking ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: unit * 0.3), value: morse.isBlinking)

                    Spacer()

                    Text("Vitesse Morse :")
                        .font(.headline)
                    
                    Text(String(format: "%.0f WPM", wpm(from: unit)))
                        .font(.headline)
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }

                Slider(
                    value: Binding(
                        get: { (0.09 - unit) / (0.09 - 0.06) },
                        set: { newVal in
                            let mapped = 0.09 - newVal * (0.09 - 0.06)
                            unit = mapped
                            MorsePlayer.shared.setUnit(mapped)
                        }
                    ),
                    in: 0...1
                ) {
                    Text("Vitesse")
                } minimumValueLabel: {
                    Text("Lent")
                } maximumValueLabel: {
                    Text("Rapide")
                }

                HStack(spacing: 12) {
                    Button("Lent") { unit = 0.09; MorsePlayer.shared.setUnit(unit) }
                    Button("Normal") { unit = 0.07; MorsePlayer.shared.setUnit(unit) }
                    Button("Rapide") { unit = 0.06; MorsePlayer.shared.setUnit(unit) }
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.top, 24)

            // --- Champ de texte + boutons mic / nettoyage ---
            Text("Écrire un mot à jouer en Morse")
                .font(.headline)

            HStack {
                TextField("Tapez ici...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: userInput) { _, newValue in
                        let cleaned = newValue
                            .folding(options: .diacriticInsensitive, locale: .current)
                            .uppercased()
                        if cleaned != userInput {
                            userInput = cleaned
                        }
                    }
                    .onReceive(speechRecognizer.$partialResult) { partial in
                        if isListening && !partial.isEmpty {
                            userInput = partial
                                .folding(options: .diacriticInsensitive, locale: .current)
                                .uppercased()
                        }
                    }

                Button(action: {
                    if isListening {
                        speechRecognizer.stopTranscription()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            userInput = speechRecognizer.finalResult
                            isListening = false
                        }
                    } else {
                        userInput = ""
                        speechRecognizer.startTranscription()
                    }
                    isListening.toggle()
                }) {
                    Image(systemName: isListening ? "mic.fill" : "mic")
                        .font(.title)
                        .foregroundColor(isListening ? .red : .blue)
                }
                .disabled(userInput.count > 100)

                Button(action: {
                    userInput = ""
                    currentCharIndex = nil
                    speechRecognizer.partialResult = ""
                    speechRecognizer.finalResult = ""
                }) {
                    Image(systemName: "trash")
                        .font(.title)
                }
                .disabled(isListening)
            }
            .padding(.horizontal)

            // --- Affichage du texte (scroll horizontal) ---
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 0) {
                        ForEach(Array(userInput.enumerated()), id: \.offset) { index, char in
                            Text(String(char))
                                .font(.title2)
                                .foregroundColor(Color.blue)
                                .padding(4)
                                .background(index == currentCharIndex ? Color.yellow : Color.clear)
                                .cornerRadius(4)
                                .id(index)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 40)
                .onChange(of: currentCharIndex) { _, newIndex in
                    if let idx = newIndex {
                        withAnimation {
                            proxy.scrollTo(idx, anchor: .center)
                        }
                    }
                }
            }

            Button("Lire le texte en Morse") {
                playTextInMorse(userInput.uppercased())
            }
            .padding()

            Spacer()

            // --- Grille des caractères Morse en bas ---
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4)) {
                    ForEach(MorseCode.orderedMappings, id: \.char) { char, display, raw in
                        VStack {
                            Text(String(char))
                                .font(.largeTitle)
                            Text(display)
                                .font(.system(size: 24, weight: .medium, design: .monospaced))
                            Button(action: {
                                MorsePlayer.shared.play(morse: raw)
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title)
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding()
        }
    }

    func playTextInMorse(_ text: String) {
        DispatchQueue.global().async {
            let u = MorsePlayer.shared.unit  // utiliser la vitesse dynamique

            for (index, char) in text.enumerated() {
                DispatchQueue.main.async {
                    self.currentCharIndex = index
                }

                if char == " " {
                    Thread.sleep(forTimeInterval: 7 * u)
                    continue
                }

                if let morseSeq = MorseCode.orderedMappings.first(where: { $0.char == char })?.raw {
                    MorsePlayer.shared.play(morse: morseSeq)

                    let elements = morseSeq.compactMap { $0 == "·" ? 1 : ($0 == "–" ? 3 : nil) }
                    let soundUnits = elements.reduce(0, +)
                    let intraUnits = max(0, elements.count - 1) * 1
                    let charSeconds = Double(soundUnits + intraUnits) * u

                    Thread.sleep(forTimeInterval: charSeconds + 3 * u)
                } else {
                    Thread.sleep(forTimeInterval: 3 * u)
                }
            }

            DispatchQueue.main.async {
                self.currentCharIndex = nil
                if !text.isEmpty {
                    self.currentCharIndex = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.currentCharIndex = nil
                    }
                }
            }
        }
    }

    private func wpm(from unit: Double) -> Double {
        (1.2 / unit).rounded()
    }
}
