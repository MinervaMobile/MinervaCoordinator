//
//  UIKitExtensions.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

extension Array where Element: NSAttributedString {
  public func height(constraintedToWidth width: CGFloat) -> CGFloat {
    let mutableString = self.reduce(NSMutableAttributedString()) { mutable, attributed -> NSMutableAttributedString in
      let mutableString = mutable
      mutableString.append(attributed)
      return mutableString
    }
    return mutableString.height(constraintedToWidth: width)
  }
}

class BlockBarButtonItem: UIBarButtonItem {
  typealias ActionHandler = (UIBarButtonItem) -> Void

  private var actionHandler: ActionHandler?

  convenience init(image: UIImage?, style: Style, actionHandler: ActionHandler?) {
    self.init(image: image, style: style, target: nil, action: #selector(barButtonItemPressed(sender:)))
    target = self
    self.actionHandler = actionHandler
  }

  convenience init(title: String?, style: Style, actionHandler: ActionHandler?) {
    self.init(title: title, style: style, target: nil, action: #selector(barButtonItemPressed(sender:)))
    target = self
    self.actionHandler = actionHandler
  }

  convenience init(barButtonSystemItem systemItem: SystemItem, actionHandler: ActionHandler?) {
    self.init(barButtonSystemItem: systemItem, target: nil, action: #selector(barButtonItemPressed(sender:)))
    target = self
    self.actionHandler = actionHandler
  }

  @objc
  func barButtonItemPressed(sender: UIBarButtonItem) {
    actionHandler?(sender)
  }
}

extension CoordinatorNavigator {

  public func presentWithCloseButton<P, VC>(
    _ coordinator: MainCoordinator<P, VC>,
    animated: Bool = true,
    modalPresentationStyle: UIModalPresentationStyle = .automatic
  ) {
    coordinator.addCloseButton() { [weak self] child in
      self?.dismiss(child, animated: true)
    }
    present(
      coordinator,
      from: coordinator.navigator,
      modalPresentationStyle: modalPresentationStyle,
      animated: animated)
  }
}

extension ListController {
  public var cellModels: [ListCellModel] {
    return listSections.flatMap { $0.cellModels }
  }
}

extension NSAttributedString {
  convenience init(string: String, font: UIFont, fontColor: UIColor) {
    self.init(
      string: string,
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: fontColor
      ])
  }
  func height(constraintedToWidth width: CGFloat) -> CGFloat {
    let size = CGSize(width: width, height: .greatestFiniteMagnitude)
    let rect = self.boundingRect(with: size, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
    let height = rect.size.height
    return ceil(height)
  }
  func width(constraintedToHeight height: CGFloat) -> CGFloat {
    let size = CGSize(width: .greatestFiniteMagnitude, height: height)
    let rect = self.boundingRect(with: size, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)

    let width = rect.size.width
    return ceil(width)
  }
}

extension Published {
  public static func just(_ initialValue: Value) -> Published<Value> {
    Published(initialValue: initialValue)
  }
}

extension String {
  func height(constraintedToWidth width: CGFloat, font: UIFont) -> CGFloat {
    let string = self as NSString
    let size = CGSize(width: width, height: .greatestFiniteMagnitude)
    let rect = string.boundingRect(
      with: size,
      options: [.usesFontLeading, .usesLineFragmentOrigin],
      attributes: [NSAttributedString.Key.font: font],
      context: nil)
    let height = rect.size.height
    return ceil(height)
  }
  func width(constraintedToHeight height: CGFloat, font: UIFont) -> CGFloat {
    let string = self as NSString
    let size = CGSize(width: .greatestFiniteMagnitude, height: height)
    let rect = string.boundingRect(
      with: size,
      options: [.usesFontLeading, .usesLineFragmentOrigin],
      attributes: [NSAttributedString.Key.font: font],
      context: nil)
    let width = rect.size.width
    return ceil(width)
  }
}

extension UIColor {

  public static var controllers: UIColor {
    return UIColor(red: 247, green: 247, blue: 247)
  }

  public static var selectable: UIColor {
    return UIColor(red: 242, green: 114, blue: 79)
  }

  public static var section: UIColor {
    return UIColor(red: 247, green: 247, blue: 247)
  }

  public static var separator: UIColor {
    return UIColor(red: 226, green: 231, blue: 242)
  }

  public convenience init(red: Int, green: Int, blue: Int) {
    self.init(
      red: CGFloat(red) / 255.0,
      green: CGFloat(green) / 255.0,
      blue: CGFloat(blue) / 255.0,
      alpha: 1.0)
  }
  public convenience init(white: Int) {
    self.init(white: CGFloat(white) / 255.0, alpha: 1.0)
  }
}

extension UIFont {

  static var headline: UIFont {
    return UIFont.preferredFont(forTextStyle: .headline)
  }

  static var boldHeadline: UIFont {
    return self.boldFont(forTextStyle: .headline)
  }

  static var subheadline: UIFont {
    return UIFont.preferredFont(forTextStyle: .subheadline)
  }

  static var boldSubheadline: UIFont {
    return self.boldFont(forTextStyle: .subheadline)
  }

  static var callout: UIFont {
    return UIFont.preferredFont(forTextStyle: .callout)
  }

  static var boldCallout: UIFont {
    return self.boldFont(forTextStyle: .callout)
  }

  static var titleLarge: UIFont {
    return UIFont.preferredFont(forTextStyle: .title1)
  }

  static var boldTitleLarge: UIFont {
    return self.boldFont(forTextStyle: .title1)
  }

  static var titleSmall: UIFont {
    return UIFont.preferredFont(forTextStyle: .title3)
  }

  static var boldTitleSmall: UIFont {
    return self.boldFont(forTextStyle: .title3)
  }

  static var body: UIFont {
    return UIFont.preferredFont(forTextStyle: .body)
  }

  static var boldBody: UIFont {
    return self.boldFont(forTextStyle: .body)
  }

  static var footnote: UIFont {
    return UIFont.preferredFont(forTextStyle: .footnote)
  }

  static var boldFootnote: UIFont {
    return self.boldFont(forTextStyle: .footnote)
  }

  static var caption: UIFont {
    return UIFont.preferredFont(forTextStyle: .caption2)
  }

  static var boldCaption: UIFont {
    return self.boldFont(forTextStyle: .caption2)
  }

  private static func boldFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
    let baseFont = UIFont.preferredFont(forTextStyle: textStyle)
    return self.boldSystemFont(ofSize: baseFont.pointSize)
  }
}

extension UILayoutPriority {
  internal static var notRequired: UILayoutPriority {
    return UILayoutPriority.required - 1
  }
}

extension UIView {

  func shouldTranslateAutoresizingMaskIntoConstraints(_ value: Bool) {
    self.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = value }
  }

  func anchor(
    toLeading leading: NSLayoutXAxisAnchor?,
    top: NSLayoutYAxisAnchor?,
    trailing: NSLayoutXAxisAnchor?,
    bottom: NSLayoutYAxisAnchor?
  ) {
    if let leading = leading {
      self.leadingAnchor.constraint(equalTo: leading).isActive = true
    }
    if let top = top {
      self.topAnchor.constraint(equalTo: top).isActive = true
    }
    if let trailing = trailing {
      self.trailingAnchor.constraint(equalTo: trailing).isActive = true
    }
    if let bottom = bottom {
      self.bottomAnchor.constraint(equalTo: bottom).isActive = true
    }
  }

  func anchorTo(layoutGuide: UILayoutGuide) {
    self.anchor(
      toLeading: layoutGuide.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: layoutGuide.trailingAnchor,
      bottom: layoutGuide.bottomAnchor)
  }

  func anchor(to view: UIView) {
    self.anchor(
      toLeading: view.leadingAnchor,
      top: view.topAnchor,
      trailing: view.trailingAnchor,
      bottom: view.bottomAnchor)
  }

  func anchorHeight(to height: CGFloat) {
    self.heightAnchor.constraint(equalToConstant: height).isActive = true
  }

  func anchorWidth(to width: CGFloat) {
    self.widthAnchor.constraint(equalToConstant: width).isActive = true
  }

  func equalHorizontalCenter(with view: UIView) {
    NSLayoutConstraint(
      item: self,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: view,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0).isActive = true
  }

  func equalVerticalCenter(with view: UIView) {
    NSLayoutConstraint(
      item: self,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: view,
      attribute: .centerY,
      multiplier: 1.0,
      constant: 0).isActive = true
  }
}

extension UIViewController {

