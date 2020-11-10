//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import PanModal
import RxRelay

open class PanModalNavigationCollectionVC: UINavigationController, PanModalPresentable {
  public enum Action {
    case panModalWillDismiss
    case panModalDidDismiss
  }

  public var allowDragToDismiss = true
  public var allowTapToDismiss = true

  private var keyboardHeight: CGFloat = 0
  private var observer: NSKeyValueObservation?

  public weak var rootViewController: CollectionViewController?

  public let dismissActionRelay = PublishRelay<Action>()

  public init(rootViewController: CollectionViewController) {
    self.rootViewController = rootViewController
    super.init(rootViewController: rootViewController)
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    observer = rootViewController?.collectionView.observe(\UICollectionView.contentSize, options: [NSKeyValueObservingOptions.new]) {
      [weak self] _, change in
      guard let strongSelf = self, let contentSize = change.newValue, contentSize != .zero,
        contentSize != change.oldValue
      else {
        return
      }
      strongSelf.panModalSetNeedsLayoutUpdate()
      strongSelf.panModalTransition(to: .shortForm)
    }

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }

  @objc
  private func keyboardWillShow(notification: NSNotification) {
    guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    else {
      return
    }
    keyboardHeight = keyboardSize.height
    panModalSetNeedsLayoutUpdate()
  }

  @objc
  private func keyboardWillHide(notification: NSNotification) {
    keyboardHeight = 0
    panModalSetNeedsLayoutUpdate()
  }
  // MARK: - PanModalPresentable

  public func panModalWillDismiss() {
    dismissActionRelay.accept(.panModalWillDismiss)
  }

  public func panModalDidDismiss() {
    dismissActionRelay.accept(.panModalDidDismiss)
  }

  public var allowsDragToDismiss: Bool {
    allowDragToDismiss
  }

  public var allowsTapToDismiss: Bool {
    allowTapToDismiss
  }

}

// MARK: - PanModalPresentable
extension PanModalNavigationCollectionVC {
  public var panScrollable: UIScrollView? {
    (topViewController as? PanModalPresentable)?.panScrollable
  }

  public var shortFormHeight: PanModalHeight {
    let height = rootViewController?.collectionView.collectionViewLayout.collectionViewContentSize.height ?? 0
    let inset = rootViewController?.view.safeAreaInsets.bottom ?? 0 + keyboardHeight
    return .contentHeight(height + inset)
  }

  public var longFormHeight: PanModalHeight {
    shortFormHeight
  }
}

// MARK: - PanModalPresentable
extension ListViewController {
  public var panScrollable: UIScrollView? {
    collectionView
  }
}
