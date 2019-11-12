//
//  LegacyListController.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

public final class LegacyListController: NSObject, ListController {

	public typealias Completion = (Bool) -> Void

	public weak var animationDelegate: ListControllerAnimationDelegate?
	public weak var reorderDelegate: ListControllerReorderDelegate?
	public weak var sizeDelegate: ListControllerSizeDelegate?
	public weak var scrollViewDelegate: UIScrollViewDelegate? {
		get { self.adapter.scrollViewDelegate }
		set { self.adapter.scrollViewDelegate = newValue }
	}

	public weak var viewController: UIViewController? {
		get { return self.adapter.viewController }
		set { self.adapter.viewController = newValue }
	}

	public var collectionView: UICollectionView? {
		get { return self.adapter.collectionView }
		set { self.adapter.collectionView = newValue }
	}

	public var listSections: [ListSection] {
		return listSectionWrappers.map { $0.section }
	}

	private let adapter: ListAdapter
	private var noLongerDisplayingCells = false
	private var listSectionWrappers: [ListSectionWrapper]

	// MARK: - Initializers

	override public init() {
		self.listSectionWrappers = []
		let updater = ListAdapterUpdater()
		self.adapter = ListAdapter(updater: updater, viewController: nil, workingRangeSize: 2)
		super.init()
		self.adapter.dataSource = self
		self.adapter.moveDelegate = self
	}

	// MARK: - Public

	public func reloadData(completion: Completion? = nil) {
		dispatchPrecondition(condition: .onQueue(.main))
		adapter.reloadData(completion: completion)
	}

	public func reload(_ cellModels: [ListCellModel]) {
		dispatchPrecondition(condition: .onQueue(.main))
		adapter.reloadObjects(cellModels.map(ListCellModelWrapper.init))
	}

	public func update(with listSections: [ListSection], animated: Bool, completion: Completion?) {
		dispatchPrecondition(condition: .onQueue(.main))
		#if DEBUG
			for section in listSections {
				var identifiers = [String: ListCellModel]()
				for cellModel in section.cellModels {
					let identifier = cellModel.identifier
					if identifier.isEmpty {
						assertionFailure("Found a cell model an invalid ID \(cellModel)")
					}
					if let existingCellModel = identifiers[identifier] {
						assertionFailure(
							"Found a cell model with a duplicate ID \(identifier) - \(cellModel) - \(existingCellModel)"
						)
					}
					identifiers[identifier] = cellModel
				}
			}
		#endif
		listSectionWrappers = listSections.map(ListSectionWrapper.init)
		adapter.performUpdates(animated: animated, completion: completion)
	}

	public func willDisplay() {
		dispatchPrecondition(condition: .onQueue(.main))
		guard noLongerDisplayingCells else { return }
		guard let visibleCells = adapter.collectionView?.visibleCells else { return }
		visibleCells.compactMap { $0 as? ListDisplayableCell }.forEach { $0.willDisplayCell() }
		noLongerDisplayingCells = false
	}

	public func didEndDisplaying() {
		dispatchPrecondition(condition: .onQueue(.main))
		guard !noLongerDisplayingCells else { return }
		guard let visibleCells = adapter.collectionView?.visibleCells else { return }
		visibleCells.compactMap { $0 as? ListDisplayableCell }.forEach { $0.didEndDisplayingCell() }
		noLongerDisplayingCells = true
	}

	public func invalidateLayout() {
		dispatchPrecondition(condition: .onQueue(.main))
		// TODO: Clear the autolayout size cache.
	}

	public func indexPath(for cellModel: ListCellModel) -> IndexPath? {
		dispatchPrecondition(condition: .onQueue(.main))
		guard let section = listSections.firstIndex(where: {
			$0.cellModels.contains(where: { cellModel.identical(to: $0) })
		}) else {
			return nil
		}
		guard let item = listSections.at(section)?.cellModels.firstIndex(where: { cellModel.identical(to: $0) }) else {
			return nil
		}
		return IndexPath(item: item, section: section)
	}

