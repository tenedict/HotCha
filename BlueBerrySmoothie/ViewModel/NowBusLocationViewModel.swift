

// 이게 어쩌면 가장 중요한데.
// 여기서 서울이랑 전국 따로 나누어 져있음
// 전국 서울 각각 시작하기 함수가 있고 시작하는 함수를 호출하면 정해진 시간마다 가장 가까운 버스를 계속해서 찾아줌
// 다 찾고 나서 종료함수가 필히 동작하거나 앱이꺼져야만 api업데이트를 멈춤

import Foundation
import CoreLocation
import Combine


// 전국, 서울 버스의 가장 가까운 위치 받아오는 뷰 모델
class NowBusLocationViewModel: NSObject, ObservableObject {
    @Published var closestBusLocation: NowBusLocation?
    @Published var NowbusLocations: [NowBusLocation] = []
    @Published var closestSeoulBusLocation: BusInfo? // 가장 가까운 버스 위치
    @Published var seoulBusLocations: [BusInfo] = [] // 현재 모든 버스 위치
    private var locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer? // 10초마다 업데이트를 위한 타이머
    
    override init() {
        super.init()
        locationManager.getCurrentLocation() // 초기 위치 요청
    }

    // 위치 업데이트를 시작하는 함수 (cityCode, routeId 필요)
    func startUpdatingBusLocation(cityCode: Int, routeId: String) {
        stopUpdatingBusLocation() // 기존 타이머 정지
        self.locationManager.getCurrentLocation() // 위치 업데이트

           self.fetchBusLocationData(cityCode: cityCode, routeId: routeId) {
               self.findClosestBusLocation() // 가장 가까운 버스 찾기
           }
        
        // 타이머 시작
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.locationManager.getCurrentLocation() // 위치 업데이트
            self?.fetchBusLocationData(cityCode: cityCode, routeId: routeId) {
                self?.findClosestBusLocation() // 가장 가까운 버스 찾기
            }
        }
    }

    // 위치 업데이트를 멈추는 함수
    func stopUpdatingBusLocation() {
        timer?.invalidate()
        timer = nil
    }

    // 위치 권한 상태 업데이트를 수동으로 호출 가능
    func fetchUserLocation() {
        locationManager.getCurrentLocation()
    }

    // 가장 가까운 버스를 찾는 함수
    func findClosestBusLocation() {
        guard let userLocation = locationManager.currentLocation else { return }

        // 버스 위치 데이터를 받아오기 전에 위도, 경도 오류 보정 처리
        let correctedLocations = NowbusLocations.map { self.validateAndFixCoordinates(for: $0) }

        // 가장 가까운 버스를 찾는 로직
        closestBusLocation = correctedLocations.min(by: { bus1, bus2 in
            let busLocation1 = CLLocation(latitude: Double(bus1.gpslati) ?? 0, longitude: Double(bus1.gpslong) ?? 0)
            let busLocation2 = CLLocation(latitude: Double(bus2.gpslati) ?? 0, longitude: Double(bus2.gpslong) ?? 0)

            return userLocation.distance(from: busLocation1) < userLocation.distance(from: busLocation2)
        })
    }

    // 위도와 경도를 검증하고 필요한 경우 수정
    private func validateAndFixCoordinates(for busLocation: NowBusLocation) -> NowBusLocation {
        var correctedBusLocation = busLocation
        guard let latitude = Double(busLocation.gpslati),
              let longitude = Double(busLocation.gpslong) else {
            return correctedBusLocation
        }

        // 위도와 경도가 올바른지 확인 (대한민국 기준 위도는 약 33~38, 경도는 약 124~132)
        if latitude < 20 || latitude > 40 || longitude < 110 || longitude > 140 {
            // 위도와 경도가 뒤바뀐 경우 수정
            correctedBusLocation.gpslati = String(longitude)
            correctedBusLocation.gpslong = String(latitude)
        }

        return correctedBusLocation
    }
    

    // API를 호출하여 버스 위치 데이터를 가져오는 함수
    func fetchBusLocationData(cityCode: Int, routeId: String, completion: @escaping () -> Void) {
        fetchNowBusLocationData(cityCode: cityCode, routeId: routeId) { [weak self] locations in
            DispatchQueue.main.async {
                // API에서 받은 버스 위치 데이터를 오류 보정 후 저장
                self?.NowbusLocations = locations.map { self?.validateAndFixCoordinates(for: $0) ?? $0 }
                completion()  // 버스 위치 데이터를 다 가져오면 completion 핸들러 호출
            }
        }
    }
    
    
    // 위치 업데이트를 시작하는 함수 (routeId 필요)
    func startUpdatingSeoulBusLocation(routeId: String) {
        stopUpdatingBusLocation() // 기존 타이머 정지
        self.locationManager.getCurrentLocation() // 위치 업데이트
        self.fetchSeoulBusLocationData(routeId: routeId) {
            self.findClosestSeoulBusLocation() // 가장 가까운 버스 찾기
        }
        
        // 타이머 시작
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.locationManager.getCurrentLocation() // 위치 업데이트
            self?.fetchSeoulBusLocationData(routeId: routeId) {
                self?.findClosestSeoulBusLocation() // 가장 가까운 버스 찾기
            }
        }
    }
    
    // 가장 가까운 버스를 찾는 함수
    func findClosestSeoulBusLocation() {
        guard let userLocation = locationManager.currentLocation else { return }

        // 가장 가까운 버스를 찾는 로직
        closestSeoulBusLocation = seoulBusLocations.min(by: { bus1, bus2 in
            let busLocation1 = CLLocation(latitude: bus1.gpsY, longitude: bus1.gpsX)
            let busLocation2 = CLLocation(latitude: bus2.gpsY, longitude: bus2.gpsX)
            
            print(closestSeoulBusLocation?.gpsX)
            
            return userLocation.distance(from: busLocation1) < userLocation.distance(from: busLocation2)
            
        })
    }
