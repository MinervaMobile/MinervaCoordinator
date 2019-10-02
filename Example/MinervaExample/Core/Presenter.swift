//
//  RxSwiftDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import Minerva
import RxSwift

public protocol PresenterPersistentState {
  var sections: [ListSection] { get }
}

public protocol PresenterTransientState {
  var error: Error? { get }
}

public protocol Presenter: DataSource {
  associatedtype PersistentState: PresenterPersistentState
  associatedtype TransientState: PresenterTransientState

  var persistentState: Observable<PersistentState> { get }
  var transientState: Observable<TransientState> { get }
}
