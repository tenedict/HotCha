

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
    func startUpdatingBusLocation(cityCode: Int, routeId: String, nodeOrd: Int) {
        stopUpdatingBusLocation() // 기존 타이머 정지
        self.locationManager.getCurrentLocation() // 위치 업데이트

        self.fetchBusLocationData(cityCode: cityCode, routeId: routeId, nodeOrd: nodeOrd) {
               self.findClosestBusLocation() // 가장 가까운 버스 찾기
           }
        
        // 타이머 시작
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.locationManager.getCurrentLocation() // 위치 업데이트
            self?.fetchBusLocationData(cityCode: cityCode, routeId: routeId, nodeOrd: nodeOrd) {
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
    func fetchBusLocationData(cityCode: Int, routeId: String, nodeOrd: Int, completion: @escaping () -> Void) {
        fetchNowBusLocationData(cityCode: cityCode, routeId: routeId) { [weak self] locations in
            DispatchQueue.main.async {
                // API에서 받은 버스 위치 데이터를 오류 보정 후 저장
                self?.NowbusLocations = locations.map { self?.validateAndFixCoordinates(for: $0) ?? $0
                }
                print("현재 운행중인 버스 위치 목록: \(self?.NowbusLocations ?? [])")
                
                // 도착 정류장을 지난 버스를 배열에서 제외
                // NowbusLocations 배열에 있는 요소들 중 요소.nodeOrd(Int 타입)의 값이 nodeOrd 보다 크면 배열에서 뺌
                self?.NowbusLocations = self?.NowbusLocations.filter { Int($0.nodeord) ?? 0 <= nodeOrd } ?? []
                print("필터링된 버스 위치 목록: \(self?.NowbusLocations ?? [])")
                           
                completion()  // 버스 위치 데이터를 다 가져오면 completion 핸들러 호출
            }
        }
    }
    
    // 위치 업데이트를 시작하는 함수 (routeId 필요)
    func startUpdatingSeoulBusLocation(routeId: String, sectOrd: Int) {
        stopUpdatingBusLocation() // 기존 타이머 정지
        self.locationManager.getCurrentLocation() // 위치 업데이트
        self.fetchSeoulBusLocationData(routeId: routeId, sectOrd: sectOrd) {
            self.findClosestSeoulBusLocation() // 가장 가까운 버스 찾기
        }
        
        // 타이머 시작
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.locationManager.getCurrentLocation() // 위치 업데이트
            self?.fetchSeoulBusLocationData(routeId: routeId, sectOrd: sectOrd) {
                self?.findClosestSeoulBusLocation() // 가장 가까운 버스 찾기
            }
        }
    }
    
    // 가장 가까운 버스를 찾는 함수
    func findClosestSeoulBusLocation() {
        guard let userLocation = locationManager.currentLocation else { return }

        // 서울 버스 위치 데이터를 오류 보정 후 사용
        let correctedLocations = seoulBusLocations.map { validateAndFixSeoulCoordinates(for: $0) }

        // 가장 가까운 버스를 찾는 로직
        closestSeoulBusLocation = correctedLocations.min(by: { bus1, bus2 in
            let busLocation1 = CLLocation(latitude: bus1.gpsY, longitude: bus1.gpsX)
            let busLocation2 = CLLocation(latitude: bus2.gpsY, longitude: bus2.gpsX)

            return userLocation.distance(from: busLocation1) < userLocation.distance(from: busLocation2)
        })

        if let closestBus = closestSeoulBusLocation {
            print("가장 가까운 서울 버스 위치: (\(closestBus.gpsY), \(closestBus.gpsX))")
        } else {
            print("가까운 버스를 찾을 수 없습니다.")
        }
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

    // 운행 중인 서울 버스를 받아오는 함수
    func fetchSeoulBusLocationData(routeId: String, sectOrd: Int, completion: @escaping () -> Void) {
        fetchSeoulBusLocation(busRouteId: routeId) { [weak self] locations, errorMessage in
            DispatchQueue.main.async {
                if let locations = locations {
                    // 보정된 데이터를 저장하고 출력
                    self?.seoulBusLocations = locations.map {
                        let correctedBusInfo = self?.validateAndFixSeoulCoordinates(for: $0) ?? $0
                        print("보정된 서울 버스 위치: \(correctedBusInfo)") // 보정된 값 출력
                        return correctedBusInfo
                    }
                }
                
                // 도착 정류장을 지난 버스를 배열에서 제외
                // seoulBusLocations 배열에 있는 요소들 중 요소.sectOrd(Int 타입)의 값이 sectOrd 보다 크면 배열에서 뺌
                self?.seoulBusLocations = self?.seoulBusLocations.filter { Int($0.sectOrd) ?? 0 <= sectOrd } ?? []
                print("필터링된 서울 버스 위치 목록: \(self?.seoulBusLocations ?? [])")
                
                completion()  // 데이터를 다 가져오면 completion 핸들러 호출
            }
        }
    }

    private func validateAndFixSeoulCoordinates(for busInfo: BusInfo) -> BusInfo {
        var correctedBusInfo = busInfo
        
        // gpsY: 위도, gpsX: 경도
        let latitude = busInfo.gpsY
        let longitude = busInfo.gpsX
        
        // 위도와 경도가 올바른지 확인 (대한민국 기준 위도: 약 33~38, 경도: 약 124~132)
        if latitude < 33 || latitude > 38 || longitude < 124 || longitude > 132 {
            // 위도와 경도가 뒤바뀐 경우 수정
            correctedBusInfo.gpsY = latitude
            correctedBusInfo.gpsX = longitude
        }
        
        return correctedBusInfo
    }
}
