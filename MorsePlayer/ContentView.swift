import SwiftUI
import AVFoundation


struct ContentView: View {
    @State private var userInput: String = ""
    @State private var currentCharIndex: Int? = nil
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isListening = false

    // Vitesse (duree du point)
    @State private var unit: Double = 0.07

    // Observe le player pour le voyant
    @ObservedObject private var morse = MorsePlayer.shared

    var body: some View {
       
       
            VStack(spacing: 10) { // spacing gére uniquement l'espace entre les éléments à l'intérieur du VStack
// VStack aligne verticalement tandis que HStack aligne horizontalement les composants dans l’interface utilisateur.
// Ces deux types de stacks permettent en plus de gérer l’alignement et l’espacement entre les
// éléments.
                // --- Vitesse + LED ---
                VStack(alignment: .leading, spacing: 8) {
                    HStack {

                        // Voyant synchronise
                        HStack(spacing: 15) {
                            Circle()
                                .fill(morse.isBlinking ? Color.green : Color.gray.opacity(0.4))
                                .frame(width: 20, height: 20)
                                .shadow(color: morse.isBlinking ? Color.green.opacity(0.7) : .clear,
                                        radius: morse.isBlinking ? 8 : 0)
                                .animation(.easeOut(duration: 0.08), value: morse.isBlinking)
                                .padding(.leading,24)
                            Spacer() // pousse les deux éléments text ci-dessous vers la droite
                            
                            Text("Vitesse Morse : ")
                                .font(.headline)

                            Text(String(format: "%.0f WPM", wpm(from: unit)))
                                .font(.headline)
                                .monospacedDigit()
                                .foregroundColor(.secondary)
                        }
                    }

                    // Slider inversé: gauche lent (0.09), droite rapide (0.06)
                    Slider(
                        value: Binding(
                            get: { (0.09 - unit) / (0.09 - 0.06) },
                            set: { newValue in
                                let mapped = 0.09 - newValue * (0.09 - 0.06)
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
                        Button("Lent")   { unit = 0.09; MorsePlayer.shared.setUnit(unit) }
                        Button("Normal") { unit = 0.07; MorsePlayer.shared.setUnit(unit) }
                        Button("Rapide") { unit = 0.06; MorsePlayer.shared.setUnit(unit) }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal) // rend la pile uniformément centrée et non collée aux bords latéraux
                .padding(.top,24) // détermine précisément la distance au bord du haut de la vue,

                // ... le reste de ta vue (champ texte, boutons, grille, etc.)

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
                .padding()

                // Et juste en dessous :
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
                                        if let index = newIndex {
                                            withAnimation {
                                                proxy.scrollTo(index, anchor: .center)
                                            }
                                        }
                                    }
                                }
                                
            Button("Lire le texte en Morse") {
                    playTextInMorse(userInput.uppercased())
                    }
                
                .padding()
            }
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
    
    func playTextInMorse(_ text: String) {
        DispatchQueue.global().async {
            for (index, char) in text.enumerated() {
                DispatchQueue.main.async {
                    self.currentCharIndex = index
                }
                
                if let morse = MorseCode.orderedMappings.first(where: { $0.char == char })?.raw {
                    MorsePlayer.shared.play(morse: morse)
                    
                    let unit = 0.05
                    let totalUnits = morse.reduce(0) { count, symbol in
                        switch symbol {
                        case "·": return count + 1
                        case "–": return count + 3
                        default: return count
                        }
                    }
                    let soundDuration = unit * Double(totalUnits)
                    let spacingDuration = unit * Double(morse.count - 1)
                    let totalDuration = soundDuration + spacingDuration
                    
                    Thread.sleep(forTimeInterval: totalDuration + 0.7)
                } else {
                    Thread.sleep(forTimeInterval: 0.3)
                }
            }
            
            DispatchQueue.main.async {
                self.currentCharIndex = nil// 🔁 Retour automatique au début
                if  !text.isEmpty {
                    self.currentCharIndex = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.currentCharIndex = nil
                    }
                }
            }
        }
    }
}
private func wpm(from unit: Double) -> Double {
    // 1 mot = 50 unités, 60 secondes par minute
    // donc WPM ≈ 60 / (50 × unit) = 1.2 / unit
    (1.2 / unit).rounded()
}
