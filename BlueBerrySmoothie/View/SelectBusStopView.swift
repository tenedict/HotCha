
// 버스 정류장 선택하는 뷰입니다.
import SwiftUI
import SwiftData

struct SelectBusStopView: View {
    //    let city: City // 도시 정보
    let bus: Bus // 선택된 버스 정보
    let cityCode: Int // ← 추가된 부분
    @Binding var busStopAlert: BusStopAlert?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var busStopViewModel: BusStopViewModel
    @StateObject private var busStopSeoulviewModel = BusStopSeoulViewModel()
    @State private var stop: String = ""
    @State private var isAutoScroll: Bool = false // 상행 하행 버튼과 스크롤로 이동될 때의 action이 중복되지 않도록 방지하는 변수
    @Binding var showSelectBusSheet: Bool
    @State private var isAnimating = false // 버스 리스트가 아래에서 위로 올라오는 애니메이션 실행 여부
    
    var body: some View {
        VStack{
            HStack {
                Text("\(bus.routeno)")
                    .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 0))
                Spacer()
                Image("magnifyingglass")
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 20.67)
            }
            .background(.gray6Dgray2)
            .cornerRadius(20)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray5Dgray3, lineWidth: 1)
            }
            .padding(EdgeInsets(top: 44, leading: 0, bottom: 24, trailing: 0))
            
            VStack {
                HStack {
                    directionView(
                        directionName: "\(bus.endnodenm)방면", // 상행
                        isSelected: true,
                        selectedColor: .brand,
                        unselectedColor: .gray5Dgray3
                    )
                    .onTapGesture {

                        isAutoScroll = true // 버튼을 누르면 자동으로 해당 위치로 스크롤 되도록함
                    }
                    
                    directionView(
                        directionName: "\(bus.startnodenm)방면", // 하행
                        isSelected: true,
                        selectedColor: .brand,
                        unselectedColor: .gray5Dgray3
                    )
                    .onTapGesture {
                      
                        isAutoScroll = true // 버튼을 누르면 자동으로 해당 위치로 스크롤 되도록함
                    }
                }
                
                
                if cityCode != 1 {
                    //BusStop 리스트 View
                    BusStopScrollView()
                } else {
                    SeoulBusStopScrollView()
                }
                
                
                
                
            }
            // 버스 리스트가 아래에서 위로 올라오는 애니메이션 위치
            .offset(y: isAnimating ? 0 : UIScreen.main.bounds.height)
        }
        // 버스 리스트가 아래에서 위로 올라오는 애니메이션
        .animation(.spring(duration: 1.0, bounce: 0.1), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
        .padding(.horizontal, 20)
        .navigationTitle("버스 검색")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 닫기 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.body1)
                        Text("뒤로")
                            .font(.body2)
                            .padding(.leading, -7)
                    }
                    .foregroundStyle(.gray1DBrand)
                }
            }
        }
        .toolbarBackground(Color(.whiteDgray1), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            if cityCode == 1 {
                await busStopSeoulviewModel.fetchBusStations(routeid: bus.routeid)
                print(busStopSeoulviewModel.fetchBusStations(routeid: bus.routeid),"테스트 프린트")
            } else {
                await busStopViewModel.getBusStopData(cityCode: cityCode, routeId: bus.routeid)
            }
        }
        .background(.whiteDgray1)
        .background(ignoresSafeAreaEdges: .horizontal)
    }
    
    /// Bus List 뷰
    private func BusStopScrollView() -> some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                ForEach(busStopViewModel.busStopList, id: \.nodeord) { busstop in
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            HapticManager.shared.triggerImpactFeedback(style: .medium)
                        }
                        storeBusStop(busStop: busstop)
                        print(busstop.nodenm)
                        showSelectBusSheet = false
                    }) {
                        VStack {
                            Spacer()
                            HStack {
                                Text("\(busstop.nodenm)")
                                    .padding(.leading, 24)
                                    .foregroundStyle(.gray1Dgray6)
                                
                                Spacer()
                            }
                            Spacer()
                            Divider()
                        }
                        .frame(height: 60)
                        .backgroundStyle(.whiteDgray1)
                    }
                    .id(busstop.nodeid) // 각 정류장에 고유 ID를 설정
                }
            }
         
        }
    }
    
    /// Bus List 뷰
    private func SeoulBusStopScrollView() -> some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                ForEach(busStopSeoulviewModel.busStations, id: \.nodeord) { busstop in
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            HapticManager.shared.triggerImpactFeedback(style: .medium)
                        }
                        print(busstop)
                        storeSeoulBusStop(busStop: busstop)
                        print(busstop)
                        showSelectBusSheet = false
                    }) {
                        VStack {
                            Spacer()
                            HStack {
                                Text("\(busstop.nodenm)")
                                    .padding(.leading, 24)
                                    .foregroundStyle(.gray1Dgray6)
                                
                                Spacer()
                            }
                            Spacer()
                            Divider()
                        }
                        .frame(height: 60)
                        .backgroundStyle(.whiteDgray1)
                    }
