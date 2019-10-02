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

final class WorkoutPresenter: DataSource {

  struct PersistentState {
    var title: String = ""
    var showFailuresOnly: Bool = false
    var filter: WorkoutFilter = WorkoutFilterProto()
  }

  struct TransientState {
    var error: Error? = nil
    var loading: Bool = false
  }

  private let sectionsSubject = BehaviorSubject<[ListSection]>(value: [])
  var sections: Observable<[ListSection]> {
    sectionsSubject.asObservable()
  }

  private let persistentStateSubject = BehaviorSubject(value: PersistentState())
  var persistentState: Observable<PersistentState> {
    persistentStateSubject.asObservable()
  }

  private let transientStateSubject = BehaviorSubject(value: TransientState())
  var transientState: Observable<TransientState> {
    transientStateSubject.asObservable()
  }

  private let interactor: WorkoutInteractor

  private let disposeBag = DisposeBag()

  private let queue = SerialDispatchQueueScheduler(
    queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive),
    internalSerialQueueName: "WorkoutPresenterQueue")

  // MARK: - Lifecycle

  init(interactor: WorkoutInteractor) {
    self.interactor = interactor

    Observable.combineLatest(
      interactor.workouts,
      interactor.user,
      interactor.filter,
      interactor.showFailuresOnly
    ).observeOn(
      queue
    ).subscribe(
      onNext: process(workoutsResult: userResult: filter: showFailuresOnly:)
    ).disposed(
      by: disposeBag
    )

    Observable.combineLatest(
      interactor.error,
      interactor.loading
    ).map {
      TransientState(error: $0.0, loading: $0.1)
    }.subscribe(
      transientStateSubject
    ).disposed(
      by: disposeBag
    )
  }

  // MARK: - Private

  private func process(
    workoutsResult: Result<[Workout], Error>,
    userResult: Result<User, Error>,
    filter: WorkoutFilter,
    showFailuresOnly: Bool
  ) {
    let user: User
    switch userResult {
    case .success(let u):
      user = u
    case .failure(let error):
      transientStateSubject.onNext(TransientState(error: error))
      return
    }

    let workouts: [Workout]
    switch workoutsResult {
    case .success(let w):
      workouts = w
    case .failure(let error):
      transientStateSubject.onNext(TransientState(error: error))
      return
    }

    let sections = createSections(
      with: filter,
      workouts: workouts,
      user: user,
      failuresOnly: showFailuresOnly
    )
    sectionsSubject.onNext(sections)

    let persistentState = PersistentState(
      title: user.email,
      showFailuresOnly: showFailuresOnly,
      filter: filter
    )
    persistentStateSubject.onNext(persistentState)

    let transientState = TransientState(
      error: nil,
      loading: false
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
      let totalCalories = workouts.reduce(0) { $0 + $1.calories }
      let failure = totalCalories > user.dailyCalories
      guard !failuresOnly || !failure else {
        continue
      }
      let section = createSection(
        date: date,
        workouts: workoutsForDate,
        user: user,
        failure: failure,
        sectionNumber: sections.count)
      sections.append(section)
    }

    return sections
  }

  private func createSection(
    date: Date,
    workouts: [Workout],
    user: User,
    failure: Bool,
    sectionNumber: Int
  ) -> ListSection {
    var cellModels = [ListCellModel]()
    let workoutBackgroundColor = failure
      ? UIColor(red: 179, green: 255, blue: 179) : UIColor(red: 255, green: 179, blue: 179)
    let sortedWorkoutsForDate = workouts.sorted { $0.date > $1.date }
    for workout in sortedWorkoutsForDate {
      let workoutCellModel = createWorkoutCellModel(for: workout)
      workoutCellModel.selectionAction = { [weak self] _, _ -> Void in
        guard let strongSelf = self else { return }
        strongSelf.interactor.edit(workout: workout)
      }
      workoutCellModel.backgroundColor = workoutBackgroundColor
      cellModels.append(workoutCellModel)
    }
    var section = ListSection(cellModels: cellModels, identifier: "WORKOUTS-\(sectionNumber)")

    let dateCellModel = LabelCellModel(text: DateFormatter.dateOnlyFormatter.string(from: date), font: .boldHeadline)
    dateCellModel.textColor = .darkGray
    dateCellModel.textAlignment = .left
    dateCellModel.topMargin = 10
    dateCellModel.bottomMargin = 10
    dateCellModel.backgroundColor = .white
    dateCellModel.bottomSeparatorColor = .separator
    cellModels.append(dateCellModel)
    section.headerModel = dateCellModel

    return section
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
