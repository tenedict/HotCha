

// 로띠 메니저
// 로띠 제대로 만들면 그때 이것도 다시 만들거에요
import Foundation
import Lottie
import UIKit
import SwiftUI

struct LottieManager: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode
    let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        
        animationView.animation = LottieAnimation.named(filename)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode

        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func play() {
        animationView.play()
    }
    
    func stop() {
        animationView.stop()
    }
}
