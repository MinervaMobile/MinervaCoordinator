//
//  DataSource.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

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

public protocol DataSource: AnyObject {
  var updateDelegate: DataSourceUpdateDelegate? { get set }
}
