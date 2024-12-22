// 도시 선택입니다.
// 그때 그대로 입니다.

import SwiftUI

struct CitySettingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isSelectCitySheetPresented = false // Sheet 상태 관리
    @State private var selectedCity: City = City(id: "1", category: "없음", name: "선택된 도시 없음", consonant: "ㅋ") // 선택된 도시 저장
    @State private var savedCityName: String = ""
    let userDefaultsKey = "CityCodeKey"
    
    var body: some View {
        VStack() {
            // 현재 선택된 도시 표시
            HStack {
                Text("지역 설정")
                    .font(.title2)
                    .padding(.vertical, 8)
                Spacer()
                
            }
            
            HStack {
                Text("버스 타는 지역을 설정해주세요")
                    .foregroundStyle(.gray3)
                    .font(.caption1)
                Spacer()
            }
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 64)
                .background(.gray7)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray5, lineWidth: 1)
                )
                .overlay(
                    HStack {
                        Text("지역")
                            .font(.body2) // 텍스트 스타일
                        Spacer()
                        Button(action:{isSelectCitySheetPresented = true}) {
                            Text("\(selectedCity.name)")
                                .font(.body2)
                                .foregroundStyle(.blackasset)
                        }
                        
                    }
                        .padding(.horizontal, 20)
                ).padding(.vertical, 32)
            
            
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $isSelectCitySheetPresented) {
            // sheet에 전달할 데이터를 binding으로 전달
            SelectCityView(selectedCity: $selectedCity) // 데이터를 @Binding으로 전달
        }
        .onAppear {
            loadCityCode()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            // 닫기 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.body1)
                    }
                    .foregroundStyle(.gray1Dgray6)
                }
            }
        }
    }
    
    private func loadCityCode() {
        let savedCityID = UserDefaults.standard.string(forKey: "\(userDefaultsKey)ID") ?? "1"
        let savedCityName = UserDefaults.standard.string(forKey: "\(userDefaultsKey)Name") ?? "선택된 도시 없음"
        selectedCity = City(id: savedCityID, category: "없음", name: savedCityName, consonant: "ㅋ")
    }
    
    
}


#Preview {
    CitySettingView()
}
