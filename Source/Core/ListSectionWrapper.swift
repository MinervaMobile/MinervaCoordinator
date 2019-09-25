//
//  ListSectionWrapper.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

internal class ListSectionWrapper: NSObject {
  internal var section: ListSection

  internal init(section: ListSection) {
    self.section = section
  }
}

// MARK: - ListDiffable
extension ListSectionWrapper: ListDiffable {
  internal func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let wrapper = object as? ListSectionWrapper else {
      return false
    }
    return section == wrapper.section
  }

  internal func diffIdentifier() -> NSObjectProtocol {
    return section.identifier as NSString
  }
}
