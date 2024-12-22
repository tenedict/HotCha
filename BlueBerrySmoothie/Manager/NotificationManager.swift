 


// 함수 호출해서 노티피케이션을 보낼 수 있습니다.
// 시작호출하면 중단할때까지 반복됩니다.
// 중단함수를 호출해야 중단 됩니다. 
import Foundation
import UserNotifications
import AVFoundation

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager() // Singleton
    private var isRunning = false // 알림 활성화 상태 체크
    private var audioPlayer: AVAudioPlayer? // 소리 재생을 위한 플레이어
    
    private override init() {} // Singleton 방지
    
    // **알림 시작 함수**
    func startNotifications(title: String, subtitle: String) {
        guard !isRunning else {
            print("Notifications are already running.")
            return
        }
        
        isRunning = true
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.interruptionLevel = .timeSensitive // 타임 센시티브 설정
        
        // 이어폰 연결 여부에 따라 소리 설정
        if isHeadphonesConnected() {
            content.sound = UNNotificationSound.default
        } else {
            content.sound = UNNotificationSound(named: UNNotificationSoundName("silentSound.wav"))
        }
        
        scheduleRepeatingNotification(with: content)
    }
    
    // **알림 중단 함수**
    func stopNotifications() {
        guard isRunning else {
            print("Notifications are not running.")
            return
        }
        
        isRunning = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        audioPlayer?.stop()
        audioPlayer = nil
        print("All notifications have been stopped.")
    }
    
// 반복하는 함수 2초마다
    private func scheduleRepeatingNotification(with content: UNMutableNotificationContent) {
        guard isRunning else { return }
        
        let identifier = UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled: \(identifier)")
                // 다음 알림 스케줄
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.scheduleRepeatingNotification(with: content)
                }
            }
        }
    }
    
    // **이어폰 연결 여부 확인**
    private func isHeadphonesConnected() -> Bool {
        let session = AVAudioSession.sharedInstance()
        return session.currentRoute.outputs.contains { $0.portType == .headphones || $0.portType == .bluetoothA2DP }
    }
    
    // **알림을 수신했을 때의 처리**
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 알림을 화면에 표시하고, 소리를 울리게 할지 여부를 결정할 수 있습니다.
        completionHandler([.banner, .sound])
    }
    
    // **알림이 클릭되었을 때의 처리**
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 알림 클릭 시 할 작업을 추가할 수 있습니다.
        print("Notification clicked: \(response.notification.request.identifier)")
        completionHandler()
    }
}
