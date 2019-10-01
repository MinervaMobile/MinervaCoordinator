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

  enum Action {
    case delete(workout: Workout)
    case edit(workout: Workout)
  }

  private(set) var sections: Observable<PresenterState>
  var actions: Observable<Action> {
    actionsSubject.asObservable()
  }

  private let actionsSubject: PublishSubject<Action>
  private let interactor: WorkoutInteractor

  // MARK: - Lifecycle

  init(interactor: WorkoutInteractor) {
    self.interactor = interactor
    self.actionsSubject = PublishSubject()
    self.sections = Observable.just(.loading)
    self.sections = self.sections.concat(
      Observable.combineLatest(
        interactor.user,
        interactor.workouts,
        interactor.failuresOnly,
        interactor.filter
      ).map { [weak self] (userResult, workoutsResult, failuresOnly, filter) -> PresenterState in
        guard let strongSelf = self else {
          return .failure(error: SystemError.cancelled)
        }
        let user: User
        switch userResult {
        case .success(let u):
          user = u
        case .failure(let error):
          return .failure(error: error)
        }

        let workouts: [Workout]
        switch workoutsResult {
        case .success(let w):
          workouts = w
        case .failure(let error):
          return .failure(error: error)
        }

        let sections = strongSelf.createSections(
          with: filter,
          workouts: workouts,
          user: user,
          failuresOnly: failuresOnly)
        return .loaded(sections: sections)
      }
    )
  }

  // MARK: - Private

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
          strongSelf.actionsSubject.onNext(.edit(workout: workout))
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
      strongSelf.actionsSubject.onNext(.delete(workout: workout))
    }
    cellModel.editAction = { [weak self] _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.actionsSubject.onNext(.edit(workout: workout))
    }
    return cellModel
  }

}
