

import SwiftUI
import Foundation

class BusSeoulStationParserDelegate: NSObject, XMLParserDelegate {
    var parsedStations: [BusStop] = []
    private var currentElement = ""
    private var currentBusStation: BusStop?
    private var currentText = ""
    
    // XML의 시작 태그를 처리
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        // <itemList> 태그 시작 시 새로운 BusStation 객체 생성
        if elementName == "itemList" {
               // itemList에서 필요한 값을 초기화
               currentBusStation = BusStop(
                   routeid: "", // 초기 값 설정
                   nodeid: "", // 초기 값 설정
                   nodenm: "", // 초기 값 설정
                   nodeno: 1,
                   nodeord: 0, // 초기 값 설정
                   gpslati: 0.0, // 초기 값 설정
                   gpslong: 0.0 // 초기 값 설정
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
        case "busRouteId":
            currentBusStation?.routeid = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "gpsX":
            currentBusStation?.gpslati = Double(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
        case "gpsY":
            currentBusStation?.gpslong = Double(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
        case "seq":
            currentBusStation?.nodeord = Int(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        case "stationNm":
            currentBusStation?.nodenm = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "station":
            currentBusStation?.nodeid = currentText.trimmingCharacters(in: .whitespacesAndNewlines)

        case "itemList":
            if let validBusStation = currentBusStation {
                parsedStations.append(validBusStation)
//                print("✅ 버스 정류장 추가: \(validBusStation)")
            }
            currentBusStation = nil
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

// 데이터를 가져오는 함수
func fetchBusStations(routeId: String, completion: @escaping ([BusStop], String?) -> Void) {
    
    if let apiKey = getAPIKey() {
        print("API Key: \(apiKey)")
        // 여기서 API 호출에 사용
    
    let urlString = "http://ws.bus.go.kr/api/rest/busRouteInfo/getStaionByRoute?serviceKey=B%2FSwHGsQuvan%2F%2Fs6M6QvZooclQm9QpSHe%2BqbWjT4xPwDgHNXOES93T9i1%2BDKEJPWfCgcTf12X64bS9A42fFRkA%3D%3D&busRouteId=\(routeId)"
    
    guard let url = URL(string: urlString) else {
        print("🚨 잘못된 URL")
        completion([], "잘못된 URL") // URL이 잘못되었으면 빈 배열 반환
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("❌ 데이터 가져오기 실패: \(error.localizedDescription)")
            completion([], error.localizedDescription) // 데이터 가져오기 실패 시 빈 배열과 오류 메시지 반환
            return
        }
        
        guard let data = data else {
            print("❌ 데이터 없음")
            completion([], "데이터가 없음") // 데이터가 없으면 빈 배열과 오류 메시지 반환
            return
        }
        
        let parser = XMLParser(data: data)
        let busSeoulStationParserDelegate = BusSeoulStationParserDelegate()  // XML 파싱을 위한 delegate
        parser.delegate = busSeoulStationParserDelegate
        
        if parser.parse() {
            print("✅ XML 파싱 성공")
            completion(busSeoulStationParserDelegate.parsedStations, nil)  // 파싱된 버스 데이터를 반환
        } else {
            print("❌ XML 파싱 실패")
            completion([], "XML 파싱 실패") // 파싱 실패 시 빈 배열과 오류 메시지 반환
        }
    }.resume()
        
    } else {
        print("API Key가 없습니다.")
    }
}