//
//    // API를 호출하여 서울 버스 위치 데이터를 가져오는 함수(위도 경도 오류 )
//    func fetchSeoulBusLocationData(routeId: String, completion: @escaping () -> Void) {
//        fetchSeoulBusLocation(busRouteId: routeId) { [weak self] locations, errorMessage in
//            DispatchQueue.main.async {
//                // API에서 받은 버스 위치 데이터를 저장
//                if let locations = locations {
//                    self?.seoulBusLocations = locations
//                }
//                completion()  // 버스 위치 데이터를 다 가져오면 completion 핸들러 호출
//            }
//        }
//    }


    func fetchSeoulBusLocationData(routeId: String, completion: @escaping () -> Void) {
        fetchSeoulBusLocation(busRouteId: routeId) { [weak self] locations, errorMessage in
            DispatchQueue.main.async {
                // API에서 받은 서울 버스 위치 데이터를 보정 후 저장
                if let locations = locations {
                    // 보정된 데이터를 저장하고 출력
                    self?.seoulBusLocations = locations.map {
                        let correctedBusInfo = self?.validateAndFixCoordinates(for: $0) ?? $0
                        print("보정된 버스 위치: \(correctedBusInfo)")  // 보정된 값 출력
                        return correctedBusInfo
                    }
                }
                completion()  // 버스 위치 데이터를 다 가져오면 completion 핸들러 호출
            }
        }
    }

    private func validateAndFixCoordinates(for busInfo: BusInfo) -> BusInfo {
        var correctedBusInfo = busInfo
        
        // gpsY, gpsX가 Double 타입일 경우
        let latitude = busInfo.gpsX
        let longitude = busInfo.gpsY
        
        // 위도와 경도가 올바른지 확인 (대한민국 기준 위도는 약 33~38, 경도는 약 124~132)
        if latitude < 20 || latitude > 40 || longitude < 110 || longitude > 140 {
            // 위도와 경도가 뒤바뀐 경우 수정
            correctedBusInfo.gpsY = latitude
            correctedBusInfo.gpsX = longitude
        }
        
        return correctedBusInfo
    }
}
