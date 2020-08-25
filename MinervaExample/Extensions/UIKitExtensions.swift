//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import UIKit

public enum UIKitExtensions {}

extension Array where Element: NSAttributedString {
  public func height(constraintedToWidth width: CGFloat) -> CGFloat {
    let mutableString = self.reduce(NSMutableAttributedString()) {
      mutable,
      attributed -> NSMutableAttributedString in
      let mutableString = mutable
      mutableString.append(attributed)
      return mutableString
    }
    return mutableString.height(constraintedToWidth: width)
  }
}

public class BlockBarButtonItem: UIBarButtonItem {
  public typealias ActionHandler = (UIBarButtonItem) -> Void

  private var actionHandler: ActionHandler?

  public convenience init(image: UIImage?, style: Style, actionHandler: ActionHandler?) {
    self.init(
      image: image,
      style: style,
      target: nil,
      action: #selector(barButtonItemPressed(sender:))
    )
    target = self
    self.actionHandler = actionHandler
  }

  public convenience init(title: String?, style: Style, actionHandler: ActionHandler?) {
    self.init(
      title: title,
      style: style,
      target: nil,
      action: #selector(barButtonItemPressed(sender:))
    )
    target = self
    self.actionHandler = actionHandler
  }

  public convenience init(barButtonSystemItem systemItem: SystemItem, actionHandler: ActionHandler?)
  {
    self.init(
      barButtonSystemItem: systemItem,
      target: nil,
      action: #selector(barButtonItemPressed(sender:))
    )
    target = self
    self.actionHandler = actionHandler
  }

  @objc
  public func barButtonItemPressed(sender: UIBarButtonItem) {
    actionHandler?(sender)
  }
}

extension CoordinatorNavigator {

  public func presentWithCloseButton<P, VC>(
    _ coordinator: MainCoordinator<P, VC>,
    animated: Bool = true,
    modalPresentationStyle: UIModalPresentationStyle = .automatic
  ) {
    coordinator.addCloseButton { [weak self] child in
      self?.dismiss(child, animated: true)
    }
    coordinator.navigator.setViewControllers([coordinator.baseViewController], animated: false)
    present(
      coordinator,
      modalPresentationStyle: modalPresentationStyle,
      animated: animated
    )
  }
}

extension LabelCellModel {
  public static func createSectionHeaderModel(title: String) -> LabelCellModel {
    let cellModel = LabelCellModel(text: title, font: .footnote)
    cellModel.backgroundColor = .section
    cellModel.directionalLayoutMargins.top = 24
    cellModel.textAlignment = .left
    cellModel.textColor = .black
    return cellModel
  }
}

extension ListController {
  public var cellModels: [ListCellModel] {
    listSections.flatMap { $0.cellModels }
  }
}

