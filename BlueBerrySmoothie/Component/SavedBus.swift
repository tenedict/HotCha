//
//
import SwiftUI

struct SavedBus: View {
    let busStopLocals: [BusStopLocal]
    let busAlert: BusAlert?
    var isSelected: Bool = false
    var onDelete: () -> Void // 삭제 핸들러
    let createdAt: Date?
    
    @StateObject private var locationManager = LocationManager.shared
    
    @State private var alertShowing = false
    @State private var isEditing: Bool = false
    @State private var isPinned: Bool = false
    @State private var isUsingAlertActive: Bool = false
    @State private var alertStop: BusStopLocal?
    
    @State private var destinationView: AnyView? = nil
    
    var body: some View {
        HStack{
            VStack {
                //알람 이름 , 메뉴버튼
                HStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.lightbrand)
                            .cornerRadius(4)
                        Text(busAlert?.alertLabel ?? "알림")
                            .font(.caption2)
                            .padding(4)
                            .foregroundColor(Color.brand)
                    }
                    .fixedSize(horizontal: true, vertical: true)
                    .padding(.top, 9)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            // 수정
                            isEditing = true
                        }, label: {
                            Label("수정", image: "pencil")
                        })
                        
                        Button(action: {
                            // 상단 고정
                            busAlert?.isPinned.toggle()
                            isPinned = busAlert?.isPinned ?? false
                        }, label: {
                            Label(busAlert?.isPinned == true ? "상단 고정 해제" : "상단 고정", image: "pin")
                        })
                        
                        Button(role: .destructive, action: {
                            // 삭제
                            alertShowing = true
                        }, label: {
                            Label("삭제", image: "trash")
                        })
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundColor(Color.gray3Dgray6)
                            .padding(5)
                    }
                }
                .padding(.top, 7)
                .padding(.bottom, 5)
                .padding(.horizontal, 20)
                
                // 버스 번호, 정류장
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.fill")
                            .frame(width: 12, height: 12)
                            .foregroundStyle(busColor(for: busAlert?.routetp ?? ""))
                        Text(busAlert?.busNo ?? "버스번호없음")
                            .font(.title1)
                            .foregroundStyle(.blackdgray71)
                        // 고정핀 위치
                        if busAlert?.isPinned == true {
                            Image("pin")
                                .foregroundColor(.gray1Dgray6)
                                .font(.title2)
                        }
                        Spacer()
                    }
                    HStack {
                        Text(busAlert?.arrivalBusStopNm ?? "도착정류장")
                            .font(.title2)
                            .foregroundStyle(.blackdgray71)
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundColor(Color.gray2)
                        Text("\(busAlert!.alertBusStop) 정류장 전")
                            .font(.caption1)
                            .foregroundColor(Color.gray2)
                        Spacer()
                    }
                }
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                Spacer()
                
                HStack {
                    NavigationLink(destination: destinationView) {
                        HStack {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .background(Color.white)
                                    .cornerRadius(30)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.gray5, lineWidth: 1)
                                    }
                                HStack {
                                    Image(systemName: "play.fill")
                                        .font(.caption2)
                                        .foregroundColor(.grayfix1)
                                    Text("시작하기")
                                        .font(.caption2)
                                        .foregroundColor(.black)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                            }
                            .fixedSize(horizontal: true, vertical: true)
                        }
                    }
                    Spacer()
                }
                .cornerRadius(16)
                .padding(.bottom, 16)
                .padding(.top, 5)
                .padding(.horizontal, 20)
            }
            .cornerRadius(16)
            .background{
                //                Image(busAlertBackground(for: busAlert?.routetp ?? ""))
                //                    .resizable()
                //                    .frame(maxWidth: .infinity, maxHeight: .infinity) // 크기를 최대한 늘림
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .cornerRadius(16)
//                    .shadow(radius: 2)
                
            }
        }
                .contextMenu { // HStack 전체를 꾹 눌렀을 때 메뉴 표시
        
                    Button(action: {
                        isEditing = true
                    }) {
                        Label("수정", systemImage: "pencil")
                    }
        
                    Button(action: {
                        busAlert?.isPinned.toggle()
                        isPinned = busAlert?.isPinned ?? false
                    }) {
                        Label(busAlert?.isPinned == true ? "상단 고정 해제" : "상단 고정", systemImage: "pin")
                    }
        
                    Button(role: .destructive, action: {
                        alertShowing = true
                    }) {
                        Label("삭제", systemImage: "trash")
                    }
                }
            .padding(.top, 8)
            .sheet(isPresented: $isEditing) {
                NavigationView{
                    AlertSettingMain(busAlert: busAlert, isEditing: true) // `busAlert`을 `AlertSettingMain`으로 전달
                }
            }
            .alert("알람 삭제", isPresented: $alertShowing) {
                Button("삭제", role: .destructive) {
                    onDelete()
                }
                Button("취소", role: .cancel){}
            } message: {
                Text("알람을 삭제하시겠습니까?")
            }
            .onAppear {
                       // NavigationLink가 나타날 때 destination 설정
                       if let busAlert = busAlert,
                          let foundStop = findAlertBusStop(busAlert: busAlert, busStops: busStopLocals) {
                           // destinationView에 적절한 뷰를 설정
                           if busAlert.cityCode == 1 {
                               print(busAlert.alertBusStop)
                               print(busAlert.busNo)
                               print(busAlert.routeid)
                               print(busAlert.arrivalBusStopID)
                               print(busAlert.arrivalBusStopNm)
                               print(busAlert.arrivalBusStopNord)
                               print(busAlert.alertBusStop)
                               print(busAlert.alertLabel)
                               print(busAlert.routetp)
                               print("++++++++++++++++++++")
                               destinationView = AnyView(UsingAlertView(busAlert: busAlert, alertStop: .constant(foundStop)))
                           } else {
                               destinationView = AnyView(UsingAlertView(busAlert: busAlert, alertStop: .constant(foundStop)))
                           }
                       } else {
                           destinationView = AnyView(Text("정보를 찾을 수 없습니다."))
                       }
                   }
    }

    // MARK: - 정류장 찾는 함수
    private func findAlertBusStop(busAlert: BusAlert, busStops: [BusStopLocal]) -> BusStopLocal? {
        // busAlert의 routeid와 일치하는 busStops만 필터링
        let filteredStops = busStops.filter { $0.routeid == busAlert.routeid }
        
        // 필터링된 배열에서 첫 번째 nodeid와 일치하는 BusStopLocal 찾기
        if let firstStop = filteredStops.first(where: { $0.nodeid == busAlert.arrivalBusStopID }) {
            // 첫 번째 정류장의 nordord 값을 이용해서 차이 계산
            let nordordDifference = firstStop.nodeord - busAlert.alertBusStop
            
            print(filteredStops.first { $0.nodeord == nordordDifference })
            // nordordDifference 값으로 새로운 정류장을 찾기
            return filteredStops.first { $0.nodeord == nordordDifference }
        }
        
        return nil // 해당하는 정류장이 없다면 nil 반환
    }
    
}



