//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import UIKit

open class DetailedLabelCellModel: BaseListCellModel {
  fileprivate static let labelMargin: CGFloat = 16

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

  public var numberOfLines = 0
  public var backgroundColor: UIColor?

  fileprivate let attributedTitle: NSAttributedString
  fileprivate let attributedDetails: NSAttributedString

  public init(identifier: String, attributedTitle: NSAttributedString, attributedDetails: NSAttributedString) {
    self.attributedTitle = attributedTitle
    self.attributedDetails = attributedDetails
    super.init(identifier: identifier)
  }

  public convenience init(attributedTitle: NSAttributedString, attributedDetails: NSAttributedString) {
    self.init(
      identifier: "\(attributedTitle.string)-\(attributedDetails.string)",
      attributedTitle: attributedTitle,
      attributedDetails: attributedDetails)
  }

  // MARK: - BaseListCellModel

  override open func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return attributedTitle == model.attributedTitle
      && attributedDetails == model.attributedDetails
      && numberOfLines == model.numberOfLines
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }
}

public final class DetailedLabelCell: BaseListCell<DetailedLabelCellModel> {

  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.numberOfLines = 0
    return label
  }()
  private let detailedLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.numberOfLines = 0
    return label
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    backgroundView = UIView()
    contentView.addSubview(label)
    contentView.addSubview(detailedLabel)
    setupConstraints()
  }

  override public func bind(model: DetailedLabelCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    label.attributedText = model.attributedTitle
    detailedLabel.attributedText = model.attributedDetails
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    guard !sizing else { return }

    backgroundView?.backgroundColor = model.backgroundColor
  }
}

// MARK: - Constraints
extension DetailedLabelCell {
  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide

    label.anchor(
      toLeading: layoutGuide.leadingAnchor,
      top: layoutGuide.topAnchor,
      trailing: nil,
      bottom: layoutGuide.bottomAnchor
    )
    detailedLabel.leadingAnchor.constraint(
      equalTo: label.trailingAnchor,
      constant: DetailedLabelCellModel.labelMargin
    ).isActive = true
    detailedLabel.anchor(
      toLeading: nil,
      top: layoutGuide.topAnchor,
      trailing: layoutGuide.trailingAnchor,
      bottom: layoutGuide.bottomAnchor
    )

    label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    detailedLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
