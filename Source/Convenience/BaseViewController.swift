//
//  BaseViewController.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import IGListKit
import UIKit

open class BaseViewController: UIViewController, ViewController {
	public weak var lifecycleDelegate: ViewControllerDelegate?

	public let collectionView: UICollectionView

	// MARK: - Lifecycle

	public init(layout: ListViewLayout = ListViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: true)) {
		self.collectionView = {
			let collectionView = ListCollectionView(frame: .zero, listCollectionViewLayout: layout)
			collectionView.keyboardDismissMode = .onDrag
			return collectionView
		}()
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
	}

	override open func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		lifecycleDelegate?.viewController(self, viewWillDisappear: animated)
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
}