//import SwiftUI
//
//struct SavedBus: View {
//    let busStopLocals: [BusStopLocal]
//    let busAlert: BusAlert?
//    var isSelected: Bool = false
//    var onDelete: () -> Void // 삭제 핸들러
//    let createdAt: Date?
//
//    @StateObject private var locationManager = LocationManager.shared
//    
//    @State private var alertShowing = false
//    @State private var isEditing: Bool = false
//    @State private var isPinned: Bool = false
//    @State private var isUsingAlertActive: Bool = false
//    @State private var alertStop: BusStopLocal?
//
//    @State private var destinationView: AnyView? = nil
//
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .foregroundColor(.whiteasset)
//                .cornerRadius(10)
//            
//            HStack(alignment: .top) {
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text(busAlert?.busNo ?? "버스 번호 없음")
//                            .font(.title)
////                            .font(.largeTitle)
////                            .padding(.bottom, 2)
//                        if busAlert?.isPinned == true {
//                            Image(systemName: "pin.fill")
//                                .foregroundStyle(.gray)
//                        }
//                    }
//                    Text(busAlert?.arrivalBusStopNm ?? "도착 정류장")
//                        .font(.title3)
//                        .padding(.bottom, 4)
//                        .foregroundStyle(.gray)
//                    
//                    Text(busAlert?.alertLabel ?? "알림")
//                        .font(.caption)
//                }
//                Spacer()
//                VStack(alignment: .trailing) {
//                    Spacer()
//                    NavigationLink(destination: destinationView) {
////                        Text("시작")
//                        Image(systemName: "arrow.forward")
//                            .font(.title2 )
//                            .padding(.horizontal, 20) // 좌우 여백
//                            .padding(.vertical, 20)  // 상하 여백
//                            .background(
//                                Circle()
//                                    .fill(Color("brand")) // 배경색을 brand로 설정
//                          
//                            )
//                            .foregroundColor(.white) // 텍스트 색상 설정
//
//                                }
//
//                    Spacer()
//                }
//            }
//            .background(Color.white.opacity(0))
//            .padding(.horizontal, 16)
//            .padding(.vertical, 6)
//            
//            
//            .alert("알람 삭제", isPresented: $alertShowing) {
//                Button("삭제", role: .destructive) {
//                    onDelete()
//                }
//                Button("취소", role: .cancel){}
//            } message: {
//                Text("알람을 삭제하시겠습니까?")
//            }
//            .onAppear {
//                if let busAlert = busAlert,
//                   let foundStop = findAlertBusStop(busAlert: busAlert, busStops: busStopLocals) {
//                    destinationView = AnyView(UsingAlertView(busAlert: busAlert, alertStop: .constant(foundStop)))
//                } else {
//                    destinationView = AnyView(Text("정보를 찾을 수 없습니다."))
//                }
//            }
//        }
//        .cornerRadius(10)
//        .contextMenu { // HStack 전체를 꾹 눌렀을 때 메뉴 표시
//            
//            Button(action: {
//                isEditing = true
//            }) {
//                Label("수정", systemImage: "pencil")
//            }
//            
//            Button(action: {
//                busAlert?.isPinned.toggle()
//                isPinned = busAlert?.isPinned ?? false
//            }) {
//                Label(busAlert?.isPinned == true ? "상단 고정 해제" : "상단 고정", systemImage: "pin")
//            }
//            
//            Button(role: .destructive, action: {
//                alertShowing = true
//            }) {
//                Label("삭제", systemImage: "trash")
//            }
//        }
//        .sheet(isPresented: $isEditing) {
//            NavigationView {
//                AlertSettingMain(busAlert: busAlert, isEditing: true) // `busAlert`을 `AlertSettingMain`으로 전달
//            }
//        }
//    }
//
//    // MARK: - 정류장 찾는 함수
//    private func findAlertBusStop(busAlert: BusAlert, busStops: [BusStopLocal]) -> BusStopLocal? {
//        let filteredStops = busStops.filter { $0.routeid == busAlert.routeid }
//        
//        if let firstStop = filteredStops.first(where: { $0.nodeid == busAlert.arrivalBusStopID }) {
//            let nordordDifference = firstStop.nodeord - busAlert.alertBusStop
//            return filteredStops.first { $0.nodeord == nordordDifference }
//        }
//        
//        return nil
//    }
//}
