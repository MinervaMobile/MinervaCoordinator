//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

/// Represents a section in the collection view.
public struct ListSection {
  /// How the cells should be arranged in the collection view
  public enum Distribution: Hashable {
    /// Cells should take up the entire row and during sizing are constrained to the entire
    /// width or height depending on scroll direction
    case entireRow
    /// Cells should be divided equally with |cellsInRow| cells per row. During sizing the
    /// cells are constrained to the available space divided by the # of cells in the row.
    case equally(cellsInRow: Int)
    /// Cells should take up however much space they want with no guidance on the #
    /// per row.
    case proportionally
    /// Identical to proportionally except that the last cell will take up the remaining width.
    /// If `minimumWidth` is not available, it will be full width on a new line.
    /// This is useful when, for example, displaying an input field at the end of an array of items.
    /// Your last cellModel should return `.relative` from  `size(constrainedTo:)` to get
    /// fill-remaining-width behavior, or  `.autolayout` to keep `.proportionally` behavior.
    case proportionallyWithLastCellFillingWidth(minimumWidth: CGFloat)
  }

  /// Information the section uses to size its cells.
  public struct Constraints: Hashable {
    /// Insets for the given section.
    public var inset: UIEdgeInsets = .zero
    /// Spacing between each line of cells.
    public var minimumLineSpacing: CGFloat = 0
    /// Spacing between each item on the same line.
    public var minimumInteritemSpacing: CGFloat = 0
    /// How cells are arranged in this section.
    public var distribution: Distribution = .entireRow
    /// Which direction this section scrolls. Currently all sections in the collection view must
    /// use the same scrollDirection, but on iOS13+ this requirement may be dropped.
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical

    public init() {}
  }

  /// A unique identifier for the section. The identifier should be the same even if the underlying cells change,
  /// otherwise it will trigger a section delete / insert rather than animating individual cell changes.
  public let identifier: String
  /// The constraints to use when laying out the cells in the section.
  public var constraints = Constraints()
  /// The section's supplementary header cell's model if one exists.
  public var headerModel: ListCellModel?
  /// The section's supplementary footer cell's model if one exists.
  public var footerModel: ListCellModel?
  /// The cell models to display in this section.
  public var cellModels: [ListCellModel]

  /// Creates a new section.
  /// - Parameter cellModels: The cell models to include in the section.
  /// - Parameter identifier: The unique identifier for this section.
  public init(cellModels: [ListCellModel], identifier: String) {
    self.cellModels = cellModels
    self.identifier = identifier
  }
}

// MARK: - CustomStringConvertible

extension ListSection: CustomStringConvertible {
  public var description: String {
    "[\(type(of: self)) identifier=\(identifier) constraints=\(constraints) header=\(headerModel.debugDescription) footer=\(footerModel.debugDescription) models=\(cellModels)]"
  }
}

// MARK: - Equatable

extension ListSection: Equatable {
  private static func areEqual(_ leftModel: ListCellModel?, _ rightModel: ListCellModel?) -> Bool {
    guard let left = leftModel else { return rightModel == nil }
    guard let right = rightModel else { return false }
    return left.identifier == right.identifier
  }

  public static func == (lhs: ListSection, rhs: ListSection) -> Bool {
    guard lhs.identifier == rhs.identifier else { return false }
    guard lhs.constraints == rhs.constraints else { return false }
    guard areEqual(lhs.headerModel, rhs.headerModel) else { return false }
    guard areEqual(lhs.footerModel, rhs.footerModel) else { return false }
    return true
  }
}
