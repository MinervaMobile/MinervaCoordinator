//
//  WorkoutPresenter.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import RxSwift

final class WorkoutPresenter: Presenter {

  typealias PersistentState = Persistent
  typealias TransientState = Transient

  struct Persistent: PresenterPersistentState {
    var sections: [ListSection] = []
    var title: String = ""
    var showFailuresOnly: Bool = false
    var filter: WorkoutFilter = WorkoutFilterProto()
  }

  struct Transient: PresenterTransientState {
    var error: Error? = nil
    var showLoadingHUD: Bool = false
    var hideLoadingHUD: Bool = false
  }

  private let persistentStateSubject: BehaviorSubject<PersistentState>
  var persistentState: Observable<PersistentState> {
    persistentStateSubject.asObservable()
  }

  private let transientStateSubject: BehaviorSubject<TransientState>
  var transientState: Observable<TransientState> {
    transientStateSubject.asObservable()
  }

  private let interactor: WorkoutInteractor

  private let disposeBag = DisposeBag()

  // MARK: - Lifecycle

  init(interactor: WorkoutInteractor) {
    self.interactor = interactor
    self.persistentStateSubject = BehaviorSubject(value: Persistent())
    self.transientStateSubject = BehaviorSubject(value: Transient())

    interactor.state
      .observeOn(
        SerialDispatchQueueScheduler(
          queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive),
          internalSerialQueueName: "userInteractive")
      ).subscribe(
        onNext: process(_:),
        onError: nil,
        onCompleted: nil,
        onDisposed: nil
      ).disposed(by: disposeBag)
  }

  // MARK: - Private

  private func process(_ state: WorkoutInteractor.State) {
    guard let user = state.user else {
      transientStateSubject.onNext(TransientState(error: SystemError.doesNotExist))
      return
    }

    let sections = createSections(
      with: state.filter,
      workouts: state.workouts,
      user: user,
      failuresOnly: state.showFailuresOnly)
    let persistentState = PersistentState(
      sections: sections,
      title: user.email,
      showFailuresOnly: state.showFailuresOnly,
      filter: state.filter)
    persistentStateSubject.onNext(persistentState)

    let transientState = TransientState(
      error: state.error,
      showLoadingHUD: state.showLoadingHUD,
      hideLoadingHUD: state.hideLoadingHUD
    )
    transientStateSubject.onNext(transientState)
  }

  private func createSections(
    with filter: WorkoutFilter,
    workouts: [Workout],
    user: User,
    failuresOnly: Bool
  ) -> [ListSection] {
    var sections = [ListSection]()

    let filterCellModel = LabelCellModel(text: filter.details, font: .subheadline)
    filterCellModel.textColor = .darkGray
    filterCellModel.textAlignment = .right
    filterCellModel.topMargin = 10
    filterCellModel.bottomMargin = 10
    filterCellModel.backgroundColor = .section
    filterCellModel.bottomSeparatorColor = .separator
    sections.append(ListSection(cellModels: [filterCellModel], identifier: "FILTER"))

    let calendar = Calendar.current
    let filteredWorkouts = workouts.filter { filter.shouldInclude(workout: $0) }
    let workoutGroups = filteredWorkouts.group { workout -> Date in
      calendar.startOfDay(for: workout.date)
    }
    let sortedGroups = workoutGroups.sorted { $0.key > $1.key }
    for (date, workoutsForDate) in sortedGroups {
      var cellModels = [ListCellModel]()
      let totalCalories = workoutsForDate.reduce(0) { $0 + $1.calories }
      let failure = totalCalories > user.dailyCalories
      guard !failuresOnly || !failure else {
        continue
      }
      let workoutBackgroundColor = failure
        ? UIColor(red: 179, green: 255, blue: 179) : UIColor(red: 255, green: 179, blue: 179)
      let sortedWorkoutsForDate = workoutsForDate.sorted { $0.date > $1.date }
      for workout in sortedWorkoutsForDate {
        let workoutCellModel = createWorkoutCellModel(for: workout)
        workoutCellModel.selectionAction = { [weak self] _, _ -> Void in
          guard let strongSelf = self else { return }
          strongSelf.interactor.edit(workout: workout)
        }
        workoutCellModel.backgroundColor = workoutBackgroundColor
        cellModels.append(workoutCellModel)
      }
      var section = ListSection(cellModels: cellModels, identifier: "WORKOUTS-\(sections.count)")

      let dateCellModel = LabelCellModel(text: DateFormatter.dateOnlyFormatter.string(from: date), font: .boldHeadline)
      dateCellModel.textColor = .darkGray
      dateCellModel.textAlignment = .left
      dateCellModel.topMargin = 10
      dateCellModel.bottomMargin = 10
      dateCellModel.backgroundColor = .white
      dateCellModel.bottomSeparatorColor = .separator
      cellModels.append(dateCellModel)
      section.headerModel = dateCellModel

      sections.append(section)
    }

    return sections
  }

  private func createWorkoutCellModel(for workout: Workout) -> SwipeableLabelCellModel {
    let cellModel = SwipeableLabelCellModel(
      identifier: workout.description,
      title: workout.details,
      details: workout.text)
    cellModel.bottomSeparatorColor = .separator
    cellModel.bottomSeparatorLeftInset = true
    cellModel.deleteAction = { [weak self] _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.interactor.delete(workout: workout)
    }
    cellModel.editAction = { [weak self] _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.interactor.edit(workout: workout)
    }
    return cellModel
  }

}
