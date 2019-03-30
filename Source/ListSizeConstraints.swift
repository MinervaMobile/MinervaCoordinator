//
//  ListSizeConstraints.swift
//  Minerva
//
//  Created by Joe Laws
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public enum ListRowDistribution {
  case entireRow
  case equally(cellsInRow: Int)
  case proportionally
}

public struct ListSizeConstraints {

  public var containerSizeAdjustedForInsets: CGSize {
    return containerSize.adjust(for: inset)
  }

  public let containerSize: CGSize
  public let inset: UIEdgeInsets
  public let minimumLineSpacing: CGFloat
  public let minimumInteritemSpacing: CGFloat
  public let distribution: ListRowDistribution

  public init(
    containerSize: CGSize,
    inset: UIEdgeInsets,
    minimumLineSpacing: CGFloat,
    minimumInteritemSpacing: CGFloat,
    distribution: ListRowDistribution
  ) {
    self.containerSize = containerSize
    self.inset = inset
    self.minimumLineSpacing = minimumLineSpacing
    self.minimumInteritemSpacing = minimumInteritemSpacing
    self.distribution = distribution
  }
}
