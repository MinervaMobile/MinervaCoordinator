//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift

public final class FakeCoordinator: BaseCoordinator<FakePresenter, CollectionViewController> {

  public var viewDidLoad = false
  public var viewWillAppear = false
  public var viewWillDisappear = false
  public var viewDidAppear = false
  public var viewDidDisappear = false
  public var traitCollectionDidChange = false

  public init(navigator: Navigator? = nil) {
    let layout = ListViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
    let collectionVC = CollectionViewController(layout: layout)
    collectionVC.backgroundImage = UIImage()
    let listController = LegacyListController()
    let navigator = navigator ?? BasicNavigator(parent: nil)
    let presenter = FakePresenter()
    super
      .init(
        navigator: navigator,
        viewController: collectionVC,
        presenter: presenter,
        listController: listController
      )
    viewController.events
      .subscribe(onNext: { [weak self] event in
        self?.handle(event)
      })
      .disposed(by: disposeBag)
    collectionVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 10_000)
  }

  // MARK: - ListControllerSizeDelegate

  override public func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    CGSize(width: sizeConstraints.adjustedContainerSize.width, height: 24)
  }

  private func handle(_ event: ListViewControllerEvent) {
    switch event {
    case .traitCollectionDidChange:
      traitCollectionDidChange = true
    case .viewDidDisappear:
      viewDidDisappear = true
    case .viewDidLoad:
      viewDidLoad = true
    case .viewWillAppear:
      viewWillAppear = true
    case .viewWillDisappear:
      viewWillDisappear = true
    case .viewDidAppear:
      viewDidAppear = true

    }
  }
}
