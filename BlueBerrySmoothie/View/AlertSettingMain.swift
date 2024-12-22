import SwiftUI
import SwiftData

// 여기도 상당히 많은 코드들이 있는데요
// 여기는 정리가 잘 안되어 있습니다.

//// AlertSettingMain 뷰
//struct AlertSettingMain: View {
//    // 환경 변수: ModelContext 및 Dismiss 기능 가져오기
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.dismiss) private var dismiss
//    
//    // 쿼리로 가져오는 BusStopLocal 데이터
//    @Query var busStopLocal: [BusStopLocal]
//    
//    // 알람 편집 시 사용하는 busAlert
//    var busAlert: BusAlert?
//    var isEditing: Bool = false // Edit 모드 여부 확인 변수
//    
//    // 상태 변수: 초기값 설정
//    @State private var label: String = "" // 알람 이름
//    @State private var selectedStation: String = "정류장 수" // 선택된 정류장 수
//    @State private var cityCodeInput: String = "21" // 초기 도시 코드
//    @State private var cityNameInput: String = "부산" // 초기 도시 이름
//    @State private var showSelectBusSheet: Bool = false // SelectBusView를 표시할지 여부
//    @State private var busStopAlert: BusStopAlert? // 사용자 선택 사항 저장
//    @State private var showSheet: Bool = false // "몇 정거장 전" 선택 Sheet 관리
//    @State private var showToast = false // 토스트 메시지 상태
//    @State private var toastMessage = "" // 토스트 메시지 내용
//    @State private var selectedField: Int? = nil // 선택된 필드 추적 (1: 버스/종착지, 2: 정류장, 3: 알람 이름)
//    @FocusState private var isFieldFocused: Bool // TextField 활성화 여부 확인
//    @State private var confirmSaveButton: Bool = false // 저장 버튼 활성화 여부
//    @State private var isSelectCitySheetPresented = false // 도시 선택 Sheet 상태
//    @State private var selectedCity: City = City(id: "1", category: "없음", name: "선택된 도시 없음", consonant: "ㅋ") // 선택된 도시 데이터
//    @State private var savedCityName: String = "" // 저장된 도시 이름
//    
//    // 초기화 메서드
//    init(busAlert: BusAlert? = nil, isEditing: Bool? = nil) {
//        self.busAlert = busAlert
//        self.isEditing = isEditing ?? false
//    }
//    
//    var body: some View {
//        VStack {
//            VStack {
//                // ------------------------------------------------
//                // 지역 선택 UI
//                Rectangle()
//                    .foregroundColor(.clear)
//                    .frame(height: 64)
//                    .background(.gray7DGray1)
//                    .cornerRadius(20)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 20)
//                            .stroke(.gray5, lineWidth: 1)
//                    )
//                    .overlay(
//                        HStack {
//                            Text("지역")
//                                .font(.body2) // 텍스트 스타일
//                            Spacer()
//                            if isEditing == false {
//                                // 도시 선택 버튼
//                                Button(action: { isSelectCitySheetPresented = true }) {
//                                    Text("\(selectedCity.name)")
//                                        .font(.body2)
//                                        .foregroundStyle(.blackasset)
//                                }
//                            } else {
//                                // 수정 모드일 경우 비활성화
//                                Text("\(selectedCity.name)")
//                                    .font(.body2)
//                                    .foregroundStyle(.gray3Dgray3)
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                    )
//                    .padding(.vertical, 10)
//                
//                
//                //----------------------------------------------------------------------------------------------
//                
//                // 버스 및 종착지 선택 UI
//                VStack(alignment: .trailing, spacing: 12) {
//                    HStack {
//                        settingLabel(text: "버스 및 종착지") // 라벨
//                        astrickImage() // * 아이콘
//                        Spacer()
//                        Text(busStopAlert?.bus.routeno ?? "버스 번호")
//                            .font(.body2)
//                            .foregroundColor(busStopAlert?.bus.routeno != nil && isEditing == false ? .blackDGray7 : .gray3Dgray3)
//                            .padding(.trailing, 20)
//                            .onTapGesture {
//                                loadCityCode()
//                                if isEditing == false {
//                                    selectedField = 1
//                                    showSelectBusSheet = true
//                                } else {
//                                    showToastMessage("버스 및 종착지는 수정할 수 없어요")
//                                }
//                            }
//                    }.padding(.vertical, 10)
//                    Divider()
//                        .padding(.horizontal, 12)
//                        .padding(.top, -10)
//                    
//                    
//                    // 정류장 이름 표시
//                    Text(busStopText)
//                        .foregroundColor(busStopAlert?.arrivalBusStop.nodenm != nil && isEditing == false ? .blackDGray7 : .gray3Dgray3)
//                        .font(.body2)
//                        .padding(.trailing, 20)
//                        .onTapGesture {
//                            if isEditing == false {
//                                selectedField = 1
//                                showSelectBusSheet = true
//                                hideKeyboard()
//                            } else {
//                                showToastMessage("버스 및 종착지는 수정할 수 없어요")
//                            }
//                        }
//                }
//                .padding(.vertical, 10)
//                .background(.gray7DGray1)
//                .cornerRadius(20)
//                .overlay {
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(selectedField == 1 && isFieldFocused == false ? .brand : .gray5Dgray3, lineWidth: 1)
//                }
//                .sheet(isPresented: $showSelectBusSheet) {
//                    SelectBusView(cityCode: Int(cityCodeInput) ?? 21, busStopAlert: $busStopAlert, showSelectBusSheet: $showSelectBusSheet)
//                }
//                .sheet(isPresented: $isSelectCitySheetPresented) {
//                    SelectCityView(selectedCity: $selectedCity)
//                }
//                //----------------------------------------------------------------------------------------------
//                // 일어날 정류장 선택 UI
//                HStack {
//                    settingLabel(text: "일어날 정류장")
//                    astrickImage()
//                    Spacer()
//                    Text("\(selectedStation)")
//                        .foregroundColor(selectedStation != "정류장 수" ? .blackDGray7 : .gray3Dgray3)
//                        .font(.body2)
//                        .padding(.trailing, 20)
//                        .onTapGesture {
//                            selectedField = 2
//                            showSheet = true
//                            hideKeyboard()
//                        }
//                }
//                .frame(height: 64)
//                .background(.gray7DGray1)
//                .cornerRadius(20)
//                .overlay {
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(selectedField == 2 && isFieldFocused == false ? .brand : .gray5Dgray3, lineWidth: 1)
//                }
//                .padding(.vertical, 10)
//                .onAppear {
//                    loadCityCode()
//                    if busStopAlert?.alertBusStop == 0 {
//                        selectedStation = "정류장 수"
//                    }
//                    if let busAlert = busAlert {
//                        label = busAlert.alertLabel ?? "알람"
//                        selectedStation = "\(busAlert.alertBusStop) 정류장 전 알람"
//                        busStopAlert = BusStopAlert(
//                            cityCode: busAlert.cityCode,
//                            bus: Bus(routeno: busAlert.busNo, routeid: busAlert.routeid),
//                            allBusStop: [],
//                            arrivalBusStop: BusStop(nodeid: busAlert.arrivalBusStopID, nodenm: busAlert.arrivalBusStopNm),
//                            alertBusStop: busAlert.alertBusStop
//                        )
//                    }
//                }
//                .sheet(isPresented: $showSheet) {
////                    StationPickerModal(isPresented: $showSheet, selectedStation: "", alert: BusStopAlert?, nodeord: busStopAlert?.arrivalBusStop.nodeord)
//                    StationPickerModal(isPresented: $showSheet, selectedStation: $selectedStation, alert: $busStopAlert, nodeord: busAlert?.arrivalBusStopNord ?? 0, onDismiss: {
//                                      selectedField = nil })
//                }
//                //----------------------------------------------------------------------------------------------
//                // 알람 이름 입력 필드
//                HStack {
//                    settingLabel(text: "알람 이름")
//                    Spacer()
//                    TextField("알람", text: $label, prompt: Text("알람").foregroundColor(.gray3Dgray3))
//                        .multilineTextAlignment(.trailing)
//                        .foregroundStyle(label.isEmpty ? .gray3Dgray3 : .blackDGray7)
//                        .font(.body2)
//                        .focused($isFieldFocused)
//                        .padding(.trailing, 20)
//                }
//                .frame(height: 64)
//                .background(.gray7DGray1)
//                .cornerRadius(20)
//                .overlay {
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(selectedField == 3 || isFieldFocused ? .brand : .gray5Dgray3, lineWidth: 1)
//                }
//                
//                Spacer()
//            }
//            .padding(20)
//            Spacer()
//        }
//        .onTapGesture {
//            hideKeyboard()
//            selectedField = nil
//            isFieldFocused = false
//        }
//        .overlay {
//                   if showSheet {
//                       StationPickerModal(isPresented: $showSheet, selectedStation: $selectedStation, alert: $busStopAlert, nodeord: busAlert?.arrivalBusStopNord ?? 0, onDismiss: {
//                           selectedField = nil })
//                   } else {
//                       EmptyView()
//                   }
//               }
//        
//        .toolbar {
//            ToolbarItem {
//                Button(action: {
//                    if isInputValid() {
//                        saveOrUpdateAlert()
//                        saveBusstop()
//                        dismiss()
//                    } else {
//                        showToastMessage("몇 정거장 전에 알람이 울릴지 선택해주세요")
//                    }
//                }) {
//                    Text("저장")
//                        .font(.body)
//                        .foregroundColor(confirmSaveButton ? .brand : .gray3Dgray3)
//                }
//            }
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: { dismiss() }) {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.gray1Dgray6)
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//        .toast(isShowing: $showToast, message: toastMessage)
//    }
//    
//    // MARK: - Helper Methods
//    
//    // 라벨 설정 뷰
//    func settingLabel(text: String) -> some View {
//        Text(text)
//            .font(.body2)
//            .foregroundColor(.gray1Dgray6)
//            .padding(.leading, 20)
//    }
//    
//    // * 아이콘 뷰
//    func astrickImage() -> some View {
//        Image("asterisk")
//            .foregroundColor(.brand)
//            .bold()
//            .padding(.leading, -6)
//    }
//    
//    // 선택한 버스 정류장 텍스트 반환
//    var busStopText: String {
//        guard let busStop = busStopAlert?.arrivalBusStop.nodenm else {
//            return "하차 정류장"
//        }
//        return busStop
//    }
//    
//    // 입력값 유효성 검사
//    private func isInputValid() -> Bool {
//        return selectedStation != "정류장 수" && busStopAlert?.bus != nil && busStopAlert?.arrivalBusStop != nil
//    }
//    
//    // 토스트 메시지 표시
//    private func showToastMessage(_ message: String) {
//        toastMessage = message
//        showToast = true
//    }
//    
//    // 알람 저장 또는 업데이트 함수
//    private func saveOrUpdateAlert() {
//        if isEditing {
//            busAlert?.alertLabel = label.isEmpty ? "알람" : label
//            busAlert?.alertBusStop = busStopAlert?.alertBusStop ?? 3
//        } else {
//            saveAlert()
//        }
//    }
//    
//    // 키보드 숨김 메서드
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//    
//    // 새로운 알람 저장
//    private func saveAlert() {
//        guard let selectedBus = busStopAlert?.bus,
//              let selectedBusStop = busStopAlert?.arrivalBusStop else { return }
//        
//        let cityCode = Int(cityCodeInput) ?? -1
//        guard cityCode > 0 else { return }
//        
//        let newAlert = BusAlert(
//            id: UUID().uuidString,
//            cityCode: Double(cityCode),
//            busNo: selectedBus.routeno,
//            routeid: selectedBus.routeid,
//            arrivalBusStopID: selectedBusStop.nodeid,
//            arrivalBusStopNm: selectedBusStop.nodenm,
//            arrivalBusStopNord: selectedBusStop.nodeord,
//            alertBusStop: busStopAlert!.alertBusStop,
//            alertLabel: label.isEmpty ? "알람" : label,
//            alertSound: true,
//            alertHaptic: true,
//            alertCycle: nil,
//            routetp: selectedBus.routetp
//        )
//        try? modelContext.insert(newAlert)
//    }
//    
//    // 도시 코드 로드
//    private func loadCityCode() {
//        let savedCityID = UserDefaults.standard.string(forKey: "CityCodeKeyID") ?? "1"
//        let savedCityName = UserDefaults.standard.string(forKey: "CityCodeKeyName") ?? "선택된 도시 없음"
//        selectedCity = City(id: savedCityID, category: "없음", name: savedCityName, consonant: "ㅋ")
//        cityCodeInput = savedCityID
//        cityNameInput = savedCityName
//    }
//    
//    // 선택한 버스 정류장 리스트 저장
//    private func saveBusstop() {
//        guard !(busStopAlert?.allBusStop.isEmpty ?? true) else { return }
//        if busStopLocal.contains(where: { $0.routeid == busStopAlert?.bus.routeid }) { return }
//        for busStop in busStopAlert!.allBusStop {
//            let newBusStopLocal = BusStopLocal(
//                id: UUID().uuidString,
//                routeid: busStop.routeid,
//                nodeid: busStop.nodeid,
//                nodenm: busStop.nodenm,
//                nodeno: busStop.nodeno,
//                nodeord: busStop.nodeord,
//                gpslati: busStop.gpslati,
//                gpslong: busStop.gpslong
//            )
//            try? modelContext.insert(newBusStopLocal)
//        }
//    }
//}
//
//// 미리보기 설정
//#Preview {
//    AlertSettingMain()
//}
// AlertSettingMain 뷰
struct AlertSettingMain: View {
    @Environment(\.modelContext) private var modelContext // ModelContext를 가져옴
    @Environment(\.dismiss) private var dismiss
    @Query var busStopLocal: [BusStopLocal]
    
