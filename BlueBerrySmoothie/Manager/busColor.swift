


// 버스 색깔 구별해주는 함수들



import SwiftUI

// 버스 타입에 따른 색상을 반환하는 함수
func busColor(for routetp: String) -> Color {
    switch routetp {
    case "간선버스", "일반버스" : return .busBlue
    case "마을버스", "지선버스" : return .busGreen
    case "순환버스" : return .busYellow
    case "급행버스", "광역버스" : return .busRed
    default: return .busOrange
    }
}

// 버스 타입에 따른 텍스트 색상을 반환하는 함수
func busTextColor(for routetp: String) -> Color {
    switch routetp {
    case "간선버스", "일반버스" : return .blue
    case "마을버스", "지선버스" : return .green
    case "순환버스" : return .yellow
    case "급행버스", "광역버스" : return .red
    default: return .orange
    }
}

//// 버스 타입에 따른 배경을 반환하는 함수
//func busAlertBackground(for routetp: String) -> String {
//    switch routetp {
//    case "간선버스", "일반버스" : return "MainCardBlue"
//    case "마을버스", "지선버스" : return "MainCardGreen"
//    case "순환버스" : return "MainCardYellow"
//    case "급행버스", "광역버스" : return "MainCardRed"
//    default: return "MainCardOrange"
//    }
//}
