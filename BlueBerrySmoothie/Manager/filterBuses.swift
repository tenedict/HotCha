// 버스 필터링 해줍니다.필터링 할때 쓰면 댑니다.
// 모든 정류장을 저장해두고 버스를 불러올때그 버스에 해당하는 정류장을 나열해줍니다. 

import Foundation

// 입력된 노선 번호에 따라 버스를 필터링하는 함수
func filterBuses(by routeNo: String, from allBuses: [Bus]) -> [Bus] {
    if routeNo.isEmpty {
        return allBuses // 입력이 없으면 전체 목록 반환
    } else {
        return allBuses.filter { $0.routeno.contains(routeNo) }
            .sorted {
                let firstLength = $0.routeno.count
                let secondLength = $1.routeno.count
                if firstLength == secondLength {
                    return $0.routeno < $1.routeno
                }
                return firstLength < secondLength
            }
    }
}