    var busAlert: BusAlert? // 편집을 위한 busAlert 매개변수 추가
    var isEditing: Bool = false // Edit 모드인지 구분
    
    // 초기화 데이터들
    @State private var label: String = ""
    @State private var selectedStation: String = "정류장 수"
    
    // 설정된 cityCode 가져오기
    @State private var cityCodeInput: String = "21"
    @State private var cityNameInput: String = "부산"
    
    @State private var showSelectBusSheet: Bool = false // SelectBusView를 sheet로 표시할지 여부
    @State private var busStopAlert: BusStopAlert? // 사용자 선택 사항
    @State private var showSheet: Bool = false // 몇 번째 전 정거장 선택 sheet 관리
    
    // 토스트 메시지 상태 변수
    @State private var showToast = false
    @State private var toastMessage = ""
    
    // 활성 비활성 색 변경을 위해 선택된 필드를 추적 / 버스 및 종착지:1, 일어날 정류장:2, 알람 이름:3, 해당안될 시 nil
    @State private var selectedField: Int? = nil
    // TextField는 selectedField로 활성 비활성 구분이 안돼서선택되었는지 상태 확인
    @FocusState private var isFieldFocused: Bool
    @State private var confirmSaveButton: Bool = false
    
    @State private var isSelectCitySheetPresented = false // Sheet 상태 관리
    @State private var selectedCity: City = City(id: "1", category: "없음", name: "선택된 도시 없음", consonant: "ㅋ") // 선택된 도시 저장
    @State private var savedCityName: String = ""
    
