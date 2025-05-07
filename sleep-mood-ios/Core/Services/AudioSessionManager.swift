import AVFoundation

class AudioSessionManager {
    static let shared = AudioSessionManager()
    private init() {}

    func activateForPlayback() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            print("오디오 세션 재생 활성화 실패: \(error)")
        }
    }

    func deactivate() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch {
            print("오디오 세션 비활성화 실패: \(error)")
        }
    }
} 