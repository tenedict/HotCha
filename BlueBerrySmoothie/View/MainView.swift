


// 메인 뷰입니다.
// 기존의 뷰.
// 시작하기 버튼 위치(왼쪽 - 가이드라인에서보면 왼쪽에 있는 버튼은 적합하지않음) - 오른쪽으로 이동
// 리스트 크기 (지나치게 크기가 커서 리스트형식에 적합하지 않음) - 줄임
// 이클립스 3개짜리로 된 메뉴 (매우 오래전 스타일이자 현재 이쁜, ux적 편리함과는 거리가 먼 디자인 하찮음) - 꾹눌러서 나오는 방식으로 바꿈
//

import SwiftUI
import SwiftData

struct MainView: View {
    @State private var showSetting: Bool = false
    @Query var busAlerts: [BusAlert] // 알람 데이터를 바인딩
    @Query var busStopLocal: [BusStopLocal]
    @State private var selectedAlert: BusAlert? // State to store the selected BusAlert
    @State private var mainToSetting: BusAlert? = nil
    @State private var isUsingAlertActive: Bool = false // Controls navigation to UsingAlertView
    @State private var isSelected: Bool = false
    @State private var isEditing: Bool = false
    
    @Environment(\.modelContext) private var context // SwiftData의 ModelContext 가져오기

    
    @State private var alertStop: BusStopLocal? // alertStop을 상태로 관리
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    var body: some View {
        NavigationView {
      
                    alertListView()
                        
                        .padding(.horizontal, 20)
                    
             
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
//                            NavigationLink(destination: CitySettingView()){
//                                Image("mainMark")
//                            }
                            NavigationLink(destination: AlertSettingMain()){
//                                Image("mainPlus")
                                Image(systemName: "plus")
                                    .font(.title3)
                                    .foregroundStyle(.brand)
                            }
                        }
                    }

                    ToolbarItem(placement: .navigationBarLeading) {
                        Image("HotCha")
                    }
                }
              

        }
    }
    
    
    
    
    private func alertListView() -> some View {
        ZStack {
            if busAlerts.isEmpty {
                VStack {
//                    Image("MainView")
//                        .frame(width: 200, height: 200)
//                        .padding(.bottom, 4)
                    Text("핫챠가 내릴 곳을 알려드려요!")
                        .foregroundColor(.gray)
                    NavigationLink(destination: AlertSettingMain()) {
                        Text("바로 알람 추가하기")
                            .font(.body)
                            .padding(.horizontal, 20) // 좌우 여백
                            .padding(.vertical, 10)  // 상하 여백
                            .background(
                                Capsule()
                                    .fill(Color("brand")) // 배경색을 brand로 설정
                            )
                            .foregroundColor(.white) // 텍스트 색상 설정
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            } else {
                ScrollView(showsIndicators: false) {
                    // 고정된 알림들을 먼저 표시
                    ForEach(busAlerts.filter { $0.isPinned }.sorted(by: { $0.createdAt > $1.createdAt }), id: \.self) { alert in
                        SavedBus(busStopLocals: busStopLocal, busAlert: alert, isSelected: selectedAlert?.id == alert.id, onDelete: {
                            deleteBusAlert(alert) // 삭제 동작
                        }, createdAt: alert.createdAt)
                        Divider()
                        .onTapGesture {
                            selectedAlert = alert
                            if let foundStop = findAlertBusStop(busAlert: alert, busStops: busStopLocal) {
                                alertStop = foundStop
                            }
                        }
                        .padding(2)
                        .padding(.bottom, 1)
                    }
                    
                    ForEach(busAlerts.filter { !$0.isPinned }.sorted(by: { $0.createdAt > $1.createdAt }), id: \.self) { alert in
                        SavedBus(busStopLocals: busStopLocal, busAlert: alert, isSelected: selectedAlert?.id == alert.id, onDelete: {
                            deleteBusAlert(alert) // 삭제 동작
                        }, createdAt: alert.createdAt)
//                        Divider()
                        .onTapGesture {
                            selectedAlert = alert
                            if let foundStop = findAlertBusStop(busAlert: alert, busStops: busStopLocal) {
                                alertStop = foundStop
                            }
                        }
                        .padding(2)
                        .padding(.bottom, 1)
                    }
                }
            }
        }
    }    

    private func deleteBusAlert(_ busAlert: BusAlert) {
        context.delete(busAlert)
        // 선택된 알람이 삭제된 경우 nil로 설정
        if selectedAlert?.id == busAlert.id {
            selectedAlert = nil
        }
        // SwiftData는 별도의 save() 없이 자동으로 변경 사항을 처리합니다.
        print("Bus alert \(busAlert.alertLabel) deleted.")
    }
}
