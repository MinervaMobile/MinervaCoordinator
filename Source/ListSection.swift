//
//  ListSection.swift
//  Minerva
//
//  Created by Joe Laws
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

public class ListSection: NSObject, ListDiffable {

  public var minimumLineSpacing: CGFloat = 0
  public var minimumInteritemSpacing: CGFloat = 0
  public var distribution: ListRowDistribution = .entireRow

  public var cellModels: [ListCellModel]
  public var headerModel: ListCellModel?
  public var footerModel: ListCellModel?

  public let identifier: String

  public init(cellModels: [ListCellModel], identifier: String) {
    self.cellModels = cellModels
    self.identifier = identifier
  }

  public func height(for containerSize: CGSize) -> CGFloat? {
    switch distribution {
    case .entireRow:
      return cellModels.reduce(0, { sum, model -> CGFloat in
        let modelHeight = model.size(constrainedTo: containerSize)?.height ?? 0
        return sum + modelHeight + minimumLineSpacing
      })
    case .equally(let cellsInRow):
      var totalHeight: CGFloat = 0
      var rowHeight: CGFloat = 0
      for (index, model) in cellModels.enumerated() {
        if index % cellsInRow == 0 {
          totalHeight += (rowHeight + minimumLineSpacing)
          rowHeight = 0
        }
        let modelHeight = model.size(constrainedTo: containerSize)?.height ?? 0
        rowHeight = max(rowHeight, modelHeight)
      }
      totalHeight += (rowHeight + minimumLineSpacing)
      return totalHeight
    case .proportionally:
      var height: CGFloat = 0
      var maxCellHeightInRow: CGFloat = 0
      var currentRowWidth: CGFloat = 0
      for model in cellModels {
        guard let modelSize = model.size(constrainedTo: containerSize) else {
          continue
        }
        let modelHeight = modelSize.height + minimumLineSpacing
        let modelWidth = modelSize.width + minimumInteritemSpacing
        maxCellHeightInRow = max(maxCellHeightInRow, modelHeight)
        currentRowWidth += modelWidth
        guard currentRowWidth < containerSize.width else {
          height += maxCellHeightInRow
          maxCellHeightInRow = modelHeight
          currentRowWidth = modelWidth
          continue
        }
      }
      height += maxCellHeightInRow
      return height
    }
  }

  // MARK: - ListDiffable

  public func diffIdentifier() -> NSObjectProtocol {
    return self.identifier as NSString
  }

  public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let other = object as? ListSection else { return false }
    return self.identifier == other.identifier
  }
}
