//
//  SurveyView.swift
//  BlueberrySmoothie
//
//  Created by Yeji Seo on 1/31/25.
//

import SwiftUI

struct SurveyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack(alignment: .top){
            VStack (alignment: .leading){
                Text("안녕하세요, 핫챠 팀입니다!")
                    .font(.title2)
                    .padding(EdgeInsets(top: 80, leading: 0, bottom: 5, trailing: 0))
                Text("항상 핫챠 앱을 사랑해 주셔서 감사합니다.\n더 나은 서비스를 제공하기 위해 핫챠 앱의 대규모 업데이트를 준비 중입니다.\n이번 업데이트에서는 디자인과 기능을 모두 새롭게 개선할 예정이며,\n여러분의 소중한 의견을 반영하고자 설문 조사를 진행합니다.")
                    .padding(.bottom, 10)
                
                Link(destination: URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSfJd0LhE5v_EW3MPRdQd-Df-YxlhmlrE7BFYvFJpfKcBLSRwQ/viewform?pli=1")!){
                    Text("[구글폼 설문조사 링크 바로가기]")
                        .font(.title2)
                        .foregroundColor(.brand)
                }
                Text("여러분의 의견이 핫챠를 더 좋은 서비스로 만드는 데 큰 힘이 됩니다. 감사합니다!")
                    .padding(.top, 10)
                Spacer()
            }
            .font(.body2)
            .foregroundColor(.gray1Dgray6)
            .padding(20)
            .lineSpacing(5)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 닫기 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .foregroundStyle(.gray1Dgray6)
                            .font(.body1)
                    }
                    .foregroundStyle(.gray1DBrand)
                }
            }
        }
    }
}

#Preview {
    SurveyView()
}