	public var centerCellModel: ListCellModel? {
		dispatchPrecondition(condition: .onQueue(.main))
		guard let indexPath = adapter.collectionView?.centerCellIndexPath,
			let cellModel = cellModel(at: indexPath) else {
				return nil
		}
		return cellModel
	}

	public func cellModel(at indexPath: IndexPath) -> ListCellModel? {
		dispatchPrecondition(condition: .onQueue(.main))
		guard let model = listSections.at(indexPath.section)?.cellModels.at(indexPath.item) else {
			return nil
		}
		return model
	}

	public func cell(at indexPath: IndexPath) -> UICollectionViewCell? {
		dispatchPrecondition(condition: .onQueue(.main))
		guard let cell = adapter.collectionView?.cellForItem(at: indexPath) else {
			return nil
		}
		return cell
	}

	public func cell(for cellModel: ListCellModel) -> UICollectionViewCell? {
		dispatchPrecondition(condition: .onQueue(.main))
		guard let indexPath = indexPath(for: cellModel),
			let cell = adapter.collectionView?.cellForItem(at: indexPath) else {
				return nil
		}
		return cell
	}

	public func removeCellModel(at indexPath: IndexPath, completion: Completion?) {
		dispatchPrecondition(condition: .onQueue(.main))
		guard listSections.at(indexPath.section)?.cellModels.at(indexPath.item) != nil else {
			assertionFailure("Could not find model at indexPath")
			return
		}
		var listSections = self.listSections
		var section = listSections[indexPath.section]
		var cellModels = section.cellModels
		cellModels.remove(at: indexPath.row)

		if cellModels.isEmpty {
			listSections.remove(at: indexPath.section)
		} else {
			section.cellModels = cellModels
			listSections[indexPath.section] = section
		}
		update(with: listSections, animated: true, completion: completion)
	}

	public func scrollTo(
		cellModel: ListCellModel,
		scrollPosition: UICollectionView.ScrollPosition,
		animated: Bool
	) {
		dispatchPrecondition(condition: .onQueue(.main))

		guard let sectionWrapper = listSectionWrappers.first(where: {
			$0.section.cellModels.contains(where: { $0.identifier == cellModel.identifier })
		}) else {
			assertionFailure("Section should exist for \(cellModel)")
			return
		}
		guard let sectionController = adapter.sectionController(for: sectionWrapper) else {
			assertionFailure("Section Controller should exist for \(sectionWrapper) and \(cellModel)")
			return
		}
		guard let modelIndex = sectionWrapper.section.cellModels.firstIndex(where: {
			$0.identifier == cellModel.identifier
		}) else {
			assertionFailure("index should exist for \(cellModel)")
			return
		}
		let indexPath = IndexPath(item: modelIndex, section: sectionController.section)
		guard collectionView?.isIndexPathAvailable(indexPath) ?? false else {
			assertionFailure("IndexPath should exist for \(cellModel)")
			return
		}
		sectionController.collectionContext?.scroll(
			to: sectionController,
			at: modelIndex,
			scrollPosition: scrollPosition,
			animated: animated)
	}

	public func scroll(to scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
		dispatchPrecondition(condition: .onQueue(.main))
		guard !listSections.isEmpty else { return }
		let cellModels = listSections.flatMap { $0.cellModels }
		guard !cellModels.isEmpty else { return }
		let model: ListCellModel?
		switch scrollPosition {
		case .top, .left:
			model = cellModels.first
		case .centeredVertically, .centeredHorizontally:
			let middleIndex = cellModels.count / 2
			model = cellModels.at(middleIndex)
		case .bottom, .right:
			model = cellModels.last
		default:
			model = cellModels.first
		}

		guard let cellModel = model else { return }

		scrollTo(cellModel: cellModel, scrollPosition: scrollPosition, animated: animated)
	}

	public func size(of listSection: ListSection, with constraints: ListSizeConstraints? = nil) -> CGSize? {
		dispatchPrecondition(condition: .onQueue(.main))
		return size(
			using: constraints,
			sectionPicker: { $0.section.identifier == listSection.identifier },
			executionBlock: { sectionController, sizeConstraints -> CGSize? in
				sectionController.size(of: listSection, with: sizeConstraints)
			}
		)
	}

