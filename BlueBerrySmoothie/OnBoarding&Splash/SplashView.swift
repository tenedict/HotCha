//
//  SplashView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/24/24.
//


import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    private var locationManager = LocationManager.shared
    
    var body: some View {
        if isActive {
            AppView()
        } else {
                Image("Splash")
                    .frame(width: 300)
                    .padding(.bottom, 100)

            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        isActive = true
                    }
                    locationManager.stopLocationUpdates()
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
