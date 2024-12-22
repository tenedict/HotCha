

import AVFoundation
import MediaPlayer


// 소리를 내주는 뷰 입니다.
// 밑에 함수만 불러서 어디에서는 사용 가능

class SoundManager {
    static let shared = SoundManager() // 싱글톤 인스턴스
    private var player: AVAudioPlayer?
    private var originalVolume: Float = 0.0
    private let volumeView = MPVolumeView()
    
    private init() {
        setupAudioSession()
    }
    
    /// 오디오 세션 초기화
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }
    }
    
    /// 오디오 파일 로드
    func loadAudioFile(named fileName: String, fileType: String = "mp3") {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            print("\(fileName).\(fileType) 파일이 없습니다.")
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            print("오디오 파일 로드 성공: \(fileName).\(fileType)")
        } catch {
            print("오디오 파일 로드 실패: \(error)")
        }
    }
    
    
    /// 오디오 재생 (이어폰 연결 시에만 재생)
        func play(loopCount: Int = 0) {
            guard let player = player else {
                print("오디오 파일이 로드되지 않았습니다.")
                return
            }
            
            // 이어폰 착용 여부 확인
            if isHeadphonesConnected() {
                // 현재 볼륨 저장
                originalVolume = AVAudioSession.sharedInstance().outputVolume
                
                // 볼륨 조정
                if originalVolume < 1.0 {
                    setSystemVolume(0.6)
                }
                
                // 루프 설정
                player.numberOfLoops = loopCount
                player.play()
                print("오디오 재생 시작 (이어폰으로)")
            } else {
                print("이어폰이 연결되지 않았습니다. 재생이 취소됩니다.")
            }
        }
    
    /// 오디오 중지
    func stop() {
        guard let player = player else { return }
        player.stop()
        setSystemVolume(originalVolume) // 볼륨 복구
        print("오디오 재생 중지")
    }
    
    /// 현재 오디오 상태 확인
    func isPlaying() -> Bool {
        return player?.isPlaying ?? false
    }
    
    /// 이어폰 연결 여부 확인
        func isHeadphonesConnected() -> Bool {
            let session = AVAudioSession.sharedInstance()
            return session.currentRoute.outputs.contains { output in
                return output.portType == .headphones || output.portType == .bluetoothA2DP
            }
        }
    
    
    /// 시스템 볼륨 설정
    private func setSystemVolume(_ volume: Float) {
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            DispatchQueue.main.async {
                slider.value = volume
            }
        }
    }
}
