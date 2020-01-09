//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxRelay
import RxSwift
import UIKit

public final class EditWorkoutPresenter: Presenter {
  public enum Action {
    case save(workout: Workout)
  }

  private static let dateCellModelIdentifier = "DateCellModel"
  private static let caloriesCellModelIdentifier = "CaloriesCellModel"
  private static let textCellModelIdentifier = "TextCellModel"

  private let actionsRelay = PublishRelay<Action>()
  public var actions: Observable<Action> { actionsRelay.asObservable() }

  public var sections = BehaviorRelay<[ListSection]>(value: [])

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
      .bind(to: sections)
      .disposed(by: disposeBag)
  }

  // MARK: - Private

  private func createSection(with workout: WorkoutProto) -> [ListSection] {
    let cellModels = loadCellModels(with: workout)
    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return [section]
  }

  private func loadCellModels(with workout: WorkoutProto) -> [ListCellModel] {
    let doneModel = SelectableLabelCellModel(
      identifier: "doneModel",
      text: "Save",
      font: .title1)
    doneModel.directionalLayoutMargins.leading = 0
    doneModel.directionalLayoutMargins.trailing = 0
    doneModel.textAlignment = .center
    doneModel.textColor = .selectable
    doneModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.actionsRelay.accept(.save(workout: strongSelf.workout))
    }

    return [
      MarginCellModel(identifier: "headerMarginModel", height: 12),
      createDateCellModel(with: workout),
      MarginCellModel(identifier: "dateMarginModel", height: 12),
      createCaloriesCellModel(with: workout),
      MarginCellModel(identifier: "caloriesMarginModel", height: 12),
      createTextCellModel(with: workout),
      MarginCellModel(identifier: "textMarginModel", height: 12),
      doneModel,
      MarginCellModel(identifier: "doneMarginModel", height: 12)
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
