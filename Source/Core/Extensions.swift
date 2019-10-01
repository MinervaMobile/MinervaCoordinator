//
//  Extensions.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

internal enum Extensions { }

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

extension UICollectionView.ScrollDirection: Hashable { }

extension UIEdgeInsets: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(top)
    hasher.combine(left)
    hasher.combine(bottom)
    hasher.combine(right)
  }
}

extension UILayoutPriority {
  internal static var notRequired: UILayoutPriority {
    return UILayoutPriority.required - 1
  }
}

extension UIView {

  internal func anchorToTopSafeAreaLayoutGuide(in view: UIView) {
    // This allows the view to scroll past the bottom safe area if collection view
    // extends to the bottom of the view
    let layoutGuide = view.safeAreaLayoutGuide
    anchor(
      toLeading: view.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: view.trailingAnchor,
      bottom: view.bottomAnchor)
  }

  internal func anchor(
    toLeading leading: NSLayoutXAxisAnchor?,
    top: NSLayoutYAxisAnchor?,
    trailing: NSLayoutXAxisAnchor?,
    bottom: NSLayoutYAxisAnchor?
  ) {
    if let leading = leading {
      leadingAnchor.constraint(equalTo: leading).isActive = true
    }
    if let top = top {
      topAnchor.constraint(equalTo: top).isActive = true
    }
    if let trailing = trailing {
      trailingAnchor.constraint(equalTo: trailing).isActive = true
    }
    if let bottom = bottom {
      bottomAnchor.constraint(equalTo: bottom).isActive = true
    }
  }

  internal func anchorTo(layoutGuide: UILayoutGuide) {
    anchor(
      toLeading: layoutGuide.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: layoutGuide.trailingAnchor,
      bottom: layoutGuide.bottomAnchor)
  }

  internal func anchor(to view: UIView) {
    anchor(
      toLeading: view.leadingAnchor,
      top: view.topAnchor,
      trailing: view.trailingAnchor,
      bottom: view.bottomAnchor)
  }

  internal func anchorHeight(to height: CGFloat) {
    heightAnchor.constraint(equalToConstant: height).isActive = true
  }

  internal func anchorWidth(to width: CGFloat) {
    widthAnchor.constraint(equalToConstant: width).isActive = true
  }

  internal func shouldTranslateAutoresizingMaskIntoConstraints(_ value: Bool) {
    self.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = value }
  }
}
