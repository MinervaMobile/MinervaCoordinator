//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation

public protocol User: CustomStringConvertible {
  var userID: String { get }
  var email: String { get }
  var dailyCalories: Int32 { get }
}

extension User {
  public var description: String {
    return proto.debugDescription
  }

  public var proto: UserProto {
    if let proto = self as? UserProto {
      return proto
    } else {
      return UserProto(
        userID: userID,
        email: email,
        dailyCalories: dailyCalories
      )
    }
  }
}

extension UserProto: User {

  public init(
    userID: String,
    email: String,
    dailyCalories: Int32
  ) {
    self.userID = userID
    self.email = email
    self.dailyCalories = dailyCalories
  }
}
