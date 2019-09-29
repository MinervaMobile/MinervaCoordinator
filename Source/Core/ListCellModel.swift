//
//  ListCellModel.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public enum ListCellSize {
  case autolayout
  case explicit(size: CGSize)
  case relative
}

// MARK: - ListCellModel
public protocol ListCellModel: CustomStringConvertible {
  var reorderable: Bool { get }
  var identifier: String { get }
  var cellType: ListCollectionViewCell.Type { get }
  func isEqual(to model: ListCellModel) -> Bool
  func size(constrainedTo containerSize: CGSize) -> ListCellSize
}

extension ListCellModel {
  public var description: String {
    return "[\(String(describing: type(of: self))) \(identifier)]"
  }
}

extension ListCellModel where Self: Equatable {
  public func isEqual(to model: ListCellModel) -> Bool {
    guard let other = model as? Self else { return false }
    return self == other
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
