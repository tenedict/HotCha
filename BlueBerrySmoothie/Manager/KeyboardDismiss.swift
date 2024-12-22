// 키보드 내리는 함수입니다.
// 호출해서 사용가능

import SwiftUI

// 키보드를 내리는 함수
func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
