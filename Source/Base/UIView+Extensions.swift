//
//  Extensions.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

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
