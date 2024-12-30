


// 모든 버스 데이터를 가지고 오는 겁니다.
// 버스 선택할때 사용

// 전체 버스 데이터를 불러오는 함수
func fetchAllBusData(citycode: Int, completion: @escaping ([Bus]) -> Void) {
    fetchBusData(citycode: citycode, routeNo: "") { fetchedBuses in
        completion(fetchedBuses)
    }
}
