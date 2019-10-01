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

  private let repository: WorkoutRepository

  private let filterSubject: BehaviorSubject<WorkoutFilter>
  var filter: Observable<WorkoutFilter> {
    filterSubject.asObservable()
  }

  private let failuresOnlySubject: BehaviorSubject<Bool>
  var failuresOnly: Observable<Bool> {
    failuresOnlySubject.asObservable()
  }

  var workouts: Observable<Result<[Workout], Error>> {
    return repository.workouts
  }

  var user: Observable<Result<User, Error>> {
    return repository.user
  }

  init(repository: WorkoutRepository) {
    self.repository = repository
    self.filterSubject = BehaviorSubject(value: WorkoutFilterProto())
    self.failuresOnlySubject = BehaviorSubject(value: false)
  }

  func apply(filter: WorkoutFilter) {
    filterSubject.onNext(filter)
  }

  func showFailuresOnly(_ showFailuresOnly: Bool) {
    failuresOnlySubject.onNext(showFailuresOnly)
  }
}
