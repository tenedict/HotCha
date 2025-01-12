//
//  NoBussignalView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 1/12/25.
//

import SwiftUI

struct NoBussignalView: View {
    @State private var showSplash = true // 스플래시 화면을 제어할 변수
    @StateObject private var networkMonitor = NetworkMonitor()

    var body: some View {
        ZStack {
            if showSplash {
                // 스플래시 화면
                VStack {
//                    Image(systemName: "bus.fill")
//                        .font(.system(size: 50))
//                        .foregroundColor(.blue)
//                    Text("버스를 찾고 있습니다...")
//                        .font(.title1)
                }
                .onAppear {
                    // 5초 후에 스플래시 화면을 숨기고 실제 화면을 보여줌
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSplash = false
                        }
                    }
                }
            } else {
                // 실제 화면 (버스 없음 메시지)
                if networkMonitor.isConnected {
                    VStack {
                        Spacer()
                    ZStack {
                        Image(systemName: "bus.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.brand)
                        Image(systemName: "questionmark")
                            .font(.system(size: 25))
                            .foregroundColor(.brand)
                            .padding(.bottom, 20)
                    }
                    Text("운행중인 버스가 없습니다.\n버스번호를 확인해 주세요.")
                        .font(.title1)
                        .padding()
                    Spacer()
                }
            }
                else {
                    
                    
                    VStack{
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.brand)
                            Spacer()
                        }
                        Text("인터넷 연결이 불안정합니다.\n인터넷 연결을 확인해 주세요.")
                            .font(.title1)
                            .padding()
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    NoBussignalView()
}
