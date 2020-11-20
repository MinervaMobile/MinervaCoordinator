//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import PanModal
import UIKit

open class PanModalNavigator: BasicNavigator {
  public enum PadDisplayPopoverType {
    case view(sourceView: UIView?, sourceRect: CGRect)
    case barButtonItem(item: UIBarButtonItem)
  }
  public enum PadDisplayMode {
    case popover(type: PadDisplayPopoverType)
    case modal
  }
  public init(
    parent: Navigator?,
    navigationController: UINavigationController & PanModalPresentable,
    padDisplayMode: PadDisplayMode
  ) {
    // Set this here so we are able to present PanModal without using convenience method
    if UIDevice.current.userInterfaceIdiom == .pad, case .popover(let type) = padDisplayMode {
      navigationController.modalPresentationStyle = .popover
      switch type {
      case let .view(sourceView, sourceRect):
        navigationController.popoverPresentationController?.sourceRect = sourceRect
        navigationController.popoverPresentationController?.sourceView =
          sourceView ?? navigationController.view
      case .barButtonItem(let item):
        navigationController.popoverPresentationController?.barButtonItem = item
      }
      navigationController.popoverPresentationController?.delegate =
        PanModalPresentationDelegate.default
    } else {
      navigationController.modalPresentationStyle = .custom
      navigationController.modalPresentationCapturesStatusBarAppearance = true
      navigationController.transitioningDelegate = PanModalPresentationDelegate.default
    }
    super.init(parent: parent, navigationController: navigationController)
  }

  deinit {
    navigationController.setViewControllers([], animated: false)
  }
}