    init(busAlert: BusAlert? = nil, isEditing: Bool? = nil) {
        self.busAlert = busAlert
        self.isEditing = isEditing ?? false
        
    }
    
    var body: some View {
        VStack {
            VStack {
//                HStack {
//                    Text("알람 설정")
//                        .font(.title2)
//                        .foregroundColor(.blackDGray7)
//                    Spacer()
//                }
//                .padding(.bottom, 8)
//
//                HStack {
//                    Text("종착지에 도착하기 전에 깨워드려요")
//                        .font(.caption1)
//                        .foregroundColor(.gray3Dgray6)
//                    Spacer()
//                }
//                .padding(.bottom, 32)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 64)
                    .background(.gray7DGray1)
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
                            if isEditing == false {
 
                                Button(action:{isSelectCitySheetPresented = true}) {
                                    Text("\(selectedCity.name)")
                                        .font(.body2)
                                        .foregroundStyle(.blackasset)
                                }
                            } else {
                                Text("\(selectedCity.name)")
                                    .font(.body2)
                                    .foregroundStyle(.gray3Dgray3)
                            }
                            
                        }
                            .padding(.horizontal, 20)
                    ).padding(.vertical, 10)
                
                
                VStack(alignment:.trailing, spacing: 12) {
                    
                    
                    HStack() {
                        // 입력할 내용 라벨
                        settingLabel(text: "버스 및 종착지")
                        // * 아이콘
                        astrickImage()
                        
                        Spacer()
                        
                        // 선택된 버스 번호 표시
                        Text(busStopAlert?.bus.routeno ?? "버스 번호")
                            .font(.body2)
                            .foregroundColor(busStopAlert?.bus.routeno != nil && isEditing == false ? .blackDGray7 : .gray3Dgray3)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0,trailing: 20))
                            .onTapGesture {
                                loadCityCode()
                                if isEditing != true {
                                    selectedField = 1
                                    showSelectBusSheet = true
                                } else {
                                    showToastMessage("버스 및 종착지는 수정할 수 없어요")
                                }
                            }
                    }
                    Divider()
                        .padding(.horizontal, 12)
                        .padding(.top, -10)
                    
