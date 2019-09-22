//
//  ListSizeConstraints.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

public struct ListSizeConstraints: Equatable {

  public let containerSize: CGSize
  public let sectionConstraints: ListSection.Constraints

  public init(
    containerSize: CGSize,
    sectionConstraints: ListSection.Constraints
  ) {
    self.containerSize = containerSize
    self.sectionConstraints = sectionConstraints
  }

  public var containerSizeAdjustedForInsets: CGSize {
    return containerSize.adjust(for: inset)
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
