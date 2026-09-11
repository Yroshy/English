import Foundation
import AVFoundation
import Combine

/// Handles microphone recording + playback for the Saturday "Speaking" exercise,
/// where the learner records themselves reading/talking about the weekly text
/// to self-assess pronunciation and fluency.
@MainActor
final class AudioRecorderService: NSObject, ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var isPlaying = false
    @Published private(set) var hasRecording = false
    @Published var permissionDenied = false

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?

    private var fileURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("onetext-speaking-practice.m4a")
    }

    func requestPermissionAndRecord() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                guard let self else { return }
                if granted {
                    self.startRecording()
                } else {
                    self.permissionDenied = true
                }
            }
        }
    }

    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder?.record()
            isRecording = true
        } catch {
            isRecording = false
        }
    }

    func stopRecording() {
        recorder?.stop()
        isRecording = false
        hasRecording = FileManager.default.fileExists(atPath: fileURL.path)
    }

    func playback() {
        guard hasRecording else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            player = try AVAudioPlayer(contentsOf: fileURL)
            player?.delegate = self
            player?.play()
            isPlaying = true
        } catch {
            isPlaying = false
        }
    }

    func stopPlayback() {
        player?.stop()
        isPlaying = false
    }
}

extension AudioRecorderService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }
}
