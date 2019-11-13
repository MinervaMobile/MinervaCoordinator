//
//  WelcomeCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import UIKit

public protocol WelcomeCoordinatorDelegate: AnyObject {
	func onboardingCoordinator(
		_ onboardingCoordinator: WelcomeCoordinator,
		activated dataManager: DataManager
	)
}

/// Manages the user flows for logging in and creating new accounts
public final class WelcomeCoordinator: MainCoordinator<WelcomePresenter, CollectionViewController> {

	public weak var delegate: WelcomeCoordinatorDelegate?
	private let userManager: UserManager

	// MARK: - Lifecycle

	public init(navigator: Navigator, userManager: UserManager) {
		self.userManager = userManager

		let presenter = WelcomePresenter()
		let viewController = CollectionViewController()
		let listController = LegacyListController()
		super.init(
			navigator: navigator,
			viewController: viewController,
			presenter: presenter,
			listController: listController
		)
		presenter.actions.subscribe(onNext: { [weak self] in self?.handle($0) }).disposed(by: disposeBag)
	}

	// MARK: - Private

	private func displaySignInVC(mode: SignInPresenter.Mode) {
		let coordinator = SignInCoordinator(navigator: navigator, userManager: userManager, mode: mode)
		coordinator.delegate = self
		push(coordinator, animated: true)
	}
	private func handle(_ action: WelcomePresenter.Action) {
		switch action {
		case .login: displaySignInVC(mode: .login)
		case .createAccount: displaySignInVC(mode: .createAccount)
		}
	}
}

extension WelcomeCoordinator: SignInCoordinatorDelegate {
	public func signInCoordinator(_ signInCoordinator: SignInCoordinator, activated dataManager: DataManager) {
		delegate?.onboardingCoordinator(self, activated: dataManager)
	}
}
