//
//  RxSwiftDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import Minerva
import RxSwift

public enum PresenterState {
  case loading
  case failure(error: Error)
  case loaded(sections: [ListSection])
}

public protocol Presenter: DataSource {
  var sections: Observable<PresenterState> { get }
}
