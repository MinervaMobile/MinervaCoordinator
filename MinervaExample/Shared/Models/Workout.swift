//
//  Workout.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import SwiftProtobuf

protocol Workout: CustomStringConvertible {
  var workoutID: String { get }
  var userID: String { get }
  var text: String { get }
  var calories: Int32 { get }
  var date: Date { get }
}

extension Workout {
  var description: String {
    return proto.debugDescription
  }

  var proto: WorkoutProto {
    if let proto = self as? WorkoutProto {
      return proto
    } else {
      return WorkoutProto(
        workoutID: workoutID,
        userID: userID,
        text: text,
        calories: calories,
        date: date
      )
    }
  }

  var details: String {
    let timeString = DateFormatter.timeOnlyFormatter.string(from: date)
    let caloriesString = String(calories)
    return "\(caloriesString) calories @ \(timeString)"
  }
}

extension WorkoutProto: Workout {

  init(
    workoutID: String,
    userID: String,
    text: String,
    calories: Int32,
    date: Date
  ) {
    self.workoutID = workoutID
    self.userID = userID
    self.text = text
    self.calories = calories
    self.date = date
  }

  var date: Date {
    get { return dateTimestamp.date }
    set { dateTimestamp = Google_Protobuf_Timestamp(date: newValue) }
  }
}
