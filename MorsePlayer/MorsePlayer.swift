import Foundation
import AVFoundation
import Combine

final class MorsePlayer: ObservableObject {
    static let shared = MorsePlayer()

    // Unité de temps (dot). Reglable.
    private var _unit: TimeInterval = 0.07
    private let unitQueue = DispatchQueue(label: "morse.unit.queue")

    var unit: TimeInterval { unitQueue.sync { _unit } }
    func setUnit(_ newValue: TimeInterval) {
        let clamped = max(0.04, min(0.12, newValue))
        unitQueue.sync { _unit = clamped }
    }

    private let sampleRate: Double = 44100.0
    private let frequency: Double = 700.0

    private let queue = DispatchQueue(label: "morse.audio.queue")
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private lazy var format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                            sampleRate: sampleRate,
                                            channels: 1,
                                            interleaved: true)!

    // Voyant visuel
    @Published private(set) var isBlinking: Bool = false

    private init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        do { try engine.start() } catch { print("Audio start error:", error) }
        player.play()
    }

    // Joue la sequence Morse pour UN caractere (ex: ".-")
    func play(morse: String) {
        let u = unit
        queue.async {
            var timeline: [(tone: Bool, dur: TimeInterval)] = []
            for (i, symbol) in morse.enumerated() {
                switch symbol {
                case "·": timeline.append((true, 1 * u))
                case "–": timeline.append((true, 3 * u))
                default:  break
                }
                if i < morse.count - 1 {
                    timeline.append((false, 1 * u)) // gap intra-caractere
                }
            }
            self.schedule(timeline: timeline)
        }
    }

    private func schedule(timeline: [(tone: Bool, dur: TimeInterval)]) {
        guard !timeline.isEmpty else { return }

        // Point de depart audio
        let startTime: AVAudioTime
        if let last = player.lastRenderTime,
           let playerTime = player.playerTime(forNodeTime: last) {
            startTime = AVAudioTime(sampleTime: playerTime.sampleTime, atRate: sampleRate)
        } else {
            startTime = AVAudioTime(hostTime: mach_absolute_time())
        }

        var cursorSamples: AVAudioFramePosition = 0
        var cursorSecs: TimeInterval = 0

        for block in timeline {
            let frames = AVAudioFrameCount(block.dur * sampleRate)
            let when = AVAudioTime(sampleTime: startTime.sampleTime + cursorSamples, atRate: sampleRate)

            // Audio: tone ou silence
            let buffer = block.tone ? makeToneBuffer(frames: frames) : makeSilenceBuffer(frames: frames)
            player.scheduleBuffer(buffer, at: when, options: [])

            // Visuel: allumer au debut du tone, eteindre a la fin
            if block.tone {
                let onDelay = cursorSecs
                let offDelay = cursorSecs + block.dur
                DispatchQueue.main.asyncAfter(deadline: .now() + onDelay) {
                    self.isBlinking = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + offDelay) {
                    self.isBlinking = false
                }
            }

            cursorSamples += AVAudioFramePosition(frames)
            cursorSecs += block.dur
        }

        // Securite: eteindre a la fin de la sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + cursorSecs + 0.01) {
            self.isBlinking = false
        }
    }

    private func makeToneBuffer(frames: AVAudioFrameCount) -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buffer.frameLength = frames
        let ch = buffer.floatChannelData![0]
        for i in 0..<Int(frames) {
            let angle = 2.0 * Double.pi * frequency * Double(i) / sampleRate
            ch[i] = Float(sin(angle))
        }
        return buffer
    }

    private func makeSilenceBuffer(frames: AVAudioFrameCount) -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buffer.frameLength = frames
        memset(buffer.floatChannelData![0], 0, Int(frames) * MemoryLayout<Float>.size)
        return buffer
    }
}
