//
//  ListBindableCell.swift
//  MinervaExample
//
//  Created by Joe Laws on 10/2/19.
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

// MARK: - ListBindableCell
public protocol ListBindableCell: ListCell {
  var disposeBag: MinervaDisposeBag { get }
}

extension ListBindableCell {
  public func bind(_ variable: MinervaObservable<UIImage?>, to imageView: UIImageView) {
    bind(variable) { [weak imageView] image in
      imageView?.image = image
    }
  }

  public func bind<T>(_ variable: MinervaObservable<T>, with completion: @escaping (T) -> Void) {
    variable.subscribe(in: self.disposeBag, completion)
  }
}
