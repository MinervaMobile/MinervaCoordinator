//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

open class BaseListCellModel: ListCellModel {
  private let cellIdentifier: String?

  public init(identifier: String? = nil) {
    self.cellIdentifier = identifier
  }

  // MARK: - ListCellModel
  open var identifier: String { cellIdentifier ?? typeIdentifier }
  open var cellType: ListCollectionViewCell.Type { cellTypeFromModelName }

  open func identical(to model: ListCellModel) -> Bool {
    identifier == model.identifier
  }
  open func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    return .autolayout
  }
}

open class BaseListCell<CellModelType: ListCellModel>: ListCollectionViewCell {
  open private(set) var model: CellModelType?
  open private(set) var highlightView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()

  override open var isHighlighted: Bool {
    didSet {
      guard let highlightModel = model as? ListHighlightableCellModelWrapper,
        highlightModel.highlightEnabled else {
          self.highlightView.isHidden = true
          return
      }

      self.highlightView.isHidden = !self.isHighlighted
    }
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(highlightView)
    highlightView.anchor(to: contentView)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    guard let attributes = layoutAttributes as? ListViewLayoutAttributes else {
      return
    }
    if let animation = attributes.animationGroup {
      self.layer.add(animation, forKey: nil)
    }
  }

  override open func prepareForReuse() {
    super.prepareForReuse()
    model = nil
  }

  open func bind(model: CellModelType, sizing: Bool) {
    guard !sizing else { return }
    if let model = model as? ListBindableCellModelWrapper {
      model.willBind()
    }
    self.model = model
  }

  // MARK: - ListCell

  public final func bindViewModel(_ viewModel: Any) {
    guard let wrapper = viewModel as? ListCellModelWrapper else {
      assertionFailure("Invalid view model \(viewModel)")
      return
    }

    bind(cellModel: wrapper.model, sizing: false)
  }

  public final func bind(cellModel: ListCellModel, sizing: Bool) {
    guard let model = cellModel as? CellModelType else {
      assertionFailure("Unknown cell model type \(CellModelType.self) for \(cellModel)")
      self.model = nil
      return
    }
    if !sizing {
      if let highlightableViewModel = cellModel as? ListHighlightableCellModelWrapper,
        highlightableViewModel.highlightEnabled {
        highlightView.backgroundColor = highlightableViewModel.highlightColor
      }
    }
    bind(model: model, sizing: sizing)
  }
}

open class BaseReactiveListCell<CellModelType: ListCellModel>: BaseListCell<CellModelType> {
  public private(set) var disposeBag = DisposeBag()

  override open func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  override open func bind(model: CellModelType, sizing: Bool) {
    disposeBag = DisposeBag()
    super.bind(model: model, sizing: sizing)
  }
}
