//
//  WorkoutCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class WorkoutCoordinator: MainCoordinator<WorkoutPresenter, WorkoutVC> {

	private let dataManager: DataManager
	private let presenter: WorkoutPresenter

	// MARK: - Lifecycle

	public init(navigator: Navigator, dataManager: DataManager, userID: String) {
		self.dataManager = dataManager

		let repository = WorkoutRepository(dataManager: dataManager, userID: userID)
		let presenter = WorkoutPresenter(repository: repository)
		self.presenter = presenter
		let listController = LegacyListController()
		let viewController = WorkoutVC(presenter: presenter, listController: listController)
		super.init(
			navigator: navigator,
			viewController: viewController,
			dataSource: presenter,
			listController: listController)

	}

	// MARK: - ViewControllerDelegate
	override public func viewControllerViewDidLoad(_ viewController: ViewController) {
		super.viewControllerViewDidLoad(viewController)

		presenter.actions
			.subscribe(onNext: handle(action:), onError: nil, onCompleted: nil, onDisposed: nil)
			.disposed(by: disposeBag)
	}

	// MARK: - Private

	private func handle(action: WorkoutPresenter.Action) {
		switch action {
		case .createWorkout(let userID):
			displayWorkoutPopup(with: nil, forUserID: userID)
		case .editWorkout(let workout):
			displayWorkoutPopup(with: workout, forUserID: workout.userID)
		case .editFilter:
			displayFilterSelection()
		}
	}

	private func displayWorkoutPopup(with workout: Workout?, forUserID userID: String) {
		let editing = workout != nil
		let workout = workout
			?? WorkoutProto(workoutID: UUID().uuidString, userID: userID, text: "", calories: 0, date: Date())

		let navigator = BasicNavigator(parent: self.navigator)
		let coordinator = EditWorkoutCoordinator(
			navigator: navigator,
			dataManager: dataManager,
			workout: workout,
			editing: editing)
		presentWithCloseButton(coordinator, modalPresentationStyle: .safeAutomatic)
	}

	private func displayFilterSelection() {
		let navigator = BasicNavigator(parent: self.navigator)
		let coordinator = FilterCoordinator(navigator: navigator, filter: presenter.filter)
		coordinator.delegate = self
		presentWithCloseButton(coordinator, modalPresentationStyle: .safeAutomatic)
	}
}

// MARK: - FilterCoordinatorDelegate
extension WorkoutCoordinator: FilterCoordinatorDelegate {
	public func filterCoordinator(_ filterCoordinator: FilterCoordinator, updatedFilter filter: WorkoutFilter) {
		presenter.apply(filter: filter)
		dismiss(filterCoordinator, animated: true)
	}
}
