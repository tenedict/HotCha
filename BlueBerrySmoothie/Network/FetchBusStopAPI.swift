
import Foundation



class NetworkManager: ObservableObject {
    
    // 버스 정류장 데이터를 가져오는 함수
    func getBusStopData(cityCode: Int, routeId: String) async throws -> [BusStop] {
        // BusStopResponse를 통해 모든 데이터를 가져온 뒤 필요한 배열만 추출하여 반환
        let response: BusStopResponse = try await fetchBusStopData(cityCode: cityCode, routeId: routeId)
        return response.response.body.items?.item ?? []
    }
    
    // API에서 받아온 응답 중 BusStopRensponse를 추출하여 반환
    private func fetchBusStopData(cityCode: Int, routeId: String) async throws -> BusStopResponse {
        
        guard let serviceKey = getAPIKey() else {
            throw APIError.invalidAPI // API 키를 가져오지 못한 경우 예외 처리
        }
        
        let urlString = "http://apis.data.go.kr/1613000/BusRouteInfoInqireService/getRouteAcctoThrghSttnList?serviceKey=\(serviceKey)&_type=json&cityCode=\(cityCode)&routeId=\(routeId)&numOfRows=999"
        
        guard let url = URL(string: urlString) else {
            print("APIError.invalidURL")
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.requestFailed(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            // JSONDecoder를 통해 BusStopResponse로 디코딩
            return try JSONDecoder().decode(BusStopResponse.self, from: data)
        } catch {
            // 디코딩 에러 확인 및 처리
            if let decodingError = error as? DecodingError {
                print("Decoding error: \(decodingError)")
                throw APIError.decodingError(underlyingError: decodingError)
            } else {
                throw APIError.dataLoadingError(underlyingError: error)
            }
        }
    }
}
