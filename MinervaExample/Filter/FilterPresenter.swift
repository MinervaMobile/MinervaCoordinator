//
//  FilterPresenter.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class FilterPresenter: Presenter {
	public enum Action {
		case edit(filter: WorkoutFilter, type: FilterType)
	}

	private let actionsSubject = PublishSubject<Action>()
	public var actions: Observable<Action> { actionsSubject.asObservable() }

	private let sectionsSubject = BehaviorSubject<[ListSection]>(value: [])
	public var sections: Observable<[ListSection]> { sectionsSubject.asObservable() }

	private let disposeBag = DisposeBag()

	// MARK: - Lifecycle

	public init(filter: Observable<WorkoutFilter>) {
		filter.map({ [weak self] in self?.createSection(with: $0) ?? [] })
			.subscribe(sectionsSubject)
			.disposed(by: disposeBag)
	}

	// MARK: - Private

	private func createSection(with filter: WorkoutFilter) -> [ListSection] {
		var cellModels = [ListCellModel]()

		cellModels.append(LabelCellModel.createSectionHeaderModel(title: "FILTERS"))

		for type in FilterType.allCases {
			let details = filter.details(for: type) ?? "---"
			let nameCellModel = LabelAccessoryCellModel.createSettingsCellModel(
				identifier: "\(filter)-\(type)-\(details)",
				title: type.description,
				details: details,
				hasChevron: true)
			nameCellModel.selectionAction = { [weak self] _, _ -> Void in
				guard let strongSelf = self else { return }
				strongSelf.actionsSubject.onNext(.edit(filter: filter, type: type))
			}
			cellModels.append(nameCellModel)
		}

		let section = ListSection(cellModels: cellModels, identifier: "SECTION")
		return [section]
	}

}
