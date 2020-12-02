//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation

extension UserRole: CustomStringConvertible {
  public var description: String {
    switch self {
    case .admin: return "Admin"
    case .user: return "User"
    case .userManager: return "User Manager"
    }
  }

  public var userEditor: Bool {
    switch self {
    case .admin, .userManager: return true
    case .user: return false
    }
  }
}
