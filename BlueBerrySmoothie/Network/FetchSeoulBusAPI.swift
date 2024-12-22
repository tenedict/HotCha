




import SwiftUI
import Foundation

// XML 파서를 위한 커스텀 delegate
class BusParserDelegate: NSObject, XMLParserDelegate {
    var parsedBuses: [Bus] = []
    private var currentElement = ""
    private var currentBusRoute: Bus?
    private var currentText = ""
    
    // XML의 시작 태그를 처리
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        // <itemList> 태그 시작 시 새로운 SeoulBus 객체 생성
        if elementName == "itemList" {
            currentBusRoute = Bus(
                routeno: "",
                routeid: "",
                startnodenm: "",
                endnodenm: "",
                startvehicletime: "",
                endvehicletime: "",
                routetp: ""
            )
        }
    }
    
    // XML의 텍스트 데이터를 처리
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }
    
    // XML의 종료 태그를 처리
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "busRouteNm":
            currentBusRoute?.routeno = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "busRouteId":
            currentBusRoute?.routeid = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "stStationNm":
            currentBusRoute?.startnodenm = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "edStationNm":
            currentBusRoute?.endnodenm = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "firstBusTm":
            currentBusRoute?.startvehicletime = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "lastBusTm":
            currentBusRoute?.endvehicletime = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "routeType":
            currentBusRoute?.routetp = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "itemList":
            if let validBusRoute = currentBusRoute, !validBusRoute.routeid.isEmpty {
                parsedBuses.append(validBusRoute)
                print("✅ 버스 노선 추가: \(validBusRoute)")
            }
            currentBusRoute = nil
        default:
            break
        }
        currentText = ""  // 텍스트 초기화 (다음 태그를 위해)
    }
    
    // 파싱 중 에러가 발생하면 호출되는 함수
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("❌ XML 파싱 오류 발생: \(parseError.localizedDescription)")
    }
}

import Foundation

// 데이터 가져오는 함수
func fetchSeoulBusAPI(citycode: Int, completion: @escaping ([Bus]) -> Void) {
    
    if let apiKey = getAPIKey() {
        print("API Key: \(apiKey)")
        // 여기서 API 호출에 사용
    
    
    
    guard let url = URL(string: "http://ws.bus.go.kr/api/rest/busRouteInfo/getBusRouteList?serviceKey=\(apiKey)&cityCode=\(citycode)") else {
        print("🚨 잘못된 URL")
        completion([]) // URL이 잘못되었으면 빈 배열 반환
        return
    }
    
    
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("❌ 데이터 가져오기 실패: \(error.localizedDescription)")
            completion([]) // 데이터 가져오기 실패 시 빈 배열 반환
            return
        }
        
        guard let data = data else {
            print("❌ 데이터 없음")
            completion([]) // 데이터가 없으면 빈 배열 반환
            return
        }
        
        let parser = XMLParser(data: data)
        let busParserDelegate = BusParserDelegate()  // XML 파싱을 위한 delegate
        parser.delegate = busParserDelegate
        
        if parser.parse() {
            print("✅ XML 파싱 성공")
            completion(busParserDelegate.parsedBuses)  // 파싱된 버스 데이터를 반환
        } else {
            print("❌ XML 파싱 실패")
            completion([]) // 파싱 실패 시 빈 배열 반환
        }
    }.resume()
    } else {
        print("API Key가 없습니다.")
    }
}
