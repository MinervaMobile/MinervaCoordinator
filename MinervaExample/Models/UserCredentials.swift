//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation

public protocol UserCredentials: CustomStringConvertible {
  var email: String { get }
  var password: String { get }
}

extension UserCredentials {
  public var description: String {
    return proto.debugDescription
  }

  public var proto: UserCredentialsProto {
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

  public init(
    email: String,
    password: String
  ) {
    self.email = email
    self.password = password
  }
}
