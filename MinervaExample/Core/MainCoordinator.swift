//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import UIKit

public class MainCoordinator<T: Presenter, U: ViewController>: BaseCoordinator<T, U> {

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
    guard model is MarginCellModel else { return nil }
    let collectionViewBounds = sizeConstraints.containerSize
    let minHeight: CGFloat = 1
    let dynamicHeight = listController.listSections.reduce(collectionViewBounds.height) { sum, section -> CGFloat in
      sum - listController.size(of: section, containerSize: collectionViewBounds).height
    }
    let marginCellCount = listController.cellModels.reduce(0) { count, model -> Int in
      guard let marginModel = model as? MarginCellModel else { return count }
      guard case .relative = marginModel.cellSize else { return count }
      return count + 1
    }
    let width = sizeConstraints.adjustedContainerSize.width
    guard marginCellCount > 0 else {
      return CGSize(width: width, height: minHeight)
    }
    let height = max(minHeight, dynamicHeight / CGFloat(marginCellCount))
    return CGSize(width: width, height: height)
  }
}
