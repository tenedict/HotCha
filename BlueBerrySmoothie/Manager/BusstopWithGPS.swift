


import Foundation
import CoreLocation


// 버스 정류장이랑 가까이 있는지 확인하는 뷰
extension LocationManager {
    // 특정 버스 정류장 좌표와 현재 위치를 비교하여 10m 거리 안인지 확인
    // 위도 경도를 받아서 내 위치랑 비교해서 true,false값 알려줌
    func BusstopWithGPS(latitude: Double, longitude: Double) -> Bool {
        guard let currentLocation = currentLocation else {
            print("현재 위치가 설정되지 않았습니다.")
            return false
        }

        // 현재 위치의 위도, 경도를 출력
        print("내 위치 - 위도: \(currentLocation.coordinate.latitude), 경도: \(currentLocation.coordinate.longitude)")
        print(latitude, longitude,"??")
        let targetLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distance = currentLocation.distance(from: targetLocation)

        print("거리 계산: \(distance)미터")
        return distance <= 10.0
    }
}
