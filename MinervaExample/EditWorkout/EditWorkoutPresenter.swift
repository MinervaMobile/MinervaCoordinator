//
//  EditWorkoutPresenter.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class EditWorkoutPresenter: DataSource {
	public enum Action {
		case save(workout: Workout)
	}

	private static let dateCellModelIdentifier = "DateCellModel"
	private static let caloriesCellModelIdentifier = "CaloriesCellModel"
	private static let textCellModelIdentifier = "TextCellModel"

	private let actionsSubject = PublishSubject<Action>()
	public var actions: Observable<Action> { actionsSubject.asObservable() }

	private let sectionsSubject = BehaviorSubject<[ListSection]>(value: [])
	public var sections: Observable<[ListSection]> { sectionsSubject.asObservable() }

	private let disposeBag = DisposeBag()

	private var workout: WorkoutProto {
		didSet {
			workoutSubject.onNext(workout)
		}
	}
	private var workoutSubject: BehaviorSubject<WorkoutProto>

	// MARK: - Lifecycle

	public init(workout: Workout) {
		self.workout = workout.proto
		self.workoutSubject = BehaviorSubject<WorkoutProto>(value: self.workout)
		workoutSubject.map({ [weak self] workout -> [ListSection] in self?.createSection(with: workout) ?? [] })
			.subscribe(sectionsSubject)
			.disposed(by: disposeBag)
	}

	// MARK: - Helpers

	private func createSection(with workout: WorkoutProto) -> [ListSection] {
		let cellModels = loadCellModels(with: workout)
		let section = ListSection(cellModels: cellModels, identifier: "SECTION")
		return [section]
	}

	private func loadCellModels(with workout: WorkoutProto) -> [ListCellModel] {
		let doneModel = LabelCell.Model(
			identifier: "doneModel",
			text: "Save",
			font: .title1)
		doneModel.leftMargin = 0
		doneModel.rightMargin = 0
		doneModel.textAlignment = .center
		doneModel.textColor = .selectable
		doneModel.selectionAction = { [weak self] _, _ -> Void in
			guard let strongSelf = self else { return }
			strongSelf.actionsSubject.onNext(.save(workout: strongSelf.workout))
		}

		return [
			MarginCellModel(cellIdentifier: "headerMarginModel", height: 12),
			createDateCellModel(with: workout),
			MarginCellModel(cellIdentifier: "dateMarginModel", height: 12),
			createCaloriesCellModel(with: workout),
			MarginCellModel(cellIdentifier: "caloriesMarginModel", height: 12),
			createTextCellModel(with: workout),
			MarginCellModel(cellIdentifier: "textMarginModel", height: 12),
			doneModel,
			MarginCellModel(cellIdentifier: "doneMarginModel", height: 12)
		]
	}

	private func createDateCellModel(with workout: WorkoutProto) -> ListCellModel {
		let cellModel = DatePickerCellModel(identifier: "dateCellModel", startDate: workout.date)
		cellModel.maximumDate = Date()
		cellModel.changedDate = { [weak self] _, date -> Void in
			self?.workout.date = date
		}
		return cellModel
	}

	private func createTextCellModel(with workout: WorkoutProto) -> ListCellModel {
		let cellModel = TextInputCellModel(
			identifier: EditWorkoutPresenter.textCellModelIdentifier,
			placeholder: "Description of the workout...",
			font: .subheadline)
		cellModel.text = workout.text.isEmpty ? nil : workout.text
		cellModel.keyboardType = .default
		cellModel.cursorColor = .selectable
		cellModel.textColor = .black
		cellModel.inputTextColor = .black
		cellModel.placeholderTextColor = .gray
		cellModel.bottomBorderColor.onNext(.black)
		cellModel.delegate = self
		return cellModel
	}

	private func createCaloriesCellModel(with workout: WorkoutProto) -> ListCellModel {
		let cellModel = TextInputCellModel(
			identifier: EditWorkoutPresenter.caloriesCellModelIdentifier,
			placeholder: "Calories",
			font: .subheadline)
		cellModel.text = workout.calories > 0 ? String(workout.calories) : nil
		cellModel.keyboardType = .numberPad
		cellModel.cursorColor = .selectable
		cellModel.textColor = .black
		cellModel.inputTextColor = .black
		cellModel.placeholderTextColor = .gray
		cellModel.bottomBorderColor.onNext(.black)
		cellModel.delegate = self
		return cellModel
	}
}

// MARK: - TextInputCellModelDelegate
extension EditWorkoutPresenter: TextInputCellModelDelegate {
	public func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?) {
		guard let text = text else { return }
		switch textInputCellModel.identifier {
		case EditWorkoutPresenter.textCellModelIdentifier:
			workout.text = text
		case EditWorkoutPresenter.caloriesCellModelIdentifier:
			workout.calories = Int32(text) ?? workout.calories
		default:
			assertionFailure("Unknown text input cell model")
		}
	}
}
