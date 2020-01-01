//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation

private enum FoundationExtensions { }

extension Array {
  public var isNotEmpty: Bool {
    return !self.isEmpty
  }

  public func at(_ index: Int) -> Element? {
    guard index >= 0, index < self.count else {
      return nil
    }
    return self[index]
  }
}

extension DateComponents {

  public func compareTime(with date: Date, calendar: Calendar = Calendar.current) -> ComparisonResult {
    let otherComponents = calendar.dateComponents([.hour, .minute, .second], from: date)
    guard let firstHour = hour,
      let secondHour = otherComponents.hour,
      let firstMinutes = minute,
      let secondMinutes = otherComponents.minute,
      let firstSeconds = second,
      let secondSeconds = otherComponents.second else {
        assertionFailure("Invalid date components.")
        return .orderedSame
    }

    let firstTime = firstHour * 360 + firstMinutes * 60 + firstSeconds
    let secondTime = secondHour * 360 + secondMinutes * 60 + secondSeconds

    if firstTime < secondTime {
      return .orderedAscending
    } else if firstTime > secondTime {
      return .orderedDescending
    } else {
      return .orderedSame
    }
  }
}

extension DateFormatter {
  public static let dateOnlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
  }()
  public static let timeOnlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }()
  public static let dateAndTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
  }()
  public static let RFC3339DateFormatter: DateFormatter = {
    let RFC3339DateFormatter = DateFormatter()
    RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
    RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return RFC3339DateFormatter
  }()
}

extension Sequence {
  public func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
    var categories: [U: [Iterator.Element]] = [:]
    for element in self {
      let key = key(element)
      var items = categories[key, default: []]
      items.append(element)
      categories[key] = items
    }
    return categories
  }
  public func asMap<T>(converter: @escaping (Iterator.Element) -> T) -> [T: Iterator.Element] {
    var map: [T: Iterator.Element] = [:]
    for element in self {
      let string = converter(element)
      map[string] = element
    }
    return map
  }
}

extension String {
  public var isEmail: Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self)
  }
}
