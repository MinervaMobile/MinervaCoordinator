//
//  ListCellModel.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

// MARK: - ListCellModel
public protocol ListCellModel: class, ListDiffable, CustomStringConvertible {
  var cell: ListCollectionViewCell? { get set }

  var reorderable: Bool { get }
  var identifier: String { get }
  var cellClassName: String { get }
  func isEqual(to model: ListCellModel) -> Bool
  func size(constrainedTo containerSize: CGSize) -> CGSize?
}

extension ListCellModel {
  public func size(with sizeConstraints: ListSizeConstraints) -> CGSize? {
    let sizeConstraintWidth = sizeConstraints.containerSizeAdjustedForInsets.width
    let rowWidth = sizeConstraintWidth
    switch sizeConstraints.distribution {
    case .equally(let cellsInRow):
      let equalCellWidth = (rowWidth / CGFloat(cellsInRow))
        - (sizeConstraints.minimumInteritemSpacing * CGFloat(cellsInRow - 1) / CGFloat(cellsInRow))
      let maxSize = CGSize(width: equalCellWidth, height: sizeConstraints.containerSize.height)
      guard let cellSize = size(constrainedTo: maxSize) else {
        assertionFailure("ListCellModel: \(self) should implement size")
        return nil
      }
      return CGSize(width: equalCellWidth, height: cellSize.height)
    case .entireRow:
      guard let cellSize = size(constrainedTo: sizeConstraints.containerSizeAdjustedForInsets) else {
        assertionFailure("ListCellModel: \(self) should implement size")
        return nil
      }
      return CGSize(width: rowWidth, height: cellSize.height)
    case .proportionally:
      let cellSize = size(constrainedTo: sizeConstraints.containerSizeAdjustedForInsets)
      return cellSize
    }
  }
}

// MARK: - ListSelectableCellModel
public protocol ListSelectableCellModelWrapper {
  func selected(at indexPath: IndexPath)
}

public protocol ListSelectableCellModel: ListSelectableCellModelWrapper {
  associatedtype SelectableModelType: ListCellModel

  typealias SelectionAction = (_ cellModel: SelectableModelType, _ indexPath: IndexPath) -> Void

  var selectionAction: SelectionAction? { get }
}

extension ListSelectableCellModel {
  public func selected(at indexPath: IndexPath) {
    guard let model = self as? SelectableModelType else {
      assertionFailure("Invalid cellModel type \(self)")
      return
    }
    selectionAction?(model, indexPath)
  }
}

// MARK: - ListBindableCellModel
public protocol ListBindableCellModelWrapper {
  func willBind()
}

public protocol ListBindableCellModel: ListBindableCellModelWrapper {
  associatedtype BindableModelType: ListCellModel
  typealias BindAction = (_ cellModel: BindableModelType) -> Void

  var willBindAction: BindAction? { get }
}

extension ListBindableCellModel {
  public func willBind() {
    guard let model = self as? BindableModelType else {
      assertionFailure("Invalid cellModel type \(self)")
      return
    }
    willBindAction?(model)
  }
}
