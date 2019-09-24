//
//  BaseListCellModel.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class BaseListCellModel: ListCellModel {

  public init() { }

  open var description: String {
    return "[\(String(describing: type(of: self))) \(identifier)]"
  }

  // MARK: - ListCellModel

  open var reorderable: Bool {
    return false
  }
  open var identifier: String {
    let identifier = String(describing: Unmanaged.passUnretained(self).toOpaque())
    guard !identifier.isEmpty else {
      assertionFailure("The identifier should exist for \(self)")
      return UUID().uuidString
    }
    return identifier
  }
  open var cellType: ListCollectionViewCell.Type {
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

  open func isEqual(to model: ListCellModel) -> Bool {
    return identifier == model.identifier
  }
  open func size(constrainedTo containerSize: CGSize) -> ListCellSize {
    return .autolayout
  }
}