extension NSAttributedString {
  public convenience init(string: String, font: UIFont, fontColor: UIColor) {
    self.init(
      string: string,
      attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: fontColor
      ]
    )
  }
  public func height(constraintedToWidth width: CGFloat) -> CGFloat {
    let size = CGSize(width: width, height: .greatestFiniteMagnitude)
    let rect = self.boundingRect(
      with: size,
      options: [.usesFontLeading, .usesLineFragmentOrigin],
      context: nil
    )
    let height = rect.size.height
    return ceil(height)
  }
  public func width(constraintedToHeight height: CGFloat) -> CGFloat {
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

extension Published {
  public static func just(_ initialValue: Value) -> Published<Value> {
    Published(initialValue: initialValue)
  }
}

extension String {
  public func height(constraintedToWidth width: CGFloat, font: UIFont) -> CGFloat {
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
  public func width(constraintedToHeight height: CGFloat, font: UIFont) -> CGFloat {
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

  public static var controllers: UIColor {
    UIColor(red: 247, green: 247, blue: 247)
  }

  public static var selectable: UIColor {
    UIColor(red: 242, green: 114, blue: 79)
  }

  public static var section: UIColor {
    UIColor(red: 247, green: 247, blue: 247)
  }

  public static var separator: UIColor {
    UIColor(red: 226, green: 231, blue: 242)
  }

  public convenience init(red: Int, green: Int, blue: Int) {
    self.init(
      red: CGFloat(red) / 255.0,
      green: CGFloat(green) / 255.0,
      blue: CGFloat(blue) / 255.0,
      alpha: 1.0
    )
  }
  public convenience init(white: Int) {
    self.init(white: CGFloat(white) / 255.0, alpha: 1.0)
  }
}

extension UIFont {
  @inline(__always)
  public final class var largeTitle: UIFont {
    UIFont.preferredFont(forTextStyle: .largeTitle)
  }
  @inline(__always)
  public final class var title1: UIFont {
    UIFont.preferredFont(forTextStyle: .title1)
  }
  @inline(__always)
  public final class var title2: UIFont {
    UIFont.preferredFont(forTextStyle: .title2)
  }
  @inline(__always)
  public final class var title3: UIFont {
    UIFont.preferredFont(forTextStyle: .title3)
  }
  @inline(__always)
  public final class var headline: UIFont {
    UIFont.preferredFont(forTextStyle: .headline)
  }
  @inline(__always)
  public final class var subheadline: UIFont {
    UIFont.preferredFont(forTextStyle: .subheadline)
  }
  @inline(__always)
  public final class var body: UIFont {
    UIFont.preferredFont(forTextStyle: .body)
  }
  @inline(__always)
  public final class var callout: UIFont {
    UIFont.preferredFont(forTextStyle: .callout)
  }
  @inline(__always)
  public final class var footnote: UIFont {
    UIFont.preferredFont(forTextStyle: .footnote)
  }
  @inline(__always)
  public final class var caption1: UIFont {
    UIFont.preferredFont(forTextStyle: .caption1)
  }
  @inline(__always)
  public final class var caption2: UIFont {
    UIFont.preferredFont(forTextStyle: .caption2)
  }

  @inline(__always)
  public final var bold: UIFont {
    withTraits(traits: .traitBold)
  }
  @inline(__always)
  public final var italic: UIFont {
    withTraits(traits: .traitItalic)
  }
  @inline(__always)
  public final var monospace: UIFont {
    withTraits(traits: .traitMonoSpace)
  }

  public final func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
      return self
    }
    return UIFont(descriptor: descriptor, size: 0)  //size 0 means keep the size as it is
  }
}

extension UILayoutPriority {
  public static var notRequired: UILayoutPriority {
    UILayoutPriority.required - 1
  }
}

extension UIView {

  public func shouldTranslateAutoresizingMaskIntoConstraints(_ value: Bool) {
    self.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = value }
  }

  public func anchor(
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

  public func anchorTo(layoutGuide: UILayoutGuide) {
    self.anchor(
      toLeading: layoutGuide.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: layoutGuide.trailingAnchor,
      bottom: layoutGuide.bottomAnchor
    )
  }

  public func anchor(to view: UIView) {
    self.anchor(
      toLeading: view.leadingAnchor,
      top: view.topAnchor,
      trailing: view.trailingAnchor,
      bottom: view.bottomAnchor
    )
  }

  public func anchorHeight(to height: CGFloat) {
    self.heightAnchor.constraint(equalToConstant: height).isActive = true
  }

  public func anchorWidth(to width: CGFloat) {
    self.widthAnchor.constraint(equalToConstant: width).isActive = true
  }

  public func equalHorizontalCenter(with view: UIView) {
    NSLayoutConstraint(
      item: self,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: view,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0
    )
    .isActive = true
  }

  public func equalVerticalCenter(with view: UIView) {
    NSLayoutConstraint(
      item: self,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: view,
      attribute: .centerY,
      multiplier: 1.0,
      constant: 0
    )
    .isActive = true
  }
}

extension UIViewController {

  public var topLayoutGuideAnchor: NSLayoutYAxisAnchor {
    self.view.safeAreaLayoutGuide.topAnchor
  }

  public var bottomLayoutGuideAnchor: NSLayoutYAxisAnchor {
    self.view.safeAreaLayoutGuide.bottomAnchor
  }

  public func add(child viewController: UIViewController, to view: UIView) {
    viewController.willMove(toParent: self)
    self.addChild(viewController)
    view.addSubview(viewController.view)
    viewController.view.frame = view.bounds
    viewController.didMove(toParent: self)
  }

  public func remove(child viewController: UIViewController) {
    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
    viewController.didMove(toParent: nil)
  }

  public func anchorViewToSafeAreaLayoutGuide(_ view: UIView) {
    view.anchorTo(layoutGuide: self.view.safeAreaLayoutGuide)
  }

  public func anchorViewToTopAndBottomSafeAreaLayoutGuide(_ view: UIView) {
    view.anchor(
      toLeading: self.view.leadingAnchor,
      top: self.topLayoutGuideAnchor,
      trailing: self.view.trailingAnchor,
      bottom: self.bottomLayoutGuideAnchor
    )
  }

  public func anchorViewToTopSafeAreaLayoutGuide(_ view: UIView) {
    // This allows the view to scroll past the bottom safe area if collection view
    // extends to the bottom of the view
    let layoutGuide = self.view.safeAreaLayoutGuide
    view.anchor(
      toLeading: self.view.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: self.view.trailingAnchor,
      bottom: self.view.bottomAnchor
    )
  }

  public func alert(_ error: Error, title: String, message: String? = nil) {
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

  public func alert(title: String, message: String?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(okAction)

    present(alertController, animated: true, completion: nil)
  }
}
