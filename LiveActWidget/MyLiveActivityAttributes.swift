// 라이브액티비티에 전달하는 구조체


import SwiftUI
import WidgetKit
import ActivityKit

// Live Activity의 속성 정의
struct MyLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var progress: Double       // 진행 상태 (0.0 ~ 1.0)
        var currentStop: String    // 현재 정류장
        var stopsRemaining: Int    // 남은 정류장 수
        var Updatetime: String // 업데이트 시간
    }

    var title: String         // 라이브 액티비티 제목
    var description: String   // 설명
}

