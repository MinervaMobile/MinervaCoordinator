//
//  CreateUserCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class CreateUserCoordinator: MainCoordinator<CreateUserPresenter, CollectionViewController> {

	private let dataManager: DataManager

	// MARK: - Lifecycle

	public init(navigator: Navigator, dataManager: DataManager) {
		self.dataManager = dataManager
		let presenter = CreateUserPresenter()
		let viewController = CollectionViewController()
		let listController = LegacyListController()
		super.init(
			navigator: navigator,
			viewController: viewController,
			presenter: presenter,
			listController: listController
		)
		presenter.actions.subscribe(onNext: { [weak self] in self?.handle($0) }).disposed(by: disposeBag)
		viewController.title = "Create User"
	}

	// MARK: - Private

	private func create(email: String, password: String, dailyCalories: Int32, role: UserRole) {
		LoadingHUD.show(in: viewController.view)
		dataManager.createUser(
			withEmail: email,
			password: password,
			dailyCalories: dailyCalories,
			role: role
		)
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
	private func handle(_ action: CreateUserPresenter.Action) {
		switch action {
		case let .create(email, password, dailyCalories, role):
			create(email: email, password: password, dailyCalories: dailyCalories, role: role)
		}
	}
}
