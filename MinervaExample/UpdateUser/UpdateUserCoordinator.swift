//
//  UpdateUserCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class UpdateUserCoordinator: MainCoordinator<UpdateUserDataSource, CollectionViewController> {

	private let dataManager: DataManager

	// MARK: - Lifecycle

	public init(navigator: Navigator, dataManager: DataManager, user: User) {
		self.dataManager = dataManager
		let dataSource = UpdateUserDataSource(user: user)
		let viewController = CollectionViewController()
		let listController = LegacyListController()
		super.init(
			navigator: navigator,
			viewController: viewController,
			dataSource: dataSource,
			listController: listController
		)
		dataSource.actions.subscribe(onNext: { [weak self] in self?.handle($0) }).disposed(by: disposeBag)
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

	private func handle(_ action: UpdateUserDataSource.Action) {
		switch action {
		case .save(let user):
			save(user: user)
		}
	}
}
