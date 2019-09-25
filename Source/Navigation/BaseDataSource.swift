//
//  BaseDataSource.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class BaseDataSource: NSObject, DataSource {

  public weak var updateDelegate: DataSourceUpdateDelegate?

}
