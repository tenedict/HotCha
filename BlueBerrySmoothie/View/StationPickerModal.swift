// 정류장 선택

//alertsettingmain에서 몇정류장에 알람울릴지 선택하는 모달

import SwiftUI

struct StationPickerModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedStation: String
    @Binding var alert: BusStopAlert? // BusStopAlert 값을 받아옴
    @State var nodeord: Int
    var onDismiss: (() -> Void)?  // 선택이 완료되어서 모달창이 닫히면 alertSettingMain에서 selectedField = nil을 실행해주기 위함
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack {
                    HStack {
                        Text("알람이 울릴 정류장 선택")
                            .foregroundColor(.blackDGray7)
                            .font(.body2)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                        Spacer()
                    }
                    
                    Divider()
                        .foregroundColor(.gray5Dgray3)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // 각 정류장 선택지
                    if (alert?.firstBeforeBusStop) != nil || nodeord > 1 {
                        stationRow(stationText: 1, isEnabled: true) {
                            selectedStation = "1 정류장 전 알람"
                            alert?.alertBusStop = 1
                            withAnimation {
                                isPresented = false
                            }
                            onDismiss?()
                        }
                    } else {
                        stationRow(stationText: 1, isEnabled: false)
                    }
                    
                    if (alert?.secondBeforeBusStop) != nil || nodeord > 2 {
                        stationRow(stationText: 2, isEnabled: true) {
                            selectedStation = "2 정류장 전 알람"
                            alert?.alertBusStop = 2
                            withAnimation {
                                isPresented = false
                            }
                            onDismiss?()
                        }
                    } else {
                        stationRow(stationText: 2, isEnabled: false)
                    }
                    
                    if (alert?.thirdBeforeBusStop) != nil || nodeord > 3 {
                        stationRow(stationText: 3, isEnabled: true) {
                            selectedStation = "3 정류장 전 알람"
                            alert?.alertBusStop = 3
                            withAnimation {
                                isPresented = false
                            }
                            onDismiss?()
                        }
                    } else {
                        stationRow(stationText: 3, isEnabled: false)
                    }
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.whiteDBlack)
                )
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.32)
                .transition(.move(edge: .bottom))
            }
            .ignoresSafeArea()
        }
    }
    
    // 선택지 행 뷰 구성 함수
    private func stationRow(stationText: Int, isEnabled: Bool, action: (() -> Void)? = nil) -> some View {
        HStack {
            Text("\(stationText) 정류장 전 알람")
                .foregroundColor(isEnabled ? .gray1Dgray6 : .gray3Dgray3)
                .font(.body2)
                .onTapGesture {
                    if isEnabled, let action = action {
                        action()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            Spacer()
        }
    }
}
