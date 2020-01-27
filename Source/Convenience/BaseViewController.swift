//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import UIKit

open class BaseViewController: UIViewController, ViewController {
  /// Defines how the collection view should interact with keyboard.
  public enum KeyboardBehavior {
      /// Keep keyboard on screen until dismissed by user.
      /// This will also adjust collection view's content inset to offset the scroll area covered by keyboard.
      case stay
      /// Dismisses the keyboard when a drag begins.
      case dismissOnDrag
  }

  public weak var lifecycleDelegate: ViewControllerDelegate?

  public let collectionView: UICollectionView

  // MARK: - Lifecycle

  public init(
    layout: ListViewLayout = ListViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: true),
    keyboardBehavior: KeyboardBehavior = .dismissOnDrag
  ) {
    self.collectionView = {
      let collectionView = ListCollectionView(frame: .zero, listCollectionViewLayout: layout)
      collectionView.keyboardDismissMode = Self.keyboardDismissMode(keyboardBehavior: keyboardBehavior)
      return collectionView
    }()
    self.enableKeyboardObserving = Self.shouldEnableKeyboardObserving(keyboardBehavior: keyboardBehavior)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIViewController
  override open func viewDidLoad() {
    super.viewDidLoad()
    lifecycleDelegate?.viewControllerViewDidLoad(self)
  }

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    lifecycleDelegate?.viewController(self, viewWillAppear: animated)
    if enableKeyboardObserving {
      setupKeyboardObserving()
    }
  }

  override open func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    lifecycleDelegate?.viewController(self, viewWillDisappear: animated)
    if enableKeyboardObserving {
      stopKeyboardObserving()
    }
  }

  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    lifecycleDelegate?.viewController(self, viewDidDisappear: animated)
  }

  override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    lifecycleDelegate?.viewController(self, traitCollectionDidChangeFrom: previousTraitCollection)
  }

  override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    let context = collectionView.collectionViewLayout.invalidationContext(forBoundsChange: .zero)
    coordinator.animate(
      alongsideTransition: { [weak self] _ in
        self?.collectionView.collectionViewLayout.invalidateLayout(with: context)
      },
      completion: nil
    )
  }

  // MARK: - Keyboard

  private enum Constants {
      static let animationDuration: TimeInterval = 0.25
  }

  private var extraBottomInsetForKeyboard: CGFloat?
  private var keyboardShowObserver: Any?
  private var keyboardHideObserver: Any?
  private let enableKeyboardObserving: Bool

  private func setupKeyboardObserving() {
      keyboardShowObserver = NotificationCenter.default.addObserver(
          forName: UIResponder.keyboardDidShowNotification,
          object: nil,
          queue: nil,
          using: { [weak self] notification in self?.keyboardDidShow(notification: notification) }
      )
      keyboardHideObserver = NotificationCenter.default.addObserver(
          forName: UIResponder.keyboardDidHideNotification,
          object: nil,
          queue: nil,
          using: { [weak self] notification in self?.keyboardDidHide(notification: notification) }
      )
  }

  private func stopKeyboardObserving() {
      if let keyboardShowObserver = keyboardShowObserver {
          NotificationCenter.default.removeObserver(keyboardShowObserver)
      }
      if let keyboardHideObserver = keyboardHideObserver {
          NotificationCenter.default.removeObserver(keyboardHideObserver)
      }
      keyboardShowObserver = nil
      keyboardHideObserver = nil
      cleanupInsetForKeyboard()
  }

  private func keyboardDidShow(notification: Notification) {
      guard let window = collectionView.window, let superview = collectionView.superview else { return }
      guard let keyboardFrame =
          (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
      let keyboardFrameInViewCoordinates = window.convert(keyboardFrame, to: superview)
      let intersection = collectionView.frame.intersection(keyboardFrameInViewCoordinates)
      guard !intersection.isNull else { return }
      let previousExtraBottomInset = self.extraBottomInsetForKeyboard ?? 0
      let extraBottomInsetForKeyboard = intersection.height - collectionView.safeAreaInsets.bottom
      self.extraBottomInsetForKeyboard = extraBottomInsetForKeyboard
      UIView.animate(withDuration: Constants.animationDuration) {
          self.collectionView.contentInset.bottom += extraBottomInsetForKeyboard - previousExtraBottomInset
          self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
      }
  }

  private func keyboardDidHide(notification: Notification) {
      cleanupInsetForKeyboard()
  }

  private func cleanupInsetForKeyboard() {
      guard let extraBottomInsetForKeyboard = extraBottomInsetForKeyboard else { return }
      UIView.animate(withDuration: Constants.animationDuration) {
          self.collectionView.contentInset.bottom -= extraBottomInsetForKeyboard
          self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
      }
      self.extraBottomInsetForKeyboard = nil
  }

  private static func shouldEnableKeyboardObserving(keyboardBehavior: KeyboardBehavior) -> Bool {
      switch keyboardBehavior {
      case .dismissOnDrag:
          return false
      case .stay:
          return true
      }
  }

  private static func keyboardDismissMode(keyboardBehavior: KeyboardBehavior) -> UIScrollView.KeyboardDismissMode {
      switch keyboardBehavior {
      case .dismissOnDrag:
          return .onDrag
      case .stay:
          return .none
      }
  }
}