	public func size(of cellModel: ListCellModel, with constraints: ListSizeConstraints? = nil) -> CGSize? {
		dispatchPrecondition(condition: .onQueue(.main))
		return size(
			using: constraints,
			sectionPicker: { wrapper -> Bool in
				wrapper.section.cellModels.contains { $0.identifier == cellModel.identifier }
			},
			executionBlock: { sectionController, sizeConstraints -> CGSize? in
				sectionController.size(for: cellModel, with: sizeConstraints)
			}
		)
	}

	// MARK: - Private

	private func size(
		using constraints: ListSizeConstraints?,
		sectionPicker: (ListSectionWrapper) -> Bool,
		executionBlock: (ListModelSectionController, ListSizeConstraints) -> CGSize?
	) -> CGSize? {
		let sectionWrapper = listSectionWrappers.first(where: sectionPicker)

		let sectionController: ListModelSectionController
		let sizeConstraints: ListSizeConstraints

		// If this function is called before the adapter is showing the cellModel we still want to return the correct size.
		// Reuse the existing ListModelSectionController if it is available in order to support caching of size information.
		if let listSectionWrapper = sectionWrapper,
			let controller = adapter.sectionController(for: listSectionWrapper) as? ListModelSectionController,
			let constraints = controller.sizeConstraints {
			sectionController = controller
			sizeConstraints = constraints
		} else if let constraints = constraints {
			sectionController = ListModelSectionController()
			sizeConstraints = constraints
		} else {
			assertionFailure("Need a section to properly size the cell")
			return nil
		}
		return executionBlock(sectionController, sizeConstraints)
	}
}

// MARK: - ListAdapterDataSource
extension LegacyListController: ListAdapterDataSource {
	public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
		return listSectionWrappers
	}

	public func listAdapter(
		_ listAdapter: ListAdapter,
		sectionControllerFor object: Any
	) -> ListSectionController {
		let sectionController = ListModelSectionController()
		sectionController.delegate = self
		return sectionController
	}

	public func emptyView(for listAdapter: ListAdapter) -> UIView? {
		return nil
	}
}

// MARK: - ListAdapterMoveDelegate
extension LegacyListController: ListAdapterMoveDelegate {
	public func listAdapter(
		_ listAdapter: ListAdapter,
		move object: Any,
		from previousObjects: [Any],
		to objects: [Any]
	) {
		guard let sections = objects as? [ListSectionWrapper] else {
			assertionFailure("Invalid object types \(objects)")
			return
		}
		self.listSectionWrappers = sections
	}
}

// MARK: - ListModelSectionControllerDelegate
extension LegacyListController: ListModelSectionControllerDelegate {
	internal func sectionController(
		_ sectionController: ListModelSectionController,
		sizeFor model: ListCellModel,
		at indexPath: IndexPath,
		constrainedTo sizeConstraints: ListSizeConstraints
	) -> CGSize? {
		return sizeDelegate?.listController(
			self,
			sizeFor: model,
			at: indexPath,
			constrainedTo: sizeConstraints
		)
	}

	internal func sectionControllerCompletedMove(
		_ sectionController: ListModelSectionController,
		for cellModel: ListCellModel,
		fromIndex: Int,
		toIndex: Int
	) {
		reorderDelegate?.listControllerCompletedMove(self, for: cellModel, fromIndex: fromIndex, toIndex: toIndex)
	}

	internal func sectionController(
		_ sectionController: ListModelSectionController,
		initialLayoutAttributes attributes: ListViewLayoutAttributes,
		for section: ListSection,
		at indexPath: IndexPath
	) -> ListViewLayoutAttributes? {
		return animationDelegate?.listController(self, initialLayoutAttributes: attributes, for: section, at: indexPath)
	}

	internal func sectionController(
		_ sectionController: ListModelSectionController,
		finalLayoutAttributes attributes: ListViewLayoutAttributes,
		for section: ListSection,
		at indexPath: IndexPath
	) -> ListViewLayoutAttributes? {
		return animationDelegate?.listController(self, finalLayoutAttributes: attributes, for: section, at: indexPath)
	}
}
