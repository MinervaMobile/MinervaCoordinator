//
//  MainCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

public class MainCoordinator<T: DataSource, U: UIViewController & ViewController>: BaseCoordinator<T, U>, UIViewControllerTransitioningDelegate {

  public typealias RefreshBlock = (_ dataSource: T, _ animated: Bool) -> Void

  private let refreshBlock: RefreshBlock

  // MARK: - Lifecycle
  public init(navigator: Navigator, viewController: U, dataSource: T, refreshBlock: @escaping RefreshBlock) {
    self.refreshBlock = refreshBlock
    super.init(navigator: navigator, viewController: viewController, dataSource: dataSource)
  }

  // MARK: - DataSourceUpdateDelegate
  public override func dataSource(_ dataSource: DataSource, encountered error: Error) {
    viewController.alert(error, title: "Failed to load your data")
  }

  public override func dataSource(
    _ dataSource: DataSource,
    update sections: [ListSection],
    animated: Bool,
    completion: DataSourceUpdateDelegate.Completion?
  ) {
    listController.update(with: sections, animated: animated, completion: completion)
  }
  public override func dataSourceStartedUpdate(_ dataSource: DataSource) {
    LoadingHUD.show(in: viewController.view)
  }
  public override func dataSourceCompletedUpdate(_ dataSource: DataSource) {
    LoadingHUD.hide(from: viewController.view)
  }

  // MARK: - ListControllerSizeDelegate
  public override func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    guard model is MarginCellModel else { return nil }
    let cellModels = listController.cellModels
    let collectionViewBounds = sizeConstraints.containerSize
    let minHeight: CGFloat = 20
    let dynamicHeight = cellModels.reduce(collectionViewBounds.height) { sum, model -> CGFloat in
      sum - (listController.size(of: model)?.height ?? 0)
    }
    let marginCellCount = cellModels.filter { $0 is MarginCellModel }.count
    let height = max(minHeight, dynamicHeight / CGFloat(marginCellCount))
    let width = sizeConstraints.adjustedContainerSize.width
    return CGSize(width: width, height: height)
  }

  // MARK: - ViewControllerDelegate
  override public func viewController(_ viewController: ViewController, viewWillAppear animated: Bool) {
    super.viewController(viewController, viewWillAppear: animated)
    refreshBlock(dataSource, animated)
  }

  // MARK: - UIViewControllerTransitioningDelegate
  public func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    let transition = ActionSheetPresentAnimator()
    return transition
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let transition = ActionSheetDismissAnimator()
    return transition
  }
}
