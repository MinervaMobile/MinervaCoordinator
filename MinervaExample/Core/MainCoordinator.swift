//
//  MainCoordinator.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import UIKit

public class MainCoordinator<T: Presenter, U: ViewController>: BaseCoordinator<T, U>, UIViewControllerTransitioningDelegate {

	public typealias DismissBlock = (BaseCoordinatorPresentable) -> Void

	private var dismissBlock: DismissBlock?

	// MARK: - Public

	public final func addCloseButton(dismissBlock: @escaping DismissBlock) {
		self.dismissBlock = dismissBlock
		viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
			title: "Close",
			style: .plain,
			target: self,
			action: #selector(closeButtonPressed(_:))
		)
	}

	// MARK: - Private

	@objc
	private func closeButtonPressed(_ sender: UIBarButtonItem) {
		dismissBlock?(self)
	}

	// MARK: - ListControllerSizeDelegate
	override public func listController(
		_ listController: ListController,
		sizeFor model: ListCellModel,
		at indexPath: IndexPath,
		constrainedTo sizeConstraints: ListSizeConstraints
	) -> CGSize? {
		guard model is MarginCellModel else { return nil }
		let cellModels = listController.cellModels
		let collectionViewBounds = sizeConstraints.containerSize
		let minHeight: CGFloat = 20
		let dynamicHeight = cellModels.reduce(collectionViewBounds.height) { sum, model -> CGFloat in
			sum - (listController.size(of: model)?.height ?? 0)
		}
		let marginCellCount = cellModels.filter { $0 is MarginCellModel }.count
		let height = max(minHeight, dynamicHeight / CGFloat(marginCellCount))
		let width = sizeConstraints.adjustedContainerSize.width
		return CGSize(width: width, height: height)
	}
}
