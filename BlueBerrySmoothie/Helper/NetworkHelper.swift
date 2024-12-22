// api에러처리 함수 입니다.


import Foundation

enum APIError: Error {
    case invalidAPI
    case invalidURL
    case requestFailed(statusCode: Int)
    case dataLoadingError(underlyingError: Error)
    case decodingError(underlyingError: Error)
}
