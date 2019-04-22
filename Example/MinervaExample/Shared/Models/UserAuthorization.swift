//
//  UserAuthorization.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

protocol UserAuthorization: CustomStringConvertible {
  var userID: String { get }
  var accessToken: String { get }
  var role: UserRole { get }
}

extension UserAuthorization {
  var description: String {
    return proto.debugDescription
  }

  var proto: UserAuthorizationProto {
    if let proto = self as? UserAuthorizationProto {
      return proto
    } else {
      return UserAuthorizationProto(
        userID: userID,
        accessToken: accessToken,
        role: role
      )
    }
  }
}

extension UserAuthorizationProto: UserAuthorization {

  init(
    userID: String,
    accessToken: String,
    role: UserRole
  ) {
    self.userID = userID
    self.accessToken = accessToken
    self.role = role
  }
}

