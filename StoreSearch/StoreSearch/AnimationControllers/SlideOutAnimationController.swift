//
//  SlideOutAnimationController.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 02.03.2022.
//

import UIKit


class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: .from) {
            let containerView = transitionContext.containerView
            let time = transitionDuration(using: transitionContext)
            
            UIView.animate(
                withDuration: time,
                animations: {
                    fromView.center.y -= containerView.bounds.size.height
//                    fromView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
                }
            )
        }
    }
}
