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
  func identical(to model: ListCellModel) -> Bool
  func size(constrainedTo containerSize: CGSize, with templateProvider: () -> ListCollectionViewCell) -> ListCellSize
}

extension ListCellModel {
  public var description: String {
    return "[\(String(describing: type(of: self))) \(identifier)]"
  }
}

extension ListCellModel where Self: AnyObject {
  public var typeIdentifier: String {
    let identifier = String(describing: Unmanaged.passUnretained(self).toOpaque())
    guard !identifier.isEmpty else {
      assertionFailure("The identifier should exist for \(self)")
      return UUID().uuidString
    }
    return identifier
  }
  public var cellTypeFromModelName: ListCollectionViewCell.Type {
    let modelType = type(of: self)
    let className = String(describing: modelType).replacingOccurrences(of: "Model", with: "")
    if let cellType = NSClassFromString(className) as? ListCollectionViewCell.Type {
      return cellType
    }
    let bundle = Bundle(for: modelType)
    let bundleName = bundle.infoDictionary?["CFBundleName"] as? String ?? ""
    let fullClassName = "\(bundleName).\(className)"
    let cleanedClassName = fullClassName.replacingOccurrences(of: " ", with: "_")
    if let cellType = NSClassFromString(cleanedClassName) as? ListCollectionViewCell.Type {
      return cellType
    }
    assertionFailure("Unable to determine the cell type")
    return BaseListCell.self
  }
}

extension ListCellModel where Self: Equatable {
  public func identical(to model: ListCellModel) -> Bool {
    guard let other = model as? Self else { return false }
    return self == other
  }
}

// MARK: - ListSelectableCellModel
public protocol ListSelectableCellModelWrapper {
  func selected(at indexPath: IndexPath)
}

public protocol ListSelectableCellModel: ListSelectableCellModelWrapper {
  typealias SelectionAction = (_ cellModel: Self, _ indexPath: IndexPath) -> Void

  var selectionAction: SelectionAction? { get }
}

extension ListSelectableCellModel {
  public func selected(at indexPath: IndexPath) {
    selectionAction?(self, indexPath)
  }
}

// MARK: - ListBindableCellModel
public protocol ListBindableCellModelWrapper {
  func willBind()
}

public protocol ListBindableCellModel: ListBindableCellModelWrapper {
  typealias BindAction = (_ cellModel: Self) -> Void

  var willBindAction: BindAction? { get }
}

extension ListBindableCellModel {
  public func willBind() {
    willBindAction?(self)
  }
}

// MARK: - TypedListCellModel
public protocol TypedListCellModel: ListCellModel {
  associatedtype CellType: ListCollectionViewCell

  func identical(to model: Self) -> Bool
  func size(constrainedTo containerSize: CGSize, with templateProvider: () -> CellType) -> ListCellSize
}

extension TypedListCellModel {

  public var cellType: ListCollectionViewCell.Type {
    return CellType.self
  }
  public func identical(to other: ListCellModel) -> Bool {
    guard let model = other as? Self else {
      return false
    }
    return identical(to: model)
  }
  public func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    return size(constrainedTo: containerSize) { () -> CellType in
      let cell = templateProvider()
      guard let typedTemplate = cell as? CellType else {
        assertionFailure("Invalid cell type \(cell)")
        return CellType()
      }
      return typedTemplate
    }
  }
}

extension TypedListCellModel where Self: Equatable {
  public func identical(to model: Self) -> Bool {
    return self == model
  }
}