                    // 버스 정류장 이름 표시
                    Text(busStopText)                        .foregroundColor(busStopAlert?.arrivalBusStop.nodenm != nil && isEditing == false ? .blackDGray7 : .gray3Dgray3)
                        .font(.body2)
                        .padding(EdgeInsets(top: 2, leading: 0, bottom: 22, trailing: 20))
                        .onTapGesture {
                            if isEditing != true {
                                selectedField = 1 // stroke 활성화/비활성화 색
                                showSelectBusSheet = true
                                hideKeyboard() // 키보드 숨김
                            } else {
                                showToastMessage("버스 및 종착지는 수정할 수 없어요")
                            }
                        }
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(.gray7DGray1)
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedField == 1 && isFieldFocused != true ? .brand : .gray5Dgray3, lineWidth: 1)
                }
                .sheet(isPresented: $showSelectBusSheet, onDismiss: {
                    selectedField = nil  // sheet가 닫힐 때 초기화
                }) { // ← 수정된 부분
                    SelectBusView(cityCode: Int(cityCodeInput) ?? 21, busStopAlert: $busStopAlert, showSelectBusSheet: $showSelectBusSheet)
                }
                .sheet(isPresented: $isSelectCitySheetPresented) {
                    // sheet에 전달할 데이터를 binding으로 전달
                    SelectCityView(selectedCity: $selectedCity) // 데이터를 @Binding으로 전달
                }
                
                
                
                // 일어날 정류장 선택
                HStack() {
                    // 입력할 내용 라벨
                    settingLabel(text: "일어날 정류장")
                    // * 아이콘
                    astrickImage()
                    
                    Spacer()
                    
                    Text("\(selectedStation)")
                        .foregroundColor(selectedStation != "정류장 수" ? .blackDGray7 : .gray3Dgray3)
                        .font(.body2)
                        .padding(EdgeInsets(top: 22, leading: 20, bottom: 22, trailing: 20))
                        .onTapGesture {
                             // stroke 활성화/비활성화 색
                            if busStopAlert?.arrivalBusStop != nil {
                                selectedField = 2
                                showSheet = true
                            } else {
                                showToastMessage("버스와 종착지를 선택해주세요")
                            }
                            hideKeyboard() // 키보드 숨김
                        }
                }
                .background(.gray7DGray1)
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedField == 2 && isFieldFocused != true ? .brand : .gray5Dgray3, lineWidth: 1)
                }
                .padding(.vertical, 10)
                
                // 알람 이름 입력 필드
                HStack(alignment: .center) {
                    // 입력할 내용 라벨
                    settingLabel(text: "알람 이름")
                    
                    Spacer()
                    
                    TextField("알람", text: $label, prompt: Text("알람").foregroundColor(.gray3Dgray3))
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(label == "" ? .gray3Dgray3 : .blackDGray7)
                        .font(.body2)
                        .focused($isFieldFocused) // stroke 색 변경을 위한 활성 비활성 구분
                        .padding(EdgeInsets(top: 22, leading: 20, bottom: 22, trailing: 20))
                }
                .background(.gray7DGray1)
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedField == 3 || isFieldFocused ? .brand : .gray5Dgray3, lineWidth: 1)
                }
                Spacer()
            }
            .padding(20)
            Spacer()
        }
        .onTapGesture {
            hideKeyboard() // 키보드 숨김
            selectedField = nil // 선택된 영역 초기화
            isFieldFocused = false // textField 선택된 영역 초기화
        }
        .onAppear {
            loadCityCode()
            // 이전 정류장 수 선택이 안되어있는 경우
            if busStopAlert?.alertBusStop == 0 {
                selectedStation = "정류장 수"
            }
            // 수정인 경우
            if let busAlert = busAlert {
                // busAlert 데이터로 초기 상태 설정
                label = busAlert.alertLabel ?? "알람"
                selectedStation = "\(busAlert.alertBusStop) 정류장 전 알람"
                
                busStopAlert = BusStopAlert(
                    cityCode: busAlert.cityCode,
                    bus: Bus(routeno: busAlert.busNo, routeid: busAlert.routeid),
                    allBusStop: [],
                    arrivalBusStop: BusStop(nodeid: busAlert.arrivalBusStopID, nodenm: busAlert.arrivalBusStopNm),
                    alertBusStop: busAlert.alertBusStop
                )
            }
        }
        .onChange(of: selectedStation){
            if selectedStation != "정류장 수" {
                confirmSaveButton = true
            } else {
                confirmSaveButton = false
            }
        }
        .onChange(of: busStopAlert?.arrivalBusStop) {
            if (isEditing != true) {
                selectedStation = "정류장 수"
            }
        }
        .overlay {
            if showSheet {
                StationPickerModal(isPresented: $showSheet, selectedStation: $selectedStation, alert: $busStopAlert, nodeord: busAlert?.arrivalBusStopNord ?? 0, onDismiss: {
                    selectedField = nil })
            } else {
                EmptyView()
            }
        }
        .toolbar {
            // 저장 버튼
            ToolbarItem {
                Button(action: {
                    if isInputValid() {
                        saveOrUpdateAlert()
                        saveBusstop()
                        dismiss()
                    } else {
                        showToastMessage("몇 정거장 전에 알람이 울릴지 선택해주세요")
                    }
                }) {
                    Text("저장")
                        .font(.body)
                        .foregroundColor(confirmSaveButton ? .brand : .gray3Dgray3)
                }
            }
            // 닫기 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()  // 현재 화면을 닫는 동작
                }) {
                    Image(systemName: "xmark")
                        .frame(width: 19.2, height: 19.2)
                        .foregroundColor(.gray1Dgray6) // 원하는 색상으로 변경 가능
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toast(isShowing: $showToast, message: toastMessage)
    }
    
    func settingLabel(text: String) -> some View {
        Text("\(text)")
            .font(.body2)
            .foregroundColor(.gray1Dgray6)
            .padding(EdgeInsets(top: 22, leading: 20, bottom: 22, trailing: 0))
    }
    
    func astrickImage() -> some View {
        Image("asterisk")
            .foregroundColor(Color.brand)
            .bold()
            .padding(.leading, -6)
    }
    
    // 선택한 버스 정류장 텍스트 표시
    var busStopText: String {
        guard let busStop = busStopAlert?.arrivalBusStop.nodenm else {
            return "하차 정류장"
        }
        
//        let direction = busStopAlert?.routeDirection
//        let hasDirection = !(direction?.isEmpty ?? true)
//
//        if hasDirection {
//            return "\(busStop) (\(direction!)방면)"
//        }
        
        return busStop
    }
    
    private func isInputValid() -> Bool {
        return selectedStation != "정류장 수" && busStopAlert?.bus != nil && busStopAlert?.arrivalBusStop != nil
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
    }
    
    // 알람 저장 함수
    private func saveOrUpdateAlert() {
        // 기존 알람 수정
        if isEditing == true {
            // 기존 busAlert 업데이트
            busAlert?.alertLabel = ( label == "" ? "알람" : label )
            busAlert?.alertBusStop = busStopAlert?.alertBusStop ?? 3
            // 추가 필드 업데이트
            print("알람이 업데이트되었습니다.")
        } else {
            // 새 알림을 저장 (편집 모드가 아닌 경우)
            saveAlert()
        }
    }
    
    // 키보드 숨김 메서드
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // 새 알림 저장 함수
    private func saveAlert() {
        guard let selectedBus = busStopAlert?.bus,
              let selectedBusStop = busStopAlert?.arrivalBusStop else {
            print("버스와 정류장을 선택하세요.")
            return
        }
        
        var selectedAlertBusStop: BusStop?
        
        if busStopAlert!.alertBusStop == 1 {
            guard let alertBusStop = busStopAlert?.firstBeforeBusStop else {
                print("다시")
                return
            }
            selectedAlertBusStop = alertBusStop
        } else if busStopAlert!.alertBusStop == 2 {
            guard let alertBusStop = busStopAlert?.secondBeforeBusStop else {
                print("다시")
                return
            }
            selectedAlertBusStop = alertBusStop
        } else {
            guard let alertBusStop = busStopAlert?.thirdBeforeBusStop else {
                print("다시")
                return
            }
            selectedAlertBusStop = alertBusStop
        }
        
        // Ensure selectedAlertBusStop is non-nil before proceeding
        guard let finalAlertBusStop = selectedAlertBusStop else {
            print("알람 정류장 선택 오류")
            return
        }
        
        
        let cityCode = Int(cityCodeInput) ?? -1 // 도시 코드 유효성 확인
        guard cityCode > 0 else {
            print("유효한 도시 코드를 입력하세요.")
            showToastMessage("유효한 도시 코드를 입력하세요.")
            return
        }
        
        // 알람 객체 생성
        let newAlert = BusAlert(
            id: UUID().uuidString,
            cityCode: Double(cityCode), // 사용자가 입력한 도시 코드
            busNo: selectedBus.routeno,
            routeid: selectedBus.routeid,
            arrivalBusStopID: selectedBusStop.nodeid,
            arrivalBusStopNm: selectedBusStop.nodenm,
            arrivalBusStopNord: selectedBusStop.nodeord,
            alertBusStop: busStopAlert!.alertBusStop,
            alertLabel: label == "" ? "알람" : label,
            alertSound: true,
            alertHaptic: true,
            alertCycle: nil,
            routetp: selectedBus.routetp
        )
        
        // 데이터베이스에 저장
        do {
            try modelContext.insert(newAlert)
            print("알람이 저장되었습니다.")
        } catch {
            print("알람 저장 실패: \(error)")
        }
    }
    
