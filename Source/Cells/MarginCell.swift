//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

public final class MarginCellModel: BaseListCellModel, ListSelectableCellModel {

  public var selectionAction: ((_ cellModel: MarginCellModel, _ indexPath: IndexPath) -> Void)?
  private let cellIdentifier: String

  public var backgroundColor: UIColor?
  public let cellSize: ListCellSize

  public init(identifer: String, cellSize: ListCellSize = .relative) {
    self.cellIdentifier = identifer
    self.cellSize = cellSize
    super.init()
  }

  public convenience init(cellSize: ListCellSize = .relative) {
    self.init(identifer: UUID().uuidString, cellSize: cellSize)
  }

  public convenience init(identifier: String, height: CGFloat) {
    self.init(
      identifer: identifier,
      cellSize: .explicit(size: CGSize(width: 0, height: height))
    )
  }

  public convenience init(identifier: String, width: CGFloat) {
    self.init(
      identifer: identifier,
      cellSize: .explicit(size: CGSize(width: width, height: 0))
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
