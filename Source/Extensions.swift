//
//  Extensions.swift
//  Minerva
//
//  Created by Joe Laws
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

extension Array {
  internal func at(_ index: Int) -> Element? {
    guard index >= 0, index < count else {
      return nil
    }
    return self[index]
  }
}

extension CGSize {
  internal func adjust(for insets: UIEdgeInsets) -> CGSize {
    return CGSize(
      width: width - insets.left - insets.right,
      height: height - insets.top - insets.bottom)
  }
}

extension Sequence {
  internal func asMap<T>(converter: @escaping (Iterator.Element) -> T) -> [T: Iterator.Element] {
    var map: [T: Iterator.Element] = [:]
    for element in self {
      let string = converter(element)
      map[string] = element
    }
    return map
  }
}

extension UICollectionView {
  internal var centerPoint: CGPoint {
    return CGPoint(
      x: center.x + contentOffset.x,
      y: center.y + contentOffset.y)
  }

  internal var centerCellIndexPath: IndexPath? {
    return indexPathForItem(at: centerPoint)
  }

  internal func isIndexPathAvailable(_ indexPath: IndexPath) -> Bool {
    guard dataSource != nil,
      indexPath.section < numberOfSections,
      indexPath.item < numberOfItems(inSection: indexPath.section) else {
        return false
    }
    return true
  }
}
