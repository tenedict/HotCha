//버스 스탑을 가지고 옴

import Foundation

class BusStopViewModel: ObservableObject {
    @Published var busStopList: [BusStop] = []
    @Published var maxUpwardNodeord: Int = 0
    
    var networkManager = NetworkManager()
    
    func getBusStopData(cityCode: Int, routeId: String) async {
        do {
            let data = try await networkManager.getBusStopData(cityCode: cityCode, routeId: routeId)
            print(routeId)
            DispatchQueue.main.async {
                self.busStopList = data
            }
        } catch {
            print("Error calling getBusStopData API in busStopViewModel")
        }
    }
    
    
}
