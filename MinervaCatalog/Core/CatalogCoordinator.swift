//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Minerva
import RxSwift
import UIKit

public final class CatalogCoordinator: BaseCoordinator<CatalogPresenter, CollectionViewController> {
  public init() {
    let navigator = BasicNavigator(parent: nil)
    let viewController = CollectionViewController()
    viewController.backgroundColor = .systemBackground
    let presenter = CatalogPresenter()
    let listController = LegacyListController()
    super.init(
      navigator: navigator,
      viewController: viewController,
      presenter: presenter,
      listController: listController
    )
  }
}
