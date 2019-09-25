//
//  ActionSheetDismissAnimator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

final class ActionSheetDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

  private let duration = 0.5

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    guard let fromViewController = transitionContext.viewController(forKey: .from) as? ActionSheetVC else {
      return
    }

    containerView.addSubview(fromViewController.view)
    fromViewController.containerHeightConstraint.constant = 0
    UIView.animate(
      withDuration: duration,
      animations: {
        fromViewController.backgroundButton.alpha = 0
        fromViewController.view.layoutIfNeeded()
      },
      completion: { _ in
        transitionContext.completeTransition(true)
      }
    )
  }
}
