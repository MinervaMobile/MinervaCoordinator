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

  struct State {
    var workouts: [Workout]
    var user: User?
    var filter: WorkoutFilter
    var showFailuresOnly: Bool
    var error: Error?
    var showLoadingHUD: Bool
    var hideLoadingHUD: Bool
  }

  private let disposeBag = DisposeBag()
  private let repository: WorkoutRepository

  private let filterSubject = BehaviorSubject<WorkoutFilter>(value: WorkoutFilterProto())
  private let showFailuresOnlySubject = BehaviorSubject<Bool>(value: false)
  private let errorSubject = BehaviorSubject<Error?>(value: nil)
  private let showLoadingHUDSubject = BehaviorSubject<Bool>(value: false)
  private let hideLoadingHUDSubject = BehaviorSubject<Bool>(value: false)

  private var transientStateClear: Bool = true

  var state: Observable<State> {
    return Observable.combineLatest(
      repository.workouts,
      repository.user,
      filterSubject,
      showFailuresOnlySubject,
      errorSubject,
      showLoadingHUDSubject,
      hideLoadingHUDSubject
    ).map { [weak self] (workoutsResult, userResult, filter, showFailuresOnly, error, showLoadingHUD, hideLoadingHUD) -> State in
      var error = error
      let user: User?
      switch userResult {
      case .success(let u):
        user = u
      case .failure(let e):
        error = error ?? e
        user = nil
      }

      let workouts: [Workout]
      switch workoutsResult {
      case .success(let w):
        workouts = w
      case .failure(let e):
        workouts = []
        error = error ?? e
      }
      self?.transientStateClear = error == nil && !showLoadingHUD && !hideLoadingHUD
      return State(
        workouts: workouts,
        user: user,
        filter: filter,
        showFailuresOnly: showFailuresOnly,
        error: error,
        showLoadingHUD: showLoadingHUD,
        hideLoadingHUD: hideLoadingHUD)
    }
  }

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
    showLoadingHUDSubject.onNext(true)
    repository.delete(workout).subscribe { [weak self] event in
      guard let strongSelf = self else { return }
      switch event {
      case .error(let error):
        strongSelf.errorSubject.onNext(error)
      case .success:
        break
      }
      strongSelf.hideLoadingHUDSubject.onNext(true)
    }.disposed(by: disposeBag)
  }

  func updateFilter(with filter: WorkoutFilter) {
    actionsSubject.onNext(.update(filter: filter))
  }

  func clearTransientState() {
    guard !transientStateClear else {
      return
    }
    showLoadingHUDSubject.onNext(false)
    hideLoadingHUDSubject.onNext(false)
    errorSubject.onNext(nil)
  }
}
