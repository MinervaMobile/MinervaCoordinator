//
//  ListViewLayout.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import IGListKit
import UIKit

/// The base layout that should be used for any collection view controlled by Minerva.
/// TODO: Remove this dependency on IGListKit's ListCollectionViewLayout
open class ListViewLayout: ListCollectionViewLayout {

	override public class var layoutAttributesClass: AnyClass {
		return ListViewLayoutAttributes.self
	}
}
