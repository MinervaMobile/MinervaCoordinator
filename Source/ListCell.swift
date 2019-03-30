//
//  ListCell.swift
//  Minerva
//
//  Created by Joe Laws
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

public typealias ListCollectionViewCell = UICollectionViewCell & ListCell

// MARK: - ListCell
public protocol ListCell: ListBindable {
  var cellModel: ListCellModel? { get }

  func willDisplayCell()
  func didEndDisplayingCell()
}

// MARK: - ListBindableCell
public protocol ListBindableCell: ListCell {
  var disposeBag: DisposeBag { get }
}

extension ListBindableCell {
  public func bind(_ variable: Observable<UIImage?>, to imageView: UIImageView) {
    self.bind(variable) { [weak imageView] image in
      imageView?.image = image
    }
  }

  public func bind<T>(_ variable: Observable<T>, with completion: @escaping (T) -> Void) {
    variable.subscribe(in: self.disposeBag, completion)
  }
}

// MARK: - ListCellHelper
public protocol ListCellHelper: ListCell {
  associatedtype ModelType: ListCellModel
}

extension ListCellHelper {
  public var model: ModelType? {
    guard let cellModel = self.cellModel else { return nil }
    guard let model = cellModel as? ModelType else {
      assertionFailure("Invalid cellModel type \(cellModel)")
      return nil
    }
    return model
  }
}
