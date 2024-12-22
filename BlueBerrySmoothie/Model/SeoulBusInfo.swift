// 서울 버스 구조체
// BusInfo는 서울이라고 생각하면 된다. 

import Foundation


// BusInfo 구조체는 기존과 동일합니다.
struct BusInfo: Identifiable {
    var id: String {
        vehId // 각 버스의 ID는 vehId로 식별합니다.
    }
    var busType: String
    var congetion: String
    var dataTm: String
    var fullSectDist: String
    var gpsX: Double
    var gpsY: Double
    var isFullFlag: String
    var islastyn: String
    var isrunyn: String
    var lastStTm: String
    var lastStnId: String
    var nextStId: String
    var nextStTm: String
    var plainNo: String
    var posX: Double
    var posY: Double
    var rtDist: String
    var sectDist: String
    var sectOrd: String
    var sectionId: String
    var stopFlag: String
    var trnstnid: String
    var vehId: String
}

// BusInfoParser 클래스는 기존과 동일하게 사용합니다.
class BusInfoParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentBusInfo: [String: String] = [:]
    private var busInfos = [BusInfo]()
    var completionHandler: (([BusInfo]) -> Void)?

    func parse(data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }

    // XMLParserDelegate Methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else { return }
        currentBusInfo[currentElement] = (currentBusInfo[currentElement] ?? "") + trimmedString
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "itemList" {
            guard let gpsX = Double(currentBusInfo["gpsX"] ?? ""),
                  let gpsY = Double(currentBusInfo["gpsY"] ?? ""),
                  let posX = Double(currentBusInfo["posX"] ?? ""),
                  let posY = Double(currentBusInfo["posY"] ?? "") else {
                currentBusInfo.removeAll()
                return
            }

            let busInfo = BusInfo(
                busType: currentBusInfo["busType"] ?? "",
                congetion: currentBusInfo["congetion"] ?? "",
                dataTm: currentBusInfo["dataTm"] ?? "",
                fullSectDist: currentBusInfo["fullSectDist"] ?? "",
                gpsX: gpsX,
                gpsY: gpsY,
                isFullFlag: currentBusInfo["isFullFlag"] ?? "",
                islastyn: currentBusInfo["islastyn"] ?? "",
                isrunyn: currentBusInfo["isrunyn"] ?? "",
                lastStTm: currentBusInfo["lastStTm"] ?? "",
                lastStnId: currentBusInfo["lastStnId"] ?? "",
                nextStId: currentBusInfo["nextStId"] ?? "",
                nextStTm: currentBusInfo["nextStTm"] ?? "",
                plainNo: currentBusInfo["plainNo"] ?? "",
                posX: posX,
                posY: posY,
                rtDist: currentBusInfo["rtDist"] ?? "",
                sectDist: currentBusInfo["sectDist"] ?? "",
                sectOrd: currentBusInfo["sectOrd"] ?? "",
                sectionId: currentBusInfo["sectionId"] ?? "",
                stopFlag: currentBusInfo["stopFlag"] ?? "",
                trnstnid: currentBusInfo["trnstnid"] ?? "",
                vehId: currentBusInfo["vehId"] ?? ""
            )
            busInfos.append(busInfo)
            currentBusInfo.removeAll()
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        completionHandler?(busInfos)
    }
}


