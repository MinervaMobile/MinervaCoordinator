//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class UpdateUserCoordinator: MainCoordinator<UpdateUserPresenter, CollectionViewController> {

  private let dataManager: DataManager

  // MARK: - Lifecycle

  public init(navigator: Navigator, dataManager: DataManager, user: User) {
    self.dataManager = dataManager
    let presenter = UpdateUserPresenter(user: user)
    let viewController = CollectionViewController()
    let listController = LegacyListController()
    super.init(
      navigator: navigator,
      viewController: viewController,
      presenter: presenter,
      listController: listController
    )
    presenter.actions.subscribe(onNext: { [weak self] in self?.handle($0) }).disposed(by: disposeBag)
    viewController.title = "Update User"
  }

  private func save(user: User) {
    LoadingHUD.show(in: viewController.view)
    dataManager.update(user)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] () -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.navigator.dismiss(strongSelf.viewController, animated: true, completion: nil)
        },
        onError: { [weak self] error -> Void in
          guard let strongSelf = self else { return }
          LoadingHUD.hide(from: strongSelf.viewController.view)
          strongSelf.viewController.alert(error, title: "Failed to save the user")
        }
      ).disposed(by: disposeBag)
  }

  private func handle(_ action: UpdateUserPresenter.Action) {
    switch action {
    case .save(let user):
      save(user: user)
    }
  }
}
