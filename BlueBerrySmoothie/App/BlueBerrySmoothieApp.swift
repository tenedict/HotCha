// 앱 파일

import SwiftUI
import SwiftData

@main

struct BlueBerrySmoothieApp: App {
    @StateObject private var busStopViewModel = BusStopViewModel()// AppDelegate 역할 클래스와 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(busStopViewModel)
                .modelContainer(for: [BusAlert.self, BusStopLocal.self])
        }

    }
}
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // UNUserNotificationCenter의 delegate를 NotificationManager로 설정
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = NotificationManager.shared // NotificationManager를 delegate로 설정
        
        // 알림 권한 요청
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 중 오류 발생: \(error)")
            } else {
                print("알림 권한 요청 성공: \(granted)")
            }
        }
        
        return true
    }
}
