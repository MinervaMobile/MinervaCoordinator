//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation

public enum SystemError: LocalizedError {
  case alreadyExists
  case cancelled
  case doesNotExist
  case invalidEmail
  case invalidEmailAndPassword
  case networkError(statusCode: Int)
  case unauthorized
  case unknown

  public var errorDescription: String? {
    switch self {
    case .alreadyExists: return "A user already exists with that email"
    case .cancelled: return "Cancelled"
    case .doesNotExist: return "User does not exist"
    case .invalidEmail: return "The email you entered is not valid"
    case .invalidEmailAndPassword: return "Invalid email or password combination"
    case .networkError(let statusCode): return "Network Error: \(statusCode)"
    case .unauthorized: return "Not Authorized"
    case .unknown: return "Unknown error"
    }
  }

  public var failureReason: String? {
    nil
  }

  public var recoverySuggestion: String? {
    nil
  }

  public var helpAnchor: String? {
    nil
  }
}
