
// 전체 몸통
// 전국용 버스 정보창
// 서울용 버스 정보창

// 전국용 버스 스크롤창
// 서울용 버스 스크롤창

// 공용으로 쓰는 리스트

// 알람 화면

import SwiftUI
import SwiftData
import Combine
struct UsingAlertView: View {
    @StateObject var viewModel = NowBusLocationViewModel()
    @Query var busStops: [BusStopLocal]
    @Environment(\.dismiss) private var dismiss
    @State var busAlert: BusAlert // 관련된 알림 정보


    @State private var showExitConfirmation = false
    @State private var positionIndex: Int = 1 // ScrollTo 변수
    @Binding var alertStop: BusStopLocal? // alertStop을 상태로 관리
    @State private var isScrollTriggered: Bool = false
    @State private var isFinishedLoading: Bool = false
    
    
    var EndAlertLottie = LottieManager(filename: "AlarmLottie", loopMode: .loop)
    
    
    @State private var liveActivityManager: LiveActivityManager? = nil
    @State private var isNotificationRunning = false // 알림 실행 상태
    
    @State var filteredBusStops: [BusStopLocal] = [] // 필터링된 정류장 저장소
    @State var timer: Timer? = nil
    
    
    var body: some View {
        ZStack {
//            Color.whiteDBlack
//                .ignoresSafeArea()
            
            VStack {
                
                if busAlert.cityCode != 1 {
                    
                    ZStack{
                        // 상단 네모박스 정보 뷰
                        
                        
                        // 노션뷰
                        BusStopScrollView(
                            viewModel: viewModel,
                            filteredBusStops: filteredBusStops,
                            busAlert: busAlert,
                            alertStop: alertStop,
                            isScrollTriggered: $isScrollTriggered
                        )
                        .edgesIgnoringSafeArea(.bottom)
                        VStack{
                            BusAlertInfoView(
                                viewModel: viewModel,
                                busAlert: busAlert,
                                alertStop: alertStop,
                                isScrollTriggered: $isScrollTriggered,
                                isNotificationRunning: $isNotificationRunning,
                                timer: $timer
                                
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            Spacer()
                        
                        }
                    }
                } else {
                    ZStack{
                        SeoulBusStopScrollView(
                            viewModel: viewModel,
                            filteredBusStops: filteredBusStops,
                            busAlert: busAlert,
                            alertStop: alertStop,
                            isScrollTriggered: $isScrollTriggered
                        )
                        .edgesIgnoringSafeArea(.bottom)
                        VStack{
                            SeoulBusAlertInfoView(
                                viewModel: viewModel,
                                filteredBusStops: filteredBusStops,
                                busAlert: busAlert,
                                alertStop: alertStop,
                                isScrollTriggered: $isScrollTriggered,
                                isNotificationRunning: $isNotificationRunning,
                                timer: $timer
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            Spacer()
                            
                        }
                    }
                }
            }
            

            
            // 알람종료 오버레이 뷰
        if isNotificationRunning == true {
            AfterAlertView()
                .toolbar(.hidden) // 알람종료 뷰에서는 툴바 숨기기
        }
            
        }
        .onDisappear {
            LiveActivityManager.shared.endLiveActivity()
        }

        .navigationBarBackButtonHidden()
        .navigationTitle(busAlert.alertLabel ?? "알람")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // x 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.showExitConfirmation.toggle();
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.gray1Dgray6)
//                    Text("즉시 종료")
//                        .font(.system(size: 12))
//                        .padding(4)
//                    .foregroundStyle(.whiteasset)
//                    .background(
//                        Capsule()
//                            .fill(.red) // 배경색을 brand로 설정
//                    )
                })
            }
        }
        .alert("알람 종료", isPresented: $showExitConfirmation) {
            Button("종료", role: .destructive) {
                // 알림 취소
                NotificationManager.shared.stopNotifications()
                isNotificationRunning = false
                LiveActivityManager.shared.endLiveActivity()
                viewModel.stopUpdatingBusLocation()
                dismiss() // Dismiss the view if confirmed
                stopAutoUpdating()
                LocationManager.shared.stopLocationUpdates()

            }
            Button("취소", role: .cancel){}
        } message: {
            Text("알람을 종료하시겠습니까?")
        }
        .onAppear {
            if busAlert.cityCode != 1 {
                viewModel.startUpdatingBusLocation(cityCode: Int(busAlert.cityCode), routeId: busAlert.routeid, nodeOrd: busAlert.arrivalBusStopNord)
            } else {
                viewModel.startUpdatingSeoulBusLocation(routeId: busAlert.routeid, sectOrd: busAlert.arrivalBusStopNord)
            }
            

            if filteredBusStops.isEmpty {
                filteredBusStops = busStops
                    .filter { $0.routeid == busAlert.routeid }
                    .sorted(by: { $0.nodeord < $1.nodeord })
            }
            
            LocationManager.shared.startLocationUpdates()

                
        }
        .onDisappear {
            LiveActivityManager.shared.endLiveActivity()
            viewModel.stopUpdatingBusLocation()
            stopAutoUpdating()
            LocationManager.shared.stopLocationUpdates()
            
        }
    }
    
    // 뷰가 사라질 때 타이머를 정리하는 함수
    func stopAutoUpdating() {
        timer?.invalidate()  // 타이머 중지
        timer = nil
    }
    
    
    /// 시간 포맷팅 함수
    func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일 설정
        formatter.dateFormat = "a h:mm" // 오전/오후 h:mm 형식
        return formatter.string(from: date)
    }
    
    struct BusAlertInfoView: View {
        @StateObject var viewModel: NowBusLocationViewModel
        let busAlert: BusAlert
        let alertStop: BusStopLocal? // 알림 정류장
        @State var refreshButtonLottie = LottieManager(filename: "refreshLottie", loopMode: .playOnce)
        @Binding var isScrollTriggered: Bool // 스크롤하게 하는 트리거
        @Binding var isNotificationRunning: Bool
        @Binding var timer: Timer?
        
        var body: some View {
            ZStack {
                if let closestBus = viewModel.closestBusLocation {
                    Rectangle()
                        .fill(.gray7DGray1)
                        .opacity(0.8)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        // 버스 정보
                        HStack(spacing: 5) {
                            Image(systemName: "square.fill")
                                .foregroundStyle(busColor(for: busAlert.routetp))
                                .frame(width: 12, height: 12)
                            
                            Text("\(busAlert.busNo)")
                                .font(.caption2)
                                .foregroundStyle(.gray3Dgray6)
                            
                            Rectangle()
                                .frame(width: 2, height: 8)
                                .foregroundStyle(.gray3Dgray6)
                            
                            Text(busAlert.arrivalBusStopNm)
                                .font(.caption2)
                                .foregroundStyle(.gray3Dgray6)
                            
                        }.padding(.bottom, 20)
                        
                        // 현재 위치 정보
                            Text(getPreviousStopCount())
                                .font(.title2)
                                .foregroundStyle(.blackDGray7)
                                .padding(.bottom, 10)
                            
                            Text("현재 정류장은")
                                .font(.caption1)
                                .foregroundStyle(.gray1Dgray6)
                            HStack(spacing: 2){
                                Text("\(closestBus.nodenm)")
                                    .font(.caption1)
                                    .foregroundStyle(.brand)
                                Text("입니다.")
                                    .font(.caption1)
                                    .foregroundStyle(.gray1)
                                    .onAppear {
                                        let currentDate = Date()  // 현재 시간을 가져옵니다.
                                        
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "HH:mm:ss"  // 원하는 시간 포맷을 지정합니다.
                                        let formattedTime = formatter.string(from: currentDate)
                                        
                                        LiveActivityManager.shared.startLiveActivity(title: busAlert.alertLabel ?? "알 수 없는 알람" , description: busAlert.busNo, stationName: busAlert.arrivalBusStopNm, initialProgress: 99, currentStop: closestBus.nodenm, stopsRemaining: busAlert.arrivalBusStopNord - (Int(closestBus.nodeord) ?? 0), Updatetime: formattedTime)
                                        
                                        startAutoUpdating()
                                    }
                                // 타이머로 5초마다 업데이트
                            }
                        
                        //새로고침 시간, 새로고침 버튼
                        HStack(spacing: 8){
                            Spacer()
                            refreshButtonLottie
                                .frame(width: 24, height: 24)
                                .onTapGesture {
                                    // 새로고침 로직 실행
                                    isScrollTriggered = true // 스크롤 트리거 활성화
                                    // 애니메이션 제어
                                    refreshButtonLottie.stop() // 버튼 클릭 시 기존 애니메이션 멈춤
                                    refreshButtonLottie.play() // 버튼 클릭 시 새 애니메이션 실행
                                    // 햅틱 피드백 (진동 효과) 트리거
                                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                                        HapticManager.shared.triggerImpactFeedback(style: .medium) // 중간 강도의 햅틱 효과 실행
                                    }
                                }
                        }
                        .padding(.trailing, 4)
                    }
                    .padding(.horizontal ,24)
                } else {
                    NoBussignalView()
                }
            }
        }
        
        // 몇 정류장 전 버스인지 표시
        func getPreviousStopCount() -> String{
            guard let closestBus = viewModel.closestBusLocation else {
                return "운행 중인 버스를 다시 조회해주세요"
            }
            
            // 남은 정류장 수가 +인 경우
            if busAlert.arrivalBusStopNord - (Int(closestBus.nodeord) ?? 0) >= busAlert.alertBusStop {
                return "목적지까지 \(busAlert.arrivalBusStopNord - (Int(closestBus.nodeord) ?? 0)) 정류장 남았습니다."
            }
            
            // 남은 정류장 수가 -인 경우
            if busAlert.arrivalBusStopNord - (Int(closestBus.nodeord) ?? 0) < busAlert.alertBusStop {
                return "목적지로부터 \(-(busAlert.arrivalBusStopNord - (Int(closestBus.nodeord) ?? 0))) 정류장 지났습니다."
            }
            
            return "새로고침 해주세요"
        }
        
        //자동으로 상태 업데이트
           func startAutoUpdating() {
               timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                   // closestBus 정보를 다시 가져오기 (가정: 최신 위치를 가져오기 위해 호출)
                   guard let closestBus = viewModel.closestBusLocation else {
                       return
                   }
                   
                   if busAlert.arrivalBusStopNord - (Int(closestBus.nodeord) ?? 0) == busAlert.alertBusStop {
                       triggerNotification()
                       
                   }
                  
                   
                   if let correctedStop = validateAndFixCoordinates(latitude: alertStop?.gpslati ?? 0,
                                                                    longitude: alertStop?.gpslong ?? 0) {
                       if LocationManager.shared.BusstopWithGPS(latitude: correctedStop.latitude,
                                                                longitude: correctedStop.longitude) {
                           print("이게 울리는거임?")
                           triggerNotification()
                       } else {print(LocationManager.shared.BusstopWithGPS(latitude: correctedStop.latitude,
                                                                           longitude: correctedStop.longitude))}
                   }
                   func validateAndFixCoordinates(latitude: Double, longitude: Double) -> (latitude: Double, longitude: Double)? {
                       // 위도와 경도가 올바른지 확인 (대한민국 기준 위도: 약 33~38, 경도: 약 124~132)
                       if latitude >= 33, latitude <= 38, longitude >= 124, longitude <= 132 {
                           return (latitude, longitude) // 유효한 경우 그대로 반환
                       } else if longitude >= 33, longitude <= 38, latitude >= 124, latitude <= 132 {
                           return (longitude, latitude) // 뒤바뀐 경우 수정 후 반환
                       }
                       
                       return nil // 유효하지 않은 경우 nil 반환
                   }
                   
                   // 현재 시간을 업데이트
                   let currentDate = Date()
                   let formatter = DateFormatter()
                   formatter.dateFormat = "HH:mm:ss"
                   let formattedTime = formatter.string(from: currentDate)
                   
                   // 라이브 액티비티 업데이트
                   LiveActivityManager.shared.updateLiveActivity(
                       progress: 1.0,  // 진행률을 항상 1로 설정
                       currentStop: closestBus.nodenm,
                       stopsRemaining: busAlert.arrivalBusStopNord - (Int(closestBus.nodeord) ?? 0),
                       Updatetime: formattedTime
                   )
               }
           }
        func triggerNotification() {
            isNotificationRunning = true
            SoundManager.shared.loadAudioFile(named: "AlarmSound") // 파일 로드
            SoundManager.shared.play(loopCount: -1) // 무한 반복 재생
            NotificationManager.shared.startNotifications(
                title: "핫챠",
                subtitle: "\(busAlert.arrivalBusStopNm)까지 \(busAlert.alertBusStop) 정류장 전입니다!"
            )
        }

    }
    
    struct SeoulBusAlertInfoView: View {
        @StateObject var viewModel: NowBusLocationViewModel
        let filteredBusStops: [BusStopLocal] // 버스 정류장 목록
        let busAlert: BusAlert
        let alertStop: BusStopLocal? // 알림 정류장
        @State var refreshButtonLottie = LottieManager(filename: "refreshLottie", loopMode: .playOnce)
        @Binding var isScrollTriggered: Bool // 스크롤하게 하는 트리거
        @Binding var isNotificationRunning: Bool
        @Binding var timer: Timer?
        
        var body: some View {
            ZStack {
                if let closestBus = viewModel.closestSeoulBusLocation {
                Rectangle()
                    .fill(.gray7DGray1)
                    .opacity(0.8)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                
                VStack(alignment: .leading, spacing: 3) {
                    // 버스 정보
                    HStack(spacing: 5) {
                        Image(systemName: "square.fill")
                            .foregroundStyle(busColor(for: busAlert.routetp))
                            .frame(width: 12, height: 12)
                        
                        Text("\(busAlert.busNo)")
                            .font(.caption2)
                            .foregroundStyle(.gray3Dgray6)
                        
                        Rectangle()
                            .frame(width: 2, height: 8)
                            .foregroundStyle(.gray3Dgray6)
                        
                        Text(busAlert.arrivalBusStopNm)
                            .font(.caption2)
                            .foregroundStyle(.gray3Dgray6)
                    }.padding(.bottom, 20)
                    
                    // 현재 위치 정보
                        Text(getSeoulPreviousStopCount())
                            .font(.title2)
                            .foregroundStyle(.blackDGray7)
                            .padding(.bottom, 10)
                        
                        Text("현재 정류장은")
                            .font(.caption1)
                            .foregroundStyle(.gray1Dgray6)
                        HStack(spacing: 2){
                            if let matchingStop = filteredBusStops.first(where: { $0.nodeid == closestBus.lastStnId }) {
                                Text("\(matchingStop.nodenm)")
                                    .font(.caption1)
                                    .foregroundStyle(.brand)
                            }
                            Text("입니다.")
                                .font(.caption1)
                                .foregroundStyle(.gray1)
                                .onAppear {
                                    let currentDate = Date()  // 현재 시간을 가져옵니다.
                                    
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "HH:mm:ss"  // 원하는 시간 포맷을 지정합니다.
                                    let formattedTime = formatter.string(from: currentDate)
                                    
                                    LiveActivityManager.shared.startLiveActivity(title: busAlert.alertLabel ?? "알 수 없는 알람" , description: busAlert.busNo, stationName: busAlert.arrivalBusStopNm, initialProgress: 99, currentStop: filteredBusStops.first(where: { $0.nodeid == closestBus.lastStnId })?.nodenm ?? "", stopsRemaining: busAlert.arrivalBusStopNord - (Int(closestBus.sectOrd) ?? 0), Updatetime: formattedTime)
                                    
                                    startAutoUpdating()
                                }
                            
                        }
                    
                    //새로고침 시간, 새로고침 버튼
                    HStack(spacing: 8){
                        Spacer()
                        refreshButtonLottie
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                // 새로고침 로직 실행
                                isScrollTriggered = true // 스크롤 트리거 활성화
                                // 애니메이션 제어
                                refreshButtonLottie.stop() // 버튼 클릭 시 기존 애니메이션 멈춤
                                refreshButtonLottie.play() // 버튼 클릭 시 새 애니메이션 실행
                                // 햅틱 피드백 (진동 효과) 트리거
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    HapticManager.shared.triggerImpactFeedback(style: .medium) // 중간 강도의 햅틱 효과 실행
                                }
                            }
                    }
                    .padding(.trailing, 4)
                }
                .padding(.horizontal ,24)
            }  else {
                NoBussignalView()
            }
            }
        }
        
        // 몇 정류장 전 버스인지 표시(서울)
        func getSeoulPreviousStopCount() -> String{
            guard let closestBus = viewModel.closestSeoulBusLocation else {
                return "운행 중인 버스를 다시 조회해주세요"
            }
            
//            closestBus.
            // 남은 정류장 수가 +인 경우
            if busAlert.arrivalBusStopNord - (Int(closestBus.sectOrd) ?? 0) >= busAlert.alertBusStop {
                return "목적지까지 \(busAlert.arrivalBusStopNord - (Int(closestBus.sectOrd) ?? 0)) 정류장 남았습니다."
            }
            
            // 남은 정류장 수가 -인 경우
            if busAlert.arrivalBusStopNord - (Int(closestBus.sectOrd) ?? 0) < busAlert.alertBusStop {
                return "목적지로부터 \(-(busAlert.arrivalBusStopNord - (Int(closestBus.sectOrd) ?? 0))) 정류장 지났습니다."
            }
            
            return "새로고침 해주세요"
        }
        
        //자동으로 상태 업데이트
           func startAutoUpdating() {
               timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                   // closestBus 정보를 다시 가져오기 (가정: 최신 위치를 가져오기 위해 호출)
                   guard let closestBus = viewModel.closestSeoulBusLocation else {
                       return
                   }
                   
                   if busAlert.arrivalBusStopNord - (Int(closestBus.sectOrd) ?? 0) == busAlert.alertBusStop {
                       print(busAlert.arrivalBusStopNord - (Int(closestBus.sectOrd) ?? 0),busAlert.alertBusStop,"확인")
                       triggerNotification()
                   }
                   
                   print(alertStop?.nodenm)
                   if let correctedStop = validateAndFixCoordinates(latitude: alertStop?.gpslati ?? 0,
                                                                    longitude: alertStop?.gpslong ?? 0) {
                       if LocationManager.shared.BusstopWithGPS(latitude: correctedStop.latitude,
                                                                longitude: correctedStop.longitude) {
                           print("이게 울리는거임?")
                           triggerNotification()
                       }
                   }
                   func validateAndFixCoordinates(latitude: Double, longitude: Double) -> (latitude: Double, longitude: Double)? {
                       // 위도와 경도가 올바른지 확인 (대한민국 기준 위도: 약 33~38, 경도: 약 124~132)
                       if latitude >= 33, latitude <= 38, longitude >= 124, longitude <= 132 {
                           return (latitude, longitude) // 유효한 경우 그대로 반환
                       } else if longitude >= 33, longitude <= 38, latitude >= 124, latitude <= 132 {
                           return (longitude, latitude) // 뒤바뀐 경우 수정 후 반환
                       }
                       
                       return nil // 유효하지 않은 경우 nil 반환
                   }
                   
                   // 현재 시간을 업데이트
                   let currentDate = Date()
                   let formatter = DateFormatter()
                   formatter.dateFormat = "HH:mm:ss"
                   let formattedTime = formatter.string(from: currentDate)
                   
                   print(busAlert.arrivalBusStopNord - (Int(closestBus.sectOrd) ?? 0)  - Int(busAlert.alertBusStop))
                   // 라이브 액티비티 업데이트
                   LiveActivityManager.shared.updateLiveActivity(
                       progress: 1.0,  // 진행률을 항상 1로 설정
                       currentStop: filteredBusStops.first(where: { $0.nodeid == closestBus.lastStnId })?.nodenm ?? "",
                       stopsRemaining: busAlert.arrivalBusStopNord - (Int(closestBus.sectOrd) ?? 0),
                       Updatetime: formattedTime
                   )
               }
           }
        func triggerNotification() {
            isNotificationRunning = true
            SoundManager.shared.loadAudioFile(named: "AlarmSound") // 파일 로드
            SoundManager.shared.play(loopCount: -1) // 무한 반복 재생
            NotificationManager.shared.startNotifications(
                title: "핫챠",
                subtitle: "\(busAlert.arrivalBusStopNm)까지 \(busAlert.alertBusStop) 정류장 전입니다!"
            )
        }
           

    }
    
    // BusStopList가 포함된 ScrollView
    struct BusStopScrollView: View {
        @StateObject var viewModel: NowBusLocationViewModel
        let filteredBusStops: [BusStopLocal] // 버스 정류장 목록
        let busAlert: BusAlert // 버스 알림 정보
        let alertStop: BusStopLocal? // 알림 정류장
        @Binding var isScrollTriggered: Bool // 스크롤하게 하는 트리거
        
        var body: some View {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // 가장 가까운 버스가 감지 되었을 경우
                        if let closestBus = viewModel.closestBusLocation {
                            let maxNodeord = filteredBusStops.last?.nodeord // 마지막 정류장의 nodeord
                            Rectangle()
                                .frame(height: 230)
                                .opacity(0)
                                
                            ForEach(filteredBusStops, id: \.id) { busStop in
                                BusStopRow(
                                    busStop: busStop,
                                    isCurrentLocation: busStop.nodeid == closestBus.nodeid,
                                    arrivalBusStopID: busAlert.arrivalBusStopID,
                                    alertStop: alertStop,
                                    isLastBusStop: busStop.nodeord == maxNodeord, // 현재 정류장의 nodeord가 최대값과 같은지 비교
                                    alertLabel: busAlert.alertLabel,
                                    vehId: closestBus.vehicleno
                                )
                            }
                        }
                    }
                }
                // 해당 버스 노드 위치로 스크롤하는 에니메이션
                .onChange(of: isScrollTriggered) { value in
                    if value {
                        if let location = viewModel.closestBusLocation {
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                withAnimation(.smooth) {
                                    proxy.scrollTo(location.nodeid, anchor: .center)
                                }
                            }
                        }
                        isScrollTriggered = false
                    }
                }
            }
        }
    }
    
    // BusStopList가 포함된 ScrollView
    struct SeoulBusStopScrollView: View {
        @StateObject var viewModel: NowBusLocationViewModel
        let filteredBusStops: [BusStopLocal] // 버스 정류장 목록
        let busAlert: BusAlert // 버스 알림 정보
        let alertStop: BusStopLocal? // 알림 정류장
//        @StateObject private var viewModel = NowBusLocationViewModel()
        @Binding var isScrollTriggered: Bool // 스크롤하게 하는 트리거
        
        var body: some View {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // 가장 가까운 버스가 감지 되었을 경우
                        if let closestBus = viewModel.closestSeoulBusLocation {
//                            let filteredBusStops = busStops.filter { $0.routeid == busAlert.routeid }
//                                .sorted(by: { $0.nodeord < $1.nodeord })
                            let maxNodeord = filteredBusStops.last?.nodeord // 마지막 정류장의 nodeord
                            Rectangle()
                                .frame(height: 230)
                                .opacity(0)
                            
                            ForEach(filteredBusStops, id: \.id) { busStop in
                                BusStopRow(
                                    busStop: busStop,
                                    isCurrentLocation: busStop.nodeid == closestBus.lastStnId,
                                    arrivalBusStopID: busAlert.arrivalBusStopID,
                                    alertStop: alertStop,
                                    isLastBusStop: busStop.nodeord == maxNodeord, // 현재 정류장의 nodeord가 최대값과 같은지 비교
                                    alertLabel: busAlert.alertLabel,
                                    vehId: closestBus.plainNo
                                )
                            }
                            
                        }
                    }

                }
                // 해당 버스 노드 위치로 스크롤하는 에니메이션
                .onChange(of: isScrollTriggered) { value in
                    if value {
                        if let location = viewModel.closestSeoulBusLocation {
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                withAnimation(.smooth) {
                                    proxy.scrollTo(location.lastStnId, anchor: .center)
                                }
                            }
                        }
                        isScrollTriggered = false
                    }
                }
            }
        }
    }
    

    
    // BusStop 리스트
    struct BusStopRow: View {
        let busStop: BusStopLocal  // BusStop을 BusStopLocal로 변경
        let isCurrentLocation: Bool
        let arrivalBusStopID: String
        let alertStop: BusStopLocal?
        let isLastBusStop: Bool
        let alertLabel: String? // 추가된 busAlertLabel
        let vehId: String?
        
        var body: some View {
            HStack {
                if isCurrentLocation {
                    Image("tagComponent")
                        .padding(.leading, 8)
                        .id(busStop.nodeid)
                        .overlay{
                            Text("현위치")
                                .font(.caption2)
                                .foregroundStyle(.brand)
                        }
                } else {
                    Image("tagComponent")
                        .opacity(0)
                        .padding(.leading, 8)
                }
                VStack {
                    if busStop.nodeord == 1 {
                        Image("Line_FirstBusStop")
                    } else if busStop.nodeid == arrivalBusStopID {
                        Image("Line_EndBusStop")
                            .padding(.leading, -3)
                    } else if busStop.nodeid == alertStop?.nodeid {
                        Image("Line_AlertBusStop")
                            .padding(.leading, -4)
                    } else if isCurrentLocation {
                        Image("Line_CurrentBusStop")
                            .padding(.leading, -3)
                    } else if isLastBusStop {
                        Image("Line_LastBusStop")
                    }
                    else {
                        Image("Line_NormalBusStop")
                    }
                }
                VStack(alignment: .leading){
                    Text(busStop.nodenm)
                       
                        .foregroundStyle(.gray1Dgray6)
                        .font(isCurrentLocation || busStop.nodeid == arrivalBusStopID || busStop.nodeid == alertStop?.nodeid ? .body1 : .caption1)

                }
                .padding(.leading, 20)
                if isCurrentLocation {
                    VStack {
                        Text(vehId ?? "버스 정보 없음")
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
            }
//            .frame(height: busStop.nodeid == alertStop?.nodeid ? 88 : 60)
            .frame(height: 60)
            .background(busStop.nodeid == arrivalBusStopID || busStop.nodeid == alertStop?.nodeid ? .gray7DGray1 : .whiteDRealBlack)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // 새로고침 버튼 뷰
    struct RefreshButton: View {
        let isRefreshing: Bool
        @Binding var isScrollTriggered: Bool
        var action: () -> Void
            
            var body: some View {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: action) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                                .padding()
                                .background(Color.black)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        .disabled(isRefreshing)
                        .padding()
                }
            }
        }
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    // 알람 비활성화 뷰
//    @ViewBuilder
//    func AfterAlertView() -> some View {
//        ZStack {
//            Image("AfterAlertViewBG")
//                .resizable()
//                .ignoresSafeArea()
//            
//            // 둥근 모서리의 반투명한 직사각형과 텍스트
//            VStack {
//                EndAlertLottie
//                    .scaleEffect(2.8) // 크기 조절
//                
//                Button(action: {
//                    NotificationManager.shared.stopNotifications()
//                    SoundManager.shared.stop()
//                    isNotificationRunning = false
//                    viewModel.stopUpdatingBusLocation()
//                    stopAutoUpdating()
//                    dismiss()
//                    LocationManager.shared.stopLocationUpdates()
//                    
//                }, label: {
//                    Text("알람 종료")
//                        .frame(width: 133, height: 49)
//                        .foregroundStyle(.white)
//                        .font(.title2)
//                        .background(RoundedRectangle(cornerRadius: 8).fill(.blackDBrand))
//                    
//                })
//                .padding(.bottom, 48)
//                
//            }
//            .background(
//                Image("AfterAlertRectangle")
//                    .resizable()
//                    .frame(maxWidth: .infinity, maxHeight: 500)
//            )
//            .padding(.horizontal, 20)
//            .padding(.top, 120)
//            .padding(.bottom, 150)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .onDisappear {
//        }
//        .onAppear {
//            EndAlertLottie.play()
//        }
//    }
//    
    @ViewBuilder
    func AfterAlertView() -> some View {
        ZStack {
            // 전체 배경을 반투명 검은색으로 설정
            Color.black.opacity(0.9)
                .ignoresSafeArea() // 배경이 화면 전체를 덮도록 설정
            
                // 캡슐 모양의 중단 버튼
                Button(action: {
                    NotificationManager.shared.stopNotifications()
                    SoundManager.shared.stop()
                    isNotificationRunning = false
                    viewModel.stopUpdatingBusLocation()
                    stopAutoUpdating()
                    dismiss()
                    LocationManager.shared.stopLocationUpdates()
                }, label: {
                    Text("알람 종료")
                        .frame(height: 50)
                        .foregroundColor(.white) // 브랜드 색상으로 텍스트 색상 설정
                        .font(.title2)
                        .padding(.horizontal, 40) // 캡슐 크기 조절
                        .background(Capsule().fill(Color.brand)) // 반투명 배경을 가진 캡슐 버튼

                })
                .padding(.top)


        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
