//
//  ListSection.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public struct ListSection {

  public enum Distribution: Hashable {
    case entireRow
    case equally(cellsInRow: Int)
    case proportionally
  }

  public struct Constraints: Hashable {
    public var inset: UIEdgeInsets = .zero
    public var minimumLineSpacing: CGFloat = 0
    public var minimumInteritemSpacing: CGFloat = 0
    public var distribution: Distribution = .entireRow
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical

    public init() { }
  }

  public var constraints: Constraints = Constraints()
  public var cellModels: [ListCellModel]
  public var headerModel: ListCellModel?
  public var footerModel: ListCellModel?

  public let identifier: String

  public init(cellModels: [ListCellModel], identifier: String) {
    self.cellModels = cellModels
    self.identifier = identifier
  }
}

// MARK: - Equatable
extension ListSection: Equatable {
  public static func == (lhs: ListSection, rhs: ListSection) -> Bool {
    guard lhs.identifier == rhs.identifier && lhs.constraints == rhs.constraints else { return false }
    guard lhs.cellModels.count == rhs.cellModels.count else { return false }
    func areEqual(_ leftModel: ListCellModel?, _ rightModel: ListCellModel?) -> Bool {
      guard let left = leftModel else {
        return rightModel == nil
      }
      guard let right = rightModel else {
        return false
      }
      return left.isEqual(to: right)
    }
    guard areEqual(lhs.headerModel, rhs.headerModel) else {
      return false
    }
    guard areEqual(lhs.footerModel, rhs.footerModel) else {
      return false
    }
    return zip(lhs.cellModels, rhs.cellModels).allSatisfy { $0.0.isEqual(to: $0.1) }
  }
}
