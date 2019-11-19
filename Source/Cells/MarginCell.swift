//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

public final class MarginCellModel: BaseListCellModel, ListSelectableCellModel {

  public enum Location {
    case top
    case bottom
    case other(identifier: String)

    public var cellIdentifier: String {
      switch self {
      case .top: return "topDynamicMarginModelIdentifier"
      case .bottom: return "bottomDynamicMarginModelIdentifier"
      case .other(let identifier): return identifier
      }
    }
  }

  public var selectionAction: ((_ cellModel: MarginCellModel, _ indexPath: IndexPath) -> Void)?
  private let cellIdentifier: String

  public var backgroundColor: UIColor?
  private let cellSize: ListCellSize

  public init(location: Location, cellSize: ListCellSize = .relative) {
    self.cellIdentifier = location.cellIdentifier
    self.cellSize = cellSize
    super.init()
  }

  public convenience init(identifier: String, height: CGFloat) {
    self.init(
      location: .other(identifier: identifier),
      cellSize: .explicit(size: CGSize(width: 0, height: height))
    )
  }

  // MARK: - BaseListCellModel

  override public var identifier: String { cellIdentifier }

  override public func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    cellSize
  }

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return backgroundColor == model.backgroundColor
      && cellSize == model.cellSize
  }
}

public final class MarginCell: BaseListCell<MarginCellModel> {

  override public func bind(model: MarginCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)

    guard !sizing else { return }

    self.contentView.backgroundColor = model.backgroundColor
  }
}
