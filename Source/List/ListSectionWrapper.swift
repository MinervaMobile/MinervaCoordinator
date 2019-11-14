//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
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
		return section.description
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
		return section.identifier as NSString
	}
}
