//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import IGListKit
import RxRelay
import UIKit

open class BaseViewController: UIViewController, ListViewController {
  public var events = PublishRelay<ListViewControllerEvent>()

  public let collectionView: UICollectionView

  // MARK: - Lifecycle

  public init(
    layout: ListViewLayout = ListViewLayout(
      stickyHeaders: false,
      topContentInset: 0,
      stretchToEdge: true
    )
  ) {
    self.collectionView = ListCollectionView(frame: .zero, listCollectionViewLayout: layout)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIViewController
  override open func viewDidLoad() {
    super.viewDidLoad()
    events.accept(.viewDidLoad)
  }

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    events.accept(.viewWillAppear(animated: animated))
  }

  override open func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    events.accept(.viewWillDisappear(animated: animated))
  }

  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    events.accept(.viewDidAppear(animated: animated))
  }

  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    events.accept(.viewDidDisappear(animated: animated))
  }

  override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    events.accept(.traitCollectionDidChange(previousTraitCollection: previousTraitCollection))
  }

  override open func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
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
