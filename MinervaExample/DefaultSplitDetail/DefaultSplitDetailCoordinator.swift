//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class DefaultSplitDetailCoordinator: MainCoordinator<
  DefaultSplitDetailPresenter, CollectionViewController
> {
  // MARK: - Lifecycle

  public init(navigator: Navigator) {
    let presenter = DefaultSplitDetailPresenter()
    let viewController = CollectionViewController()
    let listController = LegacyListController()
    super
      .init(
        navigator: navigator,
        viewController: viewController,
        presenter: presenter,
        listController: listController
      )
  }
}
