//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva

public class FakeReferenceCellModel: ListTypedCellModel {
  public typealias CellType = FakeReferenceCell

  public var identifier: String
  public var size: ListCellSize

  public init(identifier: String, size: ListCellSize) {
    self.identifier = identifier
    self.size = size
  }

  public func identical(to model: FakeReferenceCellModel) -> Bool {
    identifier == model.identifier
  }

  public func size(constrainedTo containerSize: CGSize) -> ListCellSize {
    size
  }
}

public final class FakeReferenceCell: ListCollectionViewCell, ListTypedCell, ListResizableCell {
  public weak var resizableDelegate: ListResizableCellDelegate?

  public func bind(model: FakeReferenceCellModel, sizing: Bool) {}
  public func bindViewModel(_ viewModel: Any) { bind(viewModel) }
}
