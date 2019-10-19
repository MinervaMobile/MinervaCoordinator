//
//  BaseListBindableCell.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class BaseListBindableCell: BaseListCell, ListBindableCell {

  public private(set) var disposeBag = MinervaDisposeBag()

  override open func prepareForReuse() {
    disposeBag.clear()
    super.prepareForReuse()
  }

  // MARK: - ListBindable

  override open func didUpdateCellModel() {
    disposeBag.clear()
    super.didUpdateCellModel()
  }
}
