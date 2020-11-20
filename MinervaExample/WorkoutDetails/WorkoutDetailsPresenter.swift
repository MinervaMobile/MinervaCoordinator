//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxRelay
import RxSwift
import UIKit

public final class WorkoutDetailsPresenter: ListPresenter {
  public enum Action {
    case edit(workout: Workout)
  }

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
    workoutSubject.map({ [weak self] workout -> [ListSection] in
      self?.createSection(with: workout) ?? []
    })
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

    let titleModel = LabelCellModel(text: workout.text, font: .headline)
    titleModel.textAlignment = .center
    titleModel.directionalLayoutMargins.top = 12

    let detailsModel = LabelCellModel(text: workout.description, font: .subheadline)
    detailsModel.textAlignment = .center
    detailsModel.directionalLayoutMargins.top = 12

    let editModel = SelectableLabelCellModel(
      identifier: "editModel",
      text: "Edit",
      font: .title1
    )
    editModel.directionalLayoutMargins.leading = 0
    editModel.directionalLayoutMargins.trailing = 0
    editModel.textAlignment = .center
    editModel.textColor = .selectable
    editModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.actionsRelay.accept(.edit(workout: strongSelf.workout))
    }
    editModel.directionalLayoutMargins.top = 12

    return [
      titleModel,
      detailsModel,
      editModel
    ]
  }
}
