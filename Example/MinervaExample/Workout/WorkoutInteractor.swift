//
//  WorkoutInteractor.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import RxSwift

final class WorkoutInteractor {

  enum Action {
    case createWorkout(userID: String)
    case edit(workout: Workout)
    case update(filter: WorkoutFilter)
  }

  private let disposeBag = DisposeBag()
  private let repository: WorkoutRepository

  private let filterSubject = BehaviorSubject<WorkoutFilter>(value: WorkoutFilterProto())
  var filter: Observable<WorkoutFilter> { filterSubject.asObservable() }

  private let showFailuresOnlySubject = BehaviorSubject<Bool>(value: false)
  var showFailuresOnly: Observable<Bool> { showFailuresOnlySubject.asObservable().distinctUntilChanged() }

  private let errorSubject = BehaviorSubject<Error?>(value: nil)
  var error: Observable<Error?> { errorSubject.asObservable().distinctUntilChanged({ $0 == nil && $1 == nil }) }

  private let loadingSubject = BehaviorSubject<Bool>(value: false)
  var loading: Observable<Bool> { loadingSubject.asObservable().distinctUntilChanged() }

  var workouts: Observable<Result<[Workout], Error>> { repository.workouts }
  var user: Observable<Result<User, Error>> { repository.user }

  private let actionsSubject = PublishSubject<Action>()
  var actions: Observable<Action> {
    actionsSubject.asObservable()
  }

  // MARK: - Lifecyle

  init(repository: WorkoutRepository) {
    self.repository = repository
  }

  // MARK: - Public

  func apply(filter: WorkoutFilter) {
    filterSubject.onNext(filter)
  }

  func showFailuresOnly(_ showFailuresOnly: Bool) {
    showFailuresOnlySubject.onNext(showFailuresOnly)
  }

  func createWorkout() {
    actionsSubject.onNext(.createWorkout(userID: repository.userID))
  }

  func edit(workout: Workout) {
    actionsSubject.onNext(.edit(workout: workout))
  }

  func delete(workout: Workout) {
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

  func updateFilter(with filter: WorkoutFilter) {
    actionsSubject.onNext(.update(filter: filter))
  }

  func clearTransientState() {
    loadingSubject.onNext(false)
    errorSubject.onNext(nil)
  }
}
