//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxRelay
import RxSwift
import UIKit

public final class DefaultSplitDetailPresenter: ListPresenter {

  public var sections = BehaviorRelay<[ListSection]>(value: [])

  private let disposeBag = DisposeBag()

  // MARK: - Lifecycle

  public init() {
    Observable
      .just(createSections())
      .bind(to: sections)
      .disposed(by: disposeBag)
  }

  // MARK: - Private

  private func createSections() -> [ListSection] {
    let cellModels = loadCellModels()
    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return [section]
  }

  private func loadCellModels() -> [ListCellModel] {

    let text = "Select an action on the left"
    let textModel = LabelCellModel(text: text, font: .headline)
    textModel.textAlignment = .center
    textModel.directionalLayoutMargins.top = 48

    return [
      textModel
    ]
  }
}
