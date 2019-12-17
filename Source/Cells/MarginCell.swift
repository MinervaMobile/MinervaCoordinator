//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

open class MarginCellModel: BaseListCellModel {

  public var backgroundColor: UIColor?
  public let cellSize: ListCellSize

  public init(identifier: String = UUID().uuidString, cellSize: ListCellSize = .relative) {
    self.cellSize = cellSize
    super.init(identifier: identifier)
  }

  public convenience init(identifier: String, height: CGFloat) {
    self.init(
      identifier: identifier,
      cellSize: .explicit(size: CGSize(width: 0, height: height))
    )
  }

  public convenience init(identifier: String, width: CGFloat) {
    self.init(
      identifier: identifier,
      cellSize: .explicit(size: CGSize(width: width, height: 0))
    )
  }

  // MARK: - BaseListCellModel

  override open func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    cellSize
  }

  override open func identical(to model: ListCellModel) -> Bool {
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
