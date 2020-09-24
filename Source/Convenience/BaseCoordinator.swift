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
  // This is used to cache the sections from the presenter so that the list controller can be cleared
  // when the view controller is not visible.
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
  public weak var presentedCoordinator: BaseCoordinatorPresentable?

  // MARK: - CoordinatorPresentable
  public typealias CoordinatorVC = U
  public let viewController: CoordinatorVC

  private var afterUpdateBlocks = [() -> Void]()

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

  open func executeAfterUpdate(_ block: @escaping () -> Void) {
    dispatchPrecondition(condition: .onQueue(.main))
    afterUpdateBlocks.append(block)
  }

  // MARK: - ListControllerSizeDelegate
  open func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    RelativeCellSizingHelper.sizeOf(
      cellModel: model,
      listController: listController,
      constrainedTo: sizeConstraints
    )
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
          self?.update(with: sections)
        })
    case .viewWillDisappear:
      break
    case .viewDidAppear:
      break
    }
  }

  private func update(with sections: [ListSection]) {
    listController.update(with: sections, animated: true) { [weak self] _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.afterUpdateBlocks.forEach { $0() }
      strongSelf.afterUpdateBlocks.removeAll()
    }
  }
}
