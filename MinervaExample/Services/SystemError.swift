//
//  SystemError.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

enum SystemError: LocalizedError {
  case alreadyExists
  case cancelled
  case doesNotExist
  case invalidEmail
  case invalidEmailAndPassword
  case networkError(statusCode: Int)
  case unauthorized
  case unknown

  var errorDescription: String? {
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

  var failureReason: String? {
    return nil
  }

  var recoverySuggestion: String? {
    return nil
  }

  var helpAnchor: String? {
    return nil
  }
}
