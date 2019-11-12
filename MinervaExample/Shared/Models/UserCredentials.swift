//
//  UserCredentials.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

protocol UserCredentials: CustomStringConvertible {
  var email: String { get }
  var password: String { get }
}

extension UserCredentials {
  var description: String {
    return proto.debugDescription
  }

  var proto: UserCredentialsProto {
    if let proto = self as? UserCredentialsProto {
      return proto
    } else {
      return UserCredentialsProto(
        email: email,
        password: password
      )
    }
  }
}

extension UserCredentialsProto: UserCredentials {

  init(
    email: String,
    password: String
  ) {
    self.email = email
    self.password = password
  }
}
