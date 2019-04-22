//
//  ActionSheetPresentAnimator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

final class ActionSheetPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

  private let duration = 0.5

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    guard let toViewController = transitionContext.viewController(forKey: .to) as? ActionSheetVC else {
      return
    }
    containerView.addSubview(toViewController.view)
    toViewController.backgroundButton.alpha = 0.0
    toViewController.view.layoutIfNeeded()
    toViewController.reloadCollectionView()
    UIView.animate(
      withDuration: duration,
      animations: {
        toViewController.backgroundButton.alpha = 0.5
        toViewController.view.layoutIfNeeded()
      },
      completion: { _ in
        transitionContext.completeTransition(true)
      }
    )
  }
}
