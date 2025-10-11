import Foundation
import Speech

class SpeechRecognizer: ObservableObject {
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    //@Published var transcript: String = ""
    @Published var partialResult: String = ""
    @Published var finalResult: String = ""

    func startTranscription() {
            self.finalResult = ""
            self.partialResult = ""
            //self.errorMessage = nil
            SFSpeechRecognizer.requestAuthorization { authStatus in
                DispatchQueue.main.async {
                    switch authStatus {
                    case .authorized:
                        self.startRecognitionSession()
                    case .denied, .restricted, .notDetermined:
                        print("❌ Autorisation de reconnaissance vocale refusée")
                    @unknown default:
                        print("❌ État d'autorisation inconnu")
                    }
                }
            }
        }
    
    private func startRecognitionSession() {
        if audioEngine.isRunning {
            stopTranscription()
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        guard let request = recognitionRequest else {
            print("❌ Impossible de créer la requête de reconnaissance")
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                self.partialResult = result.bestTranscription.formattedString
                if result.isFinal {
                self.finalResult = result.bestTranscription.formattedString
                }
            }

            if let error = error {
                print("❌ Erreur reconnaissance : \(error.localizedDescription)")
                self.stopTranscription()
            }
        }

        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("❌ Échec démarrage moteur audio : \(error.localizedDescription)")
        }
    }

    

    func stopTranscription() {
            self.finalResult = ""
            self.partialResult = ""
            //self.errorMessage = nil
            
            if audioEngine.isRunning {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
                recognitionRequest?.endAudio() // important : signaler la fin
            }
     
            // Ne pas annuler ici : laisser le système finir
            // recognitionTask?.cancel() ← ne pas faire
     
            // Délai pour laisser le temps à result.isFinal d'arriver
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.recognitionTask?.cancel()
                self.recognitionTask = nil
                self.recognitionRequest = nil
            }
        }
    
    

    private func resetRecognition() {
        recognitionRequest = nil
        recognitionTask = nil
    }

}