//    private func loadCityCode() {
//        let savedCityID = UserDefaults.standard.string(forKey: "CityCodeKeyID") ?? "1"
//        let savedCityName = UserDefaults.standard.string(forKey: "CityCodeKeyName") ?? "선택된 도시 없음"
//        cityCodeInput = savedCityID
//        cityNameInput = savedCityName
//    }
    private func loadCityCode() {
        let savedCityID = UserDefaults.standard.string(forKey: "CityCodeKeyID") ?? "1"
        let savedCityName = UserDefaults.standard.string(forKey: "CityCodeKeyName") ?? "선택된 도시 없음"
        selectedCity = City(id: savedCityID, category: "없음", name: savedCityName, consonant: "ㅋ")
        cityCodeInput = savedCityID
        cityNameInput = savedCityName
    }
    
    
    
    
    // 선택한 버스의 정류장 List 저장 함수 - UsingAlertView에서 정류장 노선을 띄우는데 사용됨
    private func saveBusstop() {
        guard !(busStopAlert?.allBusStop.isEmpty)! else {
            print("버스를 선택하세요.")
            return
        }
        
        let routeExists = busStopLocal.contains { existingBusStop in
            existingBusStop.routeid == busStopAlert?.bus.routeid
        }
        
        if routeExists {
            print("routeid \(busStopAlert?.bus.routeid ?? "알 수 없음")이 이미 존재합니다. 저장하지 않았습니다.")
            return
        }
        
        for busStop in busStopAlert!.allBusStop {
            let newBusStopLocal = BusStopLocal(
                id: UUID().uuidString,
                routeid: busStop.routeid,
                nodeid: busStop.nodeid,
                nodenm: busStop.nodenm,
                nodeno: busStop.nodeno,
                nodeord: busStop.nodeord,
                gpslati: busStop.gpslati,
                gpslong: busStop.gpslong
            )
            
            do {
                try modelContext.insert(newBusStopLocal)
                //                print("버스 정류장이 저장되었습니다.")
            } catch {
                print("버스 정류장 저장 실패: \(error)")
            }
        }
    }
}

#Preview {
    AlertSettingMain()
}
