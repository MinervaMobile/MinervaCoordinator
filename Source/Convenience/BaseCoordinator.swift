//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxRelay
import RxSwift
import UIKit

open class BaseCoordinator<T: Presenter, U: ViewController>: NSObject, CoordinatorNavigator, CoordinatorPresentable, ListControllerSizeDelegate, ViewControllerDelegate {

  public typealias CoordinatorVC = U

  public weak var parent: Coordinator?
  public var childCoordinators = [Coordinator]()
  public let listController: ListController

  public let viewController: U
  public let presenter: T
  public let navigator: Navigator
  public let disposeBag = DisposeBag()
  private var updateRelay = BehaviorRelay<[ListSection]>(value: [])
  private var updateDisposable: Disposable?

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
    viewController.lifecycleDelegate = self
  }

  // MARK: - ListControllerSizeDelegate

  open func listController(
    _ listController: ListController,
    sizeFor model: ListCellModel,
    at indexPath: IndexPath,
    constrainedTo sizeConstraints: ListSizeConstraints
  ) -> CGSize? {
    return nil
  }

  // MARK: - ViewControllerDelegate
  open func viewControllerViewDidLoad(_ viewController: ViewController) {
    presenter.sections.bind(to: updateRelay).disposed(by: disposeBag)
  }
  open func viewController(_ viewController: ViewController, viewWillAppear animated: Bool) {
    listController.willDisplay()
    updateDisposable?.dispose()
    updateDisposable = updateRelay
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] sections in self?.listController.update(with: sections, animated: true) })
  }
  open func viewController(_ viewController: ViewController, viewWillDisappear animated: Bool) {
  }
  open func viewController(_ viewController: ViewController, viewDidDisappear animated: Bool) {
    listController.didEndDisplaying()
    updateDisposable?.dispose()
    updateDisposable = nil
  }
  open func viewController(
    _ viewController: ViewController,
    traitCollectionDidChangeFrom previousTraitCollection: UITraitCollection?
  ) {
    listController.invalidateLayout()
  }
}
