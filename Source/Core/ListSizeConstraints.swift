//
//  ListSizeConstraints.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public struct ListSizeConstraints: Hashable {

  public let containerSize: CGSize
  public let sectionConstraints: ListSection.Constraints

  public init(
    containerSize: CGSize,
    sectionConstraints: ListSection.Constraints
  ) {
    self.containerSize = containerSize
    self.sectionConstraints = sectionConstraints
  }

  /// The container size adjusted for the insets, distribution, minimumInteritemSpacing, scroll direction
  public var adjustedContainerSize: CGSize {
    let insetSize = containerSize.adjust(for: inset)
    guard case .equally(let cellsInRow) = distribution else {
      return insetSize
    }
    let rowWidth = insetSize.width
    let rowHeight = insetSize.height
    let maxSize: CGSize
    if scrollDirection == .vertical {
      let equalCellWidth = (rowWidth / CGFloat(cellsInRow))
        - (minimumInteritemSpacing * CGFloat(cellsInRow - 1) / CGFloat(cellsInRow))
      maxSize = CGSize(width: equalCellWidth, height: rowHeight)
    } else {
      let equalCellHeight = (rowHeight / CGFloat(cellsInRow))
        - (minimumInteritemSpacing * CGFloat(cellsInRow - 1) / CGFloat(cellsInRow))
      maxSize = CGSize(width: rowWidth, height: equalCellHeight)
    }
    return maxSize
  }

  public var inset: UIEdgeInsets {
    return sectionConstraints.inset
  }
  public var minimumLineSpacing: CGFloat {
    return sectionConstraints.minimumLineSpacing
  }
  public var minimumInteritemSpacing: CGFloat {
    return sectionConstraints.minimumInteritemSpacing
  }
  public var distribution: ListSection.Distribution {
    return sectionConstraints.distribution
  }
  public var scrollDirection: UICollectionView.ScrollDirection {
    return sectionConstraints.scrollDirection
  }
}
