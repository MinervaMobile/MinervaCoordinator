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

public final class WorkoutPresenter: Presenter {

  public enum Action {
    case createWorkout(userID: String)
    case editFilter
    case editWorkout(Workout)
  }

  public struct PersistentState {
    public var title: String = ""
    public var filter: WorkoutFilter = WorkoutFilterProto()
  }

  public struct TransientState {
    public var error: Error?
    public var loading: Bool = false
  }

  private let actionsRelay = PublishRelay<Action>()
  public var actions: Observable<Action> { actionsRelay.asObservable() }

  public var sections = BehaviorRelay<[ListSection]>(value: [])

  private let persistentStateSubject = BehaviorSubject(value: PersistentState())
  public var persistentState: Observable<PersistentState> { persistentStateSubject.asObservable() }

  private let transientStateSubject = PublishSubject<TransientState>()
  public var transientState: Observable<TransientState> { transientStateSubject.asObservable() }

  private let filterSubject = BehaviorSubject<WorkoutFilter>(value: WorkoutFilterProto())
  public var filter: Observable<WorkoutFilter> { filterSubject.asObservable() }
  private let errorSubject = BehaviorSubject<Error?>(value: nil)
  private let loadingSubject = BehaviorSubject<Bool>(value: false)

  private let repository: WorkoutRepository
  private let disposeBag = DisposeBag()
  private let queue = SerialDispatchQueueScheduler(
    queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive),
    internalSerialQueueName: "WorkoutPresenterQueue")

  // MARK: - Lifecycle

  public init(repository: WorkoutRepository) {
    self.repository = repository

    Observable.combineLatest(
      repository.workouts,
      repository.user,
      filterSubject.asObservable()
    ).observeOn(
      queue
    ).subscribe(
      onNext: process(workoutsResult: userResult: filter:)
    ).disposed(
      by: disposeBag
    )

    Observable.combineLatest(
      errorSubject.asObservable().distinctUntilChanged({ $0 == nil && $1 == nil }),
      loadingSubject.asObservable().distinctUntilChanged()
    ).map {
      TransientState(error: $0.0, loading: $0.1)
    }.subscribe(
      transientStateSubject
    ).disposed(
      by: disposeBag
    )
  }

  public func apply(filter: WorkoutFilter) {
    filterSubject.onNext(filter)
  }

  public func editFilter() {
    actionsRelay.accept(.editFilter)
  }

  public func createWorkout() {
    actionsRelay.accept(.createWorkout(userID: repository.userID))
  }

  public func edit(workout: Workout) {
    actionsRelay.accept(.editWorkout(workout))
  }

  public func delete(workout: Workout) {
    loadingSubject.onNext(true)
    repository.delete(workout).subscribe { [weak self] event in
      guard let strongSelf = self else { return }
      switch event {
      case .error(let error):
        strongSelf.errorSubject.onNext(error)
      case .success:
        break
      }
      strongSelf.loadingSubject.onNext(false)
    }.disposed(by: disposeBag)
  }

  // MARK: - Private

  private func process(
    workoutsResult: Result<[Workout], Error>,
    userResult: Result<User, Error>,
    filter: WorkoutFilter
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
      user: user
    )
    self.sections.accept(sections)

    let persistentState = PersistentState(title: user.email, filter: filter)
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
    user: User
  ) -> [ListSection] {
    var sections = [ListSection]()

    let filterCellModel = LabelCellModel(text: filter.details, font: .subheadline)
    filterCellModel.textColor = .darkGray
    filterCellModel.textAlignment = .right
    filterCellModel.directionalLayoutMargins.top = 10
    filterCellModel.directionalLayoutMargins.bottom = 10
    filterCellModel.backgroundColor = .section
    sections.append(ListSection(cellModels: [filterCellModel], identifier: "FILTER"))

    let calendar = Calendar.current
    let filteredWorkouts = workouts.filter { filter.shouldInclude(workout: $0) }
    let workoutGroups = filteredWorkouts.group { workout -> Date in
      calendar.startOfDay(for: workout.date)
    }
    let sortedGroups = workoutGroups.sorted { $0.key > $1.key }
    for (date, workoutsForDate) in sortedGroups {
      let totalCalories = workoutsForDate.reduce(0) { $0 + $1.calories }
      let failure = totalCalories < user.dailyCalories
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
      ? UIColor(red: 255, green: 179, blue: 179) : UIColor(red: 179, green: 255, blue: 179)
    let sortedWorkoutsForDate = workouts.sorted { $0.date > $1.date }
    for workout in sortedWorkoutsForDate {
      let workoutCellModel = createWorkoutCellModel(for: workout)
      workoutCellModel.selectionAction = { [weak self] _, _ -> Void in
        guard let strongSelf = self else { return }
        strongSelf.edit(workout: workout)
      }
      workoutCellModel.backgroundColor = workoutBackgroundColor
      cellModels.append(workoutCellModel)
    }
    var section = ListSection(cellModels: cellModels, identifier: "WORKOUTS-\(sectionNumber)")

    let dateCellModel = LabelCellModel(
      text: DateFormatter.dateOnlyFormatter.string(from: date),
      font: UIFont.headline.bold)
    dateCellModel.textColor = .darkGray
    dateCellModel.textAlignment = .left
    dateCellModel.directionalLayoutMargins.top = 10
    dateCellModel.directionalLayoutMargins.bottom = 10
    dateCellModel.backgroundColor = .white
    cellModels.append(dateCellModel)
    section.headerModel = dateCellModel

    return section
  }

  private func createWorkoutCellModel(for workout: Workout) -> SwipeableLabelCellModel {
    let cellModel = SwipeableLabelCellModel(
      identifier: workout.description,
      attributedText: NSAttributedString(string: "\(workout.details)\n\(workout.text)")
    )

    cellModel.deleteAction = { [weak self] _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delete(workout: workout)
    }
    return cellModel
  }

}
