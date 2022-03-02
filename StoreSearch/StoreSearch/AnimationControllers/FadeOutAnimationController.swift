//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 02.03.2022.
//

import UIKit


class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        print("T1")
        if let fromView = transitionContext.view(forKey: .from) {
            print("T2")
            let time = transitionDuration(using: transitionContext)
            UIView.animate(
                withDuration: time) {
                    fromView.alpha = 0
                } completion: { finished in
                    transitionContext.completeTransition(finished)
                }

        }
    }
}
