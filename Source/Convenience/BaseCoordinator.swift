//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxRelay
import RxSwift
import UIKit

open class BaseCoordinator<T: ListPresenter, U: ListViewController>: NSObject, CoordinatorNavigator,
  CoordinatorPresentable, ListControllerSizeDelegate
{
  private var updateRelay = BehaviorRelay<[ListSection]>(value: [])
  private var updateDisposable: Disposable?

  public let listController: ListController
  public let presenter: T
  public let disposeBag = DisposeBag()

  // MARK: - Coordinator
  public weak var parent: Coordinator?
  public var childCoordinators = [Coordinator]()

  // MARK: - CoordinatorNavigator
  public let navigator: Navigator

  // MARK: - CoordinatorPresentable
  public typealias CoordinatorVC = U
  public let viewController: CoordinatorVC

  // MARK: - Lifecycle

  public init(
    navigator: Navigator,
    viewController: U,
    presenter: T,
    listController: ListController
  ) {
    self.navigator = navigator
    self.viewController = viewController
    self.presenter = presenter
    self.listController = listController

    super.init()

    listController.collectionView = viewController.collectionView
    listController.viewController = viewController
    listController.sizeDelegate = self
    viewController.events
      .subscribe(
        onNext: { [weak self] event -> Void in
          self?.handle(event)
        }
      )
      .disposed(by: disposeBag)
  }

  // MARK: - ListControllerSizeDelegate
  open func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    nil
  }

  // MARK: - Private

  private func handle(_ event: ListViewControllerEvent) {
    switch event {
    case .traitCollectionDidChange:
      listController.invalidateLayout()
    case .viewDidDisappear:
      listController.didEndDisplaying()
      updateDisposable?.dispose()
      updateDisposable = nil
    case .viewDidLoad:
      presenter.sections.bind(to: updateRelay).disposed(by: disposeBag)
    case .viewWillAppear:
      listController.willDisplay()
      updateDisposable?.dispose()
      updateDisposable =
        updateRelay
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] sections in
          self?.listController.update(with: sections, animated: true)
        })
    case .viewWillDisappear:
      break
    }
  }
}
