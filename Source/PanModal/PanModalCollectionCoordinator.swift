//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import PanModal
import UIKit

open class PanModalCollectionCoordinator<T: ListPresenter, U: ListViewController>: BaseCoordinator<T, U>, PanModalCoordinatorPresentable
{

  // MARK: - PanModalCoordinatorPresentable

  public let panModalPresentableVC: UIViewController & PanModalPresentable
  public let navigationController: PanModalNavigationCollectionVC

  // MARK: - Lifecycle

  public init(
    parentNavigator: Navigator?,
    collectionViewController: U,
    presenter: T,
    listController: ListController,
    padDisplayMode: PanModalNavigator.PadDisplayMode = .modal
  ) {

    let navigationController = PanModalNavigationCollectionVC(
      rootViewController: collectionViewController
    )
    self.navigationController = navigationController
    self.panModalPresentableVC = navigationController

    let navigator = PanModalNavigator(
      parent: parentNavigator,
      navigationController: navigationController,
      padDisplayMode: padDisplayMode
    )

    super
      .init(
        navigator: navigator,
        viewController: collectionViewController,
        presenter: presenter,
        listController: listController
      )
  }
}
