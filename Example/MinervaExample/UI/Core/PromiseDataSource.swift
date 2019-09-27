//
//  BaseDataSource.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

public protocol DataSourceUpdateDelegate: AnyObject {
  typealias Completion = (Bool) -> Void

  func dataSourceStartedUpdate(_ dataSource: DataSource)
  func dataSource(_ dataSource: DataSource, encountered error: Error)
  func dataSource(
    _ dataSource: DataSource,
    update sections: [ListSection],
    animated: Bool,
    completion: Completion?
  )
  func dataSourceCompletedUpdate(_ dataSource: DataSource)
}

extension DataSourceUpdateDelegate {
  public func dataSource(
    _ dataSource: DataSource,
    process promise: Promise<[ListSection]>,
    animated: Bool,
    completion: Completion?
  ) {
    dataSourceStartedUpdate(dataSource)
    promise.done { [weak self, weak dataSource] sections in
      guard let strongSelf = self, let strongDataSource = dataSource else { return }
      strongSelf.dataSource(strongDataSource, update: sections, animated: animated, completion: completion)
    }.catch { [weak self, weak dataSource] error in
      guard let strongSelf = self, let strongDataSource = dataSource else { return }
      strongSelf.dataSource(strongDataSource, encountered: error)
      completion?(false)
    }.finally { [weak self, weak dataSource] in
      guard let strongSelf = self, let strongDataSource = dataSource else { return }
      strongSelf.dataSourceCompletedUpdate(strongDataSource)
    }
  }
}

public protocol PromiseDataSource: DataSource {
  var updateDelegate: DataSourceUpdateDelegate? { get set }
}

open class BaseDataSource: NSObject, PromiseDataSource {

  public weak var updateDelegate: DataSourceUpdateDelegate?

}
