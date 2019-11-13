//
//  FilterCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import RxSwift
import UIKit

public protocol FilterCoordinatorDelegate: AnyObject {
	func filterCoordinator(
		_ filterCoordinator: FilterCoordinator,
		updatedFilter filter: WorkoutFilter
	)
}

public final class FilterCoordinator: MainCoordinator<FilterDataSource, CollectionViewController> {

	public weak var delegate: FilterCoordinatorDelegate?

	// MARK: - Lifecycle

	public init(navigator: Navigator, filter: Observable<WorkoutFilter>) {
		let dataSource = FilterDataSource(filter: filter)
		let viewController = CollectionViewController()
		let listController = LegacyListController()
		super.init(
			navigator: navigator,
			viewController: viewController,
			dataSource: dataSource,
			listController: listController
		)
		dataSource.actions.subscribe(onNext: { [weak self] in self?.handle($0) }).disposed(by: disposeBag)
	}

	// MARK: - Private

	private func displayFilterPopup(with filter: WorkoutFilter, type: FilterType) {
		let coordinator = UpdateFilterCoordinator(navigator: navigator, filter: filter, type: type)
		coordinator.delegate = self
		push(coordinator, animated: true)
	}
	private func handle(_ action: FilterDataSource.Action) {
		switch action {
		case let .edit(filter, type):
			displayFilterPopup(with: filter, type: type)
		}
	}
}

// MARK: - UpdateFilterDataSourceDelegate
extension FilterCoordinator: UpdateFilterCoordinatorDelegate {
	public func updateFilterCoordinator(
		_ updateFilterCoordinator: UpdateFilterCoordinator,
		updatedFilter filter: WorkoutFilter
	) {
		delegate?.filterCoordinator(self, updatedFilter: filter)
	}
}
