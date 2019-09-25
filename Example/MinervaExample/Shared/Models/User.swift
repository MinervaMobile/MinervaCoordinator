//
//  User.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

protocol User: CustomStringConvertible {
  var userID: String { get }
  var email: String { get }
  var dailyCalories: Int32 { get }
}

extension User {
  var description: String {
    return proto.debugDescription
  }

  var proto: UserProto {
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

  init(
    userID: String,
    email: String,
    dailyCalories: Int32
  ) {
    self.userID = userID
    self.email = email
    self.dailyCalories = dailyCalories
  }
}
