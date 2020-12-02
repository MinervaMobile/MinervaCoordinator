//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

internal enum ListExtensions {}

extension Array {
  internal func at(_ index: Int) -> Element? {
    guard index >= 0, index < count else { return nil }
    return self[index]
  }
}

extension Collection {
  internal func element(at index: Self.Index) -> Self.Iterator.Element? {
    guard index >= startIndex, index < endIndex else {
      return nil
    }
    return self[index]
  }
}

extension CGSize {
  internal func adjust(for insets: UIEdgeInsets) -> CGSize {
    CGSize(
      width: width - insets.left - insets.right,
      height: height - insets.top - insets.bottom
    )
  }
}

extension CGSize: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(width)
    hasher.combine(height)
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
    CGPoint(x: center.x + contentOffset.x, y: center.y + contentOffset.y)
  }

  internal var centerCellIndexPath: IndexPath? { indexPathForItem(at: centerPoint) }

  internal func isIndexPathAvailable(_ indexPath: IndexPath) -> Bool {
    guard
      dataSource != nil,
      indexPath.section < numberOfSections,
      indexPath.item < numberOfItems(inSection: indexPath.section)
    else {
      return false
    }
    return true
  }
}

extension UICollectionView.ScrollDirection: Hashable {}

extension UIEdgeInsets: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(top)
    hasher.combine(left)
    hasher.combine(bottom)
    hasher.combine(right)
  }
}
