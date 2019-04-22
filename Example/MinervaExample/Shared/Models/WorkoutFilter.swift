//
//  WorkoutFilter.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import SwiftProtobuf

typealias FilterType = WorkoutFilterProto.FilterType

extension FilterType: CustomStringConvertible {

  var description: String {
    switch self {
    case .endDate: return "End Date"
    case .endTime: return "End Time"
    case .startDate: return "Start Date"
    case .startTime: return "Start Time"
    }
  }
}

protocol WorkoutFilter: CustomStringConvertible {

  var startDate: Date? { get }
  var endDate: Date? { get }
  var startTime: Date? { get }
  var endTime: Date? { get }

}

extension WorkoutFilter {
  var description: String {
    return proto.debugDescription
  }

  var proto: WorkoutFilterProto {
    if let proto = self as? WorkoutFilterProto {
      return proto
    } else {
      return WorkoutFilterProto(startDate: startDate, endDate: endDate, startTime: startTime, endTime: endTime)
    }
  }

  var details: String {
    var text = ""
    if startDate != nil || endDate != nil || startTime != nil || endTime != nil {
      text += "Workouts "
    }
    if let startDate = startDate {
      text += "since "
      text += DateFormatter.dateOnlyFormatter.string(from: startDate)
      text += " "
    }
    if let endDate = endDate {
      text += "until "
      text += DateFormatter.dateOnlyFormatter.string(from: endDate)
    }
    if (startDate != nil || endDate != nil) && (startTime != nil || endTime != nil) {
      text += ",\n"
    }
    if let startTime = startTime {
      if endTime == nil {
        text += "after "
      } else {
        text += "between "
      }
      text += DateFormatter.timeOnlyFormatter.string(from: startTime)
      text += " "
    }
    if let endTime = endTime {
      if startTime == nil {
        text += "until "
      } else {
        text += "and "
      }
      text += DateFormatter.timeOnlyFormatter.string(from: endTime)
    }
    guard !text.isEmpty else {
      return "Displaying all workouts."
    }
    return text
  }

  func date(for filterType: FilterType) -> Date? {
    switch filterType {
    case .endDate: return endDate
    case .endTime: return endTime
    case .startDate: return startDate
    case .startTime: return startTime
    }
  }

  func details(for filterType: FilterType) -> String? {
    switch filterType {
    case .endDate:
      if let endDate = self.endDate {
        return DateFormatter.dateOnlyFormatter.string(from: endDate)
      }
    case .endTime:
      if let endTime = self.endTime {
        return DateFormatter.timeOnlyFormatter.string(from: endTime)
      }
    case .startDate:
      if let startDate = self.startDate {
        return DateFormatter.dateOnlyFormatter.string(from: startDate)
      }
    case .startTime:
      if let startTime = self.startTime {
        return DateFormatter.timeOnlyFormatter.string(from: startTime)
      }
    }
    return nil
  }

  func shouldInclude(workout: Workout) -> Bool {
    let calendar = Calendar.current
    if startDate != nil || endDate != nil {
      let workoutDate = calendar.startOfDay(for: workout.date)
      if let startDate = self.startDate, calendar.startOfDay(for: startDate) > workoutDate {
        return false
      }
      if let endDate = self.endDate, calendar.startOfDay(for: endDate) < workoutDate {
        return false
      }
    }
    if startTime != nil || endTime != nil {
      let workoutComponents = calendar.dateComponents([.hour, .minute, .second], from: workout.date)
      if let startTime = self.startTime {
        if workoutComponents.compareTime(with: startTime) == .orderedAscending {
          return false
        }
      }
      if let endTime = self.endTime {
        if workoutComponents.compareTime(with: endTime) == .orderedDescending {
          return false
        }
      }
    }
    return true
  }
}

extension WorkoutFilterProto: WorkoutFilter {

  init(
    startDate: Date?,
    endDate: Date?,
    startTime: Date?,
    endTime: Date?
  ) {
    self.startDate = startDate
    self.endDate = endDate
    self.startTime = startTime
    self.endTime = endTime
  }

  var startDate: Date? {
    get { return hasStartDateTimestamp ? startDateTimestamp.date : nil }
    set {
      if let date = newValue {
        self.startDateTimestamp = Google_Protobuf_Timestamp(date: date)
      } else {
        clearStartDateTimestamp()
      }
    }
  }

  var endDate: Date? {
    get { return hasEndDateTimestamp ? endDateTimestamp.date : nil }
    set {
      if let date = newValue {
        self.endDateTimestamp = Google_Protobuf_Timestamp(date: date)
      } else {
        clearEndDateTimestamp()
      }
    }
  }

  var startTime: Date? {
    get { return hasStartTimeTimestamp ? startTimeTimestamp.date : nil }
    set {
      if let date = newValue {
        self.startTimeTimestamp = Google_Protobuf_Timestamp(date: date)
      } else {
        clearStartTimeTimestamp()
      }
    }
  }

  var endTime: Date? {
    get { return hasEndTimeTimestamp ? endTimeTimestamp.date : nil }
    set {
      if let date = newValue {
        self.endTimeTimestamp = Google_Protobuf_Timestamp(date: date)
      } else {
        clearEndTimeTimestamp()
      }
    }
  }
}
