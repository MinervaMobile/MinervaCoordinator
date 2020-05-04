//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

internal enum CellExtensions {}

extension NSAttributedString {
  internal convenience init(string: String, font: UIFont, fontColor: UIColor) {
    self.init(
      string: string,
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: fontColor
      ]
    )
  }
  internal func height(constraintedToWidth width: CGFloat) -> CGFloat {
    let size = CGSize(width: width, height: .greatestFiniteMagnitude)
    let rect = self.boundingRect(
      with: size,
      options: [.usesFontLeading, .usesLineFragmentOrigin],
      context: nil
    )
    let height = rect.size.height
    return ceil(height)
  }
  internal func width(constraintedToHeight height: CGFloat) -> CGFloat {
    let size = CGSize(width: .greatestFiniteMagnitude, height: height)
    let rect = self.boundingRect(
      with: size,
      options: [.usesFontLeading, .usesLineFragmentOrigin],
      context: nil
    )

    let width = rect.size.width
    return ceil(width)
  }
}

extension String {
  internal func height(constraintedToWidth width: CGFloat, font: UIFont) -> CGFloat {
    let string = self as NSString
    let size = CGSize(width: width, height: .greatestFiniteMagnitude)
    let rect = string.boundingRect(
      with: size,
      options: [.usesFontLeading, .usesLineFragmentOrigin],
      attributes: [NSAttributedString.Key.font: font],
      context: nil
    )
    let height = rect.size.height
    return ceil(height)
  }
  internal func width(constraintedToHeight height: CGFloat, font: UIFont) -> CGFloat {
    let string = self as NSString
    let size = CGSize(width: .greatestFiniteMagnitude, height: height)
    let rect = string.boundingRect(
      with: size,
      options: [.usesFontLeading, .usesLineFragmentOrigin],
      attributes: [NSAttributedString.Key.font: font],
      context: nil
    )
    let width = rect.size.width
    return ceil(width)
  }
}

extension UIColor {
  internal func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    UIGraphicsImageRenderer(size: size)
      .image { rendererContext in
        self.setFill()
        rendererContext.fill(CGRect(origin: .zero, size: size))
      }
  }
}

extension UIView {
  public func anchor(
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

  public func anchorTo(layoutGuide: UILayoutGuide) {
    anchor(
      toLeading: layoutGuide.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: layoutGuide.trailingAnchor,
      bottom: layoutGuide.bottomAnchor
    )
  }

  public func anchor(to view: UIView) {
    anchor(
      toLeading: view.leadingAnchor,
      top: view.topAnchor,
      trailing: view.trailingAnchor,
      bottom: view.bottomAnchor
    )
  }

  public func anchorHeight(to height: CGFloat) {
    heightAnchor.constraint(equalToConstant: height).isActive = true
  }

  public func anchorWidth(to width: CGFloat) {
    widthAnchor.constraint(equalToConstant: width).isActive = true
  }

  public func shouldTranslateAutoresizingMaskIntoConstraints(_ value: Bool) {
    subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = value }
  }
}
