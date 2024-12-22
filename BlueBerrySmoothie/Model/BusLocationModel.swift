// 전국 버스 용이다. 구조

import Foundation

struct NowBusLocation: Codable, Identifiable {
    var id = UUID()
    var gpslati: String
    var gpslong: String
    var nodeid: String
    var nodenm: String
    var nodeord: String
    var routenm: String
    var routetp: String
    var vehicleno: String

    // 커스텀 디코딩 구현
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // 값을 디코딩하고 String으로 변환
        gpslati = try Self.decodeAsString(container: container, forKey: .gpslati)
        gpslong = try Self.decodeAsString(container: container, forKey: .gpslong)
        nodeid = try Self.decodeAsString(container: container, forKey: .nodeid)
        nodenm = try Self.decodeAsString(container: container, forKey: .nodenm)
        nodeord = try Self.decodeAsString(container: container, forKey: .nodeord)
        routenm = try Self.decodeAsString(container: container, forKey: .routenm)
        routetp = try Self.decodeAsString(container: container, forKey: .routetp)
        vehicleno = try Self.decodeAsString(container: container, forKey: .vehicleno)
    }

    // 유틸리티 메서드: 다양한 타입(String, Int, Double)을 String으로 디코딩
    private static func decodeAsString(container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> String {
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: key) {
            return String(intValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return String(doubleValue)
        } else {
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Value cannot be decoded as String, Int, or Double")
        }
    }

    // 키 열거형
    private enum CodingKeys: String, CodingKey {
        case gpslati, gpslong, nodeid, nodenm, nodeord, routenm, routetp, vehicleno
    }
}
