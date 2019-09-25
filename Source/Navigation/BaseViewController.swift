//
//  BaseViewController.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

open class BaseViewController: UIViewController, ViewController {
  public weak var lifecycleDelegate: ViewControllerDelegate?

  public let collectionView: UICollectionView = {
    let layout = ListViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: true)
    let collectionView = ListCollectionView(frame: .zero, listCollectionViewLayout: layout)
    collectionView.contentInsetAdjustmentBehavior = .automatic
    collectionView.keyboardDismissMode = .onDrag
    return collectionView
  }()

  // MARK: - Lifecycle

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIViewController

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    lifecycleDelegate?.viewController(self, viewWillAppear: animated)
  }

  override open func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    lifecycleDelegate?.viewController(self, viewWillDisappear: animated)
  }

  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    lifecycleDelegate?.viewController(self, viewDidDisappear: animated)
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
}
