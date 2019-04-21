//
//  BaseListBindableCell.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

open class BaseListBindableCell: BaseListCell, ListBindableCell {

  public private(set) var disposeBag = DisposeBag()

  open override func prepareForReuse() {
    disposeBag.clear()
    super.prepareForReuse()
  }

  // MARK: - ListBindable

  public override func bindViewModel(_ viewModel: Any) {
    disposeBag.clear()
    super.bindViewModel(viewModel)
  }
}