  var topLayoutGuideAnchor: NSLayoutYAxisAnchor {
    return self.view.safeAreaLayoutGuide.topAnchor
  }

  var bottomLayoutGuideAnchor: NSLayoutYAxisAnchor {
    return self.view.safeAreaLayoutGuide.bottomAnchor
  }

  func add(child viewController: UIViewController, to view: UIView) {
    viewController.willMove(toParent: self)
    self.addChild(viewController)
    view.addSubview(viewController.view)
    viewController.view.frame = view.bounds
    viewController.didMove(toParent: self)
  }

  func remove(child viewController: UIViewController) {
    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
    viewController.didMove(toParent: nil)
  }

  func anchorViewToSafeAreaLayoutGuide(_ view: UIView) {
    view.anchorTo(layoutGuide: self.view.safeAreaLayoutGuide)
  }

  func anchorViewToTopAndBottomSafeAreaLayoutGuide(_ view: UIView) {
    view.anchor(
      toLeading: self.view.leadingAnchor,
      top: self.topLayoutGuideAnchor,
      trailing: self.view.trailingAnchor,
      bottom: self.bottomLayoutGuideAnchor)
  }

  func anchorViewToTopSafeAreaLayoutGuide(_ view: UIView) {
    // This allows the view to scroll past the bottom safe area if collection view
    // extends to the bottom of the view
    let layoutGuide = self.view.safeAreaLayoutGuide
    view.anchor(
      toLeading: self.view.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: self.view.trailingAnchor,
      bottom: self.view.bottomAnchor)
  }

  func alert(_ error: Error, title: String, message: String? = nil) {
    switch error {
    case SystemError.cancelled: return
    default: break
    }
    var message = message
    if let localError = error as? LocalizedError {
      message = message ?? localError.errorDescription
    }
    alert(title: title, message: message)
  }

  func alert(title: String, message: String?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(okAction)

    present(alertController, animated: true, completion: nil)
  }
}
