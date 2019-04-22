//
//  WorkoutActionSheetDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

protocol WorkoutActionSheetDataSourceDelegate: class {
  func workoutActionSheetDataSource(
    _ workoutActionSheetDataSource: WorkoutActionSheetDataSource,
    selected action: WorkoutActionSheetDataSource.Action)
}

final class WorkoutActionSheetDataSource: ActionSheetDataSource {
  enum Action {
    case dismiss
    case save(workout: Workout)
  }

  private static let dateCellModelIdentifier = "DateCellModel"
  private static let caloriesCellModelIdentifier = "CaloriesCellModel"
  private static let textCellModelIdentifier = "TextCellModel"

  weak var delegate: WorkoutActionSheetDataSourceDelegate?

  private var workout: WorkoutProto
  private let editing: Bool

  // MARK: - Lifecycle

  init(workout: Workout, editing: Bool) {
    self.workout = workout.proto
    self.editing = editing
  }

  // MARK: - Public

  func loadCellModels() -> [ListCellModel] {
    let leftAction: LabelCellModel.SelectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.workoutActionSheetDataSource(strongSelf, selected: .dismiss)
    }
    let rightAction: LabelCellModel.SelectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.workoutActionSheetDataSource(strongSelf, selected: .save(workout: strongSelf.workout))
    }
    let headerSectionModel = ActionSheetVC.createHeaderModel(
      identifier: "ActionSheetHeader",
      leftText: "Cancel",
      centerText: editing ? "Edit Workout" : "Add Workout",
      rightText: "Save",
      leftAction: leftAction,
      rightAction: rightAction)

    return [
      headerSectionModel,
      MarginCellModel(cellIdentifier: "headerMarginModel", height: 12),
      createDateCellModel(),
      MarginCellModel(cellIdentifier: "dateMarginModel", height: 12),
      createCaloriesCellModel(),
      MarginCellModel(cellIdentifier: "caloriesMarginModel", height: 12),
      createTextCellModel(),
      MarginCellModel(cellIdentifier: "textMarginModel", height: 12)
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
      identifier: WorkoutActionSheetDataSource.textCellModelIdentifier,
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
      identifier: WorkoutActionSheetDataSource.caloriesCellModelIdentifier,
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
extension WorkoutActionSheetDataSource: TextInputCellModelDelegate {
  func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?) {
    guard let text = text else { return }
    switch textInputCellModel.identifier {
    case WorkoutActionSheetDataSource.textCellModelIdentifier:
      workout.text = text
    case WorkoutActionSheetDataSource.caloriesCellModelIdentifier:
      workout.calories = Int32(text) ?? workout.calories
    default:
      assertionFailure("Unknown text input cell model")
    }
  }
}
