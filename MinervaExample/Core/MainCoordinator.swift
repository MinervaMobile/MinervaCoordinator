//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import UIKit

public class MainCoordinator<T: ListPresenter, U: ListViewController>: BaseCoordinator<T, U> {

  public typealias DismissBlock = (BaseCoordinatorPresentable) -> Void

  private var dismissBlock: DismissBlock?

  // MARK: - Public

  public final func addCloseButton(dismissBlock: @escaping DismissBlock) {
    self.dismissBlock = dismissBlock
    viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "Close",
      style: .plain,
      target: self,
      action: #selector(closeButtonPressed(_:))
    )
  }

  // MARK: - Private

  @objc
  private func closeButtonPressed(_ sender: UIBarButtonItem) {
    dismissBlock?(self)
  }

  // MARK: - ListControllerSizeDelegate

  override public func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    if model is MarginCellModel {
      return RelativeCellSizingHelper.sizeOf(
        cellModel: model,
        withExcessHeightDividedEquallyBetween: { $0 is MarginCellModel },
        listController: listController,
        constrainedTo: sizeConstraints
      )
    } else {
      return nil
    }
  }
}

extension UIModalPresentationStyle {
  /// On iOS13+ this is UIModalPresentationStyle.automatic and earler versions are UIModalPresentationStyle.fullScreen
  public static var safeAutomatic: UIModalPresentationStyle {
    if #available(iOS 13, tvOS 13.0, *) {
      return .automatic
    } else {
      return .fullScreen
    }
  }
}
