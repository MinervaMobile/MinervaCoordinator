//
//  EditWorkoutPresenter.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

protocol EditWorkoutPresenterDelegate: AnyObject {
  func workoutActionSheetDataSource(
    _ workoutActionSheetDataSource: EditWorkoutPresenter,
    selected action: EditWorkoutPresenter.Action)
}

final class EditWorkoutPresenter: BaseDataSource {
  enum Action {
    case save(workout: Workout)
  }

  private static let dateCellModelIdentifier = "DateCellModel"
  private static let caloriesCellModelIdentifier = "CaloriesCellModel"
  private static let textCellModelIdentifier = "TextCellModel"

  weak var delegate: EditWorkoutPresenterDelegate?

  private var workout: WorkoutProto
  private let editing: Bool

  // MARK: - Lifecycle

  init(workout: Workout, editing: Bool) {
    self.workout = workout.proto
    self.editing = editing
  }

  // MARK: - Public

  func reload(animated: Bool) {
    updateDelegate?.dataSourceStartedUpdate(self)
    let section = createSection()
    updateDelegate?.dataSource(self, update: [section], animated: animated, completion: nil)
    updateDelegate?.dataSourceCompletedUpdate(self)
  }

  // MARK: - Helpers

  private func createSection() -> ListSection {
    let cellModels = loadCellModels()
    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return section
  }

  func loadCellModels() -> [ListCellModel] {
    let doneModel = LabelCell.Model(
      identifier: "doneModel",
      text: "Save",
      font: .titleLarge)
    doneModel.leftMargin = 0
    doneModel.rightMargin = 0
    doneModel.textAlignment = .center
    doneModel.textColor = .selectable
    doneModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.workoutActionSheetDataSource(strongSelf, selected: .save(workout: strongSelf.workout))
    }

    return [
      MarginCellModel(cellIdentifier: "headerMarginModel", height: 12),
      createDateCellModel(),
      MarginCellModel(cellIdentifier: "dateMarginModel", height: 12),
      createCaloriesCellModel(),
      MarginCellModel(cellIdentifier: "caloriesMarginModel", height: 12),
      createTextCellModel(),
      MarginCellModel(cellIdentifier: "textMarginModel", height: 12),
      doneModel,
      MarginCellModel(cellIdentifier: "doneMarginModel", height: 12)
    ]
  }

  // MARK: - Helpers

  private func createDateCellModel() -> ListCellModel {
    let cellModel = DatePickerCellModel(identifier: "dateCellModel", startDate: workout.date)
    cellModel.maximumDate = Date()
    cellModel.changedDate = { [weak self] _, date -> Void in
      self?.workout.date = date
    }
    return cellModel
  }

  private func createTextCellModel() -> ListCellModel {
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
    cellModel.bottomBorderColor = .black
    cellModel.delegate = self
    return cellModel
  }

  private func createCaloriesCellModel() -> ListCellModel {
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
    cellModel.bottomBorderColor = .black
    cellModel.delegate = self
    return cellModel
  }
}

// MARK: - TextInputCellModelDelegate
extension EditWorkoutPresenter: TextInputCellModelDelegate {
  func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?) {
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
