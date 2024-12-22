

// 위치 권한 요청
// 내 위치 받아오기
// 내 위치를 받아오는 것을 껏다 켰다 할 수 있습니다. 
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager() // 싱글톤 인스턴스
    let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation? // 현재 위치를 저장
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var errorMessage: String?

    override init() {
        super.init()
        manager.delegate = self
        checkIfLocationServicesIsEnabled()
    }

    // 위치 서비스가 활성화되어 있는지 확인
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            checkLocationAuthorization()
        } else {
            errorMessage = "위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 켜주세요."
        }
    }


    // 백그라운드 위치 업데이트 활성화
    func enableBackgroundUpdates() {
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false // 필요에 따라 자동 중지 비활성화
    }
    
    // 위치 권한 상태를 확인
    public func checkLocationAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            requestWhenInUsePermission()
        case .authorizedWhenInUse:
            // 'WhenInUse' 권한을 받으면 항상 권한 요청
            requestAlwaysPermission() // 수정 위치
            manager.requestLocation()
        case .authorizedAlways:
            // 'Always' 권한이 있으면 백그라운드 업데이트 활성화
            enableBackgroundUpdates() // 수정 위치
            manager.requestLocation()
        case .restricted:
            errorMessage = "위치 서비스 접근이 제한되어 있습니다."
        case .denied:
            errorMessage = "위치 서비스 권한이 거부되었습니다. 설정에서 권한을 허용해주세요."
        @unknown default:
            print("알 수 없는 권한 상태")
        }
    }

    // 위치 권한 요청
    public func requestWhenInUsePermission() {
        manager.requestWhenInUseAuthorization()
    }

    // 위치 권한 요청 (Always)
    public func requestAlwaysPermission() {
        manager.requestAlwaysAuthorization()
    }

    // 현재 위치를 반환하는 함수 (한 번만 요청)
    func getCurrentLocation() {
        manager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    // 위치가 업데이트되면 호출되는 메소드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        currentLocation = newLocation
        print("현재 위치 업데이트: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
    }
    
    // 위치 권한 상태 변경 시 호출되는 메소드
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        switch status {
        case .authorizedAlways:
            enableBackgroundUpdates() // 백그라운드 업데이트 활성화
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            requestAlwaysPermission() // "항상" 권한 요청
        case .denied, .restricted:
            errorMessage = "위치 서비스 권한이 거부되었습니다."
        case .notDetermined:
            requestWhenInUsePermission()
        @unknown default:
            print("알 수 없는 상태")
        }
    }
    // 위치 오류 발생 시 호출되는 메소드
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 정보를 가져오는데 실패했습니다: \(error.localizedDescription)")
        errorMessage = "위치 정보를 가져오는데 실패했습니다."
    }
    
    func startLocationUpdates() {
        manager.startUpdatingLocation()
        print("위치 업데이트가 다시 시작되었습니다.")
    }
    
    func stopLocationUpdates() {
            manager.stopUpdatingLocation()
            print("위치 업데이트가 중지되었습니다.")
        }
    
}
