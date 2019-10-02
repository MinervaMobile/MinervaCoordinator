//
//  ListCell.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

// TODO: Remove this dependency on IGListKit's ListBindable
public typealias ListCollectionViewCell = UICollectionViewCell & ListCell & ListBindable

// MARK: - ListCell
public protocol ListCell {
  var cellModel: ListCellModel? { get }

  func willDisplayCell()
  func didEndDisplayingCell()
}

// MARK: - ListCellHelper
public protocol ListCellHelper: ListCell {
  associatedtype ModelType: ListCellModel
}

extension ListCellHelper {
  public var model: ModelType? {
    guard let cellModel = self.cellModel else { return nil }
    guard let model = cellModel as? ModelType else {
      assertionFailure("Invalid cellModel type \(cellModel)")
      return nil
    }
    return model
  }
}