//                    .id(busstop.nodeid) // 각 정류장에 고유 ID를 설정
                }
            }
            .onAppear{
                print(busStopSeoulviewModel.busStations,"온어피어 프린트")
            }
         
        }
    }
    
    
    
    
    // 최상단으로 스크롤하는 함수
    private func scrollToTop(proxy: ScrollViewProxy) {
        if let firstStop = busStopViewModel.busStopList.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.smooth) {
                    proxy.scrollTo(firstStop.nodeid, anchor: .top)
                }
            }
        }
    }
    
    // 하행의 첫 인덱스로 스크롤하는 함수
//    private func scrollToMiddle(proxy: ScrollViewProxy, completion: @escaping () -> Void) {
//        // 하행의 가장 작은 order 구함
//        if let minDownwardNodeord = busStopViewModel.busStopList.filter({ $0.updowncd == 1 }).map({ $0.nodeord }).min() {
//            //해당 order로 스크롤을 이동함
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                withAnimation(.smooth) {
//                    proxy.scrollTo(minDownwardNodeord, anchor: .center)
//                    completion()
//                }
//            }
//        }
//    }
    
//    private func handleScrollChange(midY: CGFloat) {
//        let screenHeight = UIScreen.main.bounds.height
//        let centerY = screenHeight / 3 * 2
//        
//        if midY > centerY && updowncdselection != 1 && isAutoScroll == false {
//            updowncdselection = 1 // 중앙 아래
//            HapticManager.shared.triggerImpactFeedback(style: .light)
//        } else {
//            if midY < centerY && updowncdselection != 2 && isAutoScroll == false  { // updowncdselection의 상태가 변경될 때만 실행,
//                updowncdselection = 2 // 중앙 위
//                HapticManager.shared.triggerImpactFeedback(style: .light)
//            }
//        }
//    }
    
    // 버스 정류장 데이터 저장
    func storeBusStop(busStop: BusStop){
        busStopAlert = BusStopAlert(cityCode: Double(cityCode), bus: bus, allBusStop: busStopViewModel.busStopList, arrivalBusStop: busStop, alertBusStop: 0)

        // 이전 정류장 (1~3번째) 저장
        if var unwrappedBusStopAlert = busStopAlert {
            storeBeforeBusStops(for: busStop, alert: &unwrappedBusStopAlert, busStops: busStopViewModel.busStopList)
            busStopAlert = unwrappedBusStopAlert
        }

    }
    // 버스 정류장 데이터 저장
    func storeSeoulBusStop(busStop: BusStop){
        busStopAlert = BusStopAlert(cityCode: Double(cityCode), bus: bus, allBusStop: busStopSeoulviewModel.busStations, arrivalBusStop: busStop, alertBusStop: 0)

        // 이전 정류장 (1~3번째) 저장
        if var unwrappedBusStopAlert = busStopAlert {
            storeBeforeBusStops(for: busStop, alert: &unwrappedBusStopAlert, busStops: busStopSeoulviewModel.busStations)
            busStopAlert = unwrappedBusStopAlert
        }

    }

    
    private func directionView(directionName: String, isSelected: Bool, selectedColor: Color, unselectedColor: Color) -> some View {
        VStack {
            HStack {
                Spacer()
                Text(directionName)
                    .foregroundColor(isSelected ? .gray1Dgray7 : .gray3Dgray4)
                Spacer()
            }
            Spacer()
            Rectangle()
                .foregroundStyle(isSelected ? selectedColor : unselectedColor)
                .frame(height: isSelected ? 2 : 1)
        }
        .frame(height: 25)
    }
    
    // 차고지 - 회차지가 있는 일반적인 경우를 예외 처리하여 이전 3 정류장을 저장한다
    private func storeBeforeBusStops(for busStop: BusStop, alert: inout BusStopAlert, busStops: [BusStop]) {
        
        if busStop.nodeord > 2000 {
            // `nodeord`를 기준으로 이전 정류장을 찾는 함수
            func findBusStop(withNodeord targetNodeord: Int) -> BusStop? {
                return busStops.first { $0.nodeord == targetNodeord }
            }

            // 각각의 이전 정류장을 nodeord 값으로 찾기
            alert.firstBeforeBusStop = findBusStop(withNodeord: busStop.nodeord - 1)
            alert.secondBeforeBusStop = findBusStop(withNodeord: busStop.nodeord - 2)
            alert.thirdBeforeBusStop = findBusStop(withNodeord: busStop.nodeord - 3)
        } else if busStop.nodeord > 1000 {
            let currentIndex: Int = busStop.nodeord - 1000
            print("currentIndex: \(currentIndex)")
            alert.firstBeforeBusStop = currentIndex > 1 ? busStops[currentIndex - 2] : nil
            alert.secondBeforeBusStop = currentIndex > 2 ? busStops[currentIndex - 3] : nil
            alert.thirdBeforeBusStop = currentIndex > 3 ? busStops[currentIndex - 4] : nil
        } else {
            let currentIndex: Int = busStop.nodeord
            alert.firstBeforeBusStop = currentIndex > 1 ? busStops[busStop.nodeord - 2] : nil
            alert.secondBeforeBusStop = currentIndex > 2 ? busStops[busStop.nodeord - 3] : nil
            alert.thirdBeforeBusStop = currentIndex > 3 ? busStops[busStop.nodeord - 4] : nil
        }
        // 이전 정류장을 최대 3개까지 저장함
        // nodeord가 1부터 시작해서 n+1 만큼 빼주어야함

       
        
    }
}

