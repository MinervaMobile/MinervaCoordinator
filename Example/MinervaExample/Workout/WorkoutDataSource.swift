//
//  WorkoutDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

protocol WorkoutDataSourceDelegate: AnyObject {
  func workoutDataSource(_ workoutDataSource: WorkoutDataSource, selected action: WorkoutDataSource.Action)
}

final class WorkoutDataSource {

  enum Action {
    case delete(workout: Workout)
    case edit(workout: Workout)
  }
  weak var delegate: WorkoutDataSourceDelegate?

  private let dataManager: DataManager
  private let userID: String

  // MARK: - Lifecycle

  init(userID: String, dataManager: DataManager) {
    self.userID = userID
    self.dataManager = dataManager
  }

  // MARK: - Public

  func loadTitle() -> Promise<String> {
    return dataManager.loadUser(withID: userID).then { user -> Promise<String> in
      guard let user = user else { return .init(error: SystemError.doesNotExist) }
      return .value(user.email)
    }
  }

  func loadSections(with filter: WorkoutFilter) -> Promise<[ListSection]> {
    return when(
      fulfilled: dataManager.loadWorkouts(forUserID: userID),
      dataManager.loadUser(withID: userID)
    ).then { [weak self] workouts, user -> Promise<[ListSection]> in
      guard let strongSelf = self else { return .init(error: SystemError.cancelled) }
      guard let user = user else { return .init(error: SystemError.doesNotExist) }
      let sections = strongSelf.createSections(with: filter, workouts: workouts, user: user)
      return .value(sections)
    }
  }

  // MARK: - Private

  private func createSections(with filter: WorkoutFilter, workouts: [Workout], user: User) -> [ListSection] {
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
      let workoutBackgroundColor = totalCalories < user.dailyCalories
        ? UIColor(red: 179, green: 255, blue: 179) : UIColor(red: 255, green: 179, blue: 179)
      let sortedWorkoutsForDate = workoutsForDate.sorted { $0.date > $1.date }
      for workout in sortedWorkoutsForDate {
        let workoutCellModel = createWorkoutCellModel(for: workout)
        workoutCellModel.selectionAction = { [weak self] _, _ -> Void in
          guard let strongSelf = self else { return }
          strongSelf.delegate?.workoutDataSource(strongSelf, selected: .edit(workout: workout))
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
      strongSelf.delegate?.workoutDataSource(strongSelf, selected: .delete(workout: workout))
    }
    cellModel.editAction = { [weak self] _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.workoutDataSource(strongSelf, selected: .edit(workout: workout))
    }
    return cellModel
  }

}
