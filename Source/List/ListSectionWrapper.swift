//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

internal class ListSectionWrapper: NSObject {
  internal var section: ListSection

  internal init(section: ListSection) {
    self.section = section
  }

  override internal var description: String {
    section.description
  }
}

// MARK: - ListDiffable

extension ListSectionWrapper: ListDiffable {
  internal func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let wrapper = object as? ListSectionWrapper else {
      assertionFailure("Unknown object type \(object.debugDescription)")
      return false
    }
    return section == wrapper.section
  }

  internal func diffIdentifier() -> NSObjectProtocol {
    section.identifier as NSString
  }
}
