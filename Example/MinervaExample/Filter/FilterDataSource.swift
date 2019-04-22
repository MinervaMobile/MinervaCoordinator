//
//  FilterDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

protocol FilterDataSourceDelegate: class {
  func filterDataSource(_ filterDataSource: FilterDataSource, selected action: FilterDataSource.Action)
}

final class FilterDataSource: CollectionViewControllerDataSource {
  enum Action {
    case edit(filter: WorkoutFilter, type: FilterType)
  }

  weak var delegate: FilterDataSourceDelegate?

  public var filter: WorkoutFilter

  // MARK: - Lifecycle

  init(filter: WorkoutFilter) {
    self.filter = filter
  }

  // MARK: - Public

  func loadSections() -> Promise<[ListSection]> {
    return .value([createSection()])
  }

  // MARK: - Private

  private func createSection() -> ListSection {
    var cellModels = [ListCellModel]()

    cellModels.append(LabelCellModel.createSectionHeaderModel(title: "FILTERS"))

    for type in FilterType.allCases {
      let nameCellModel = LabelAccessoryCellModel.createSettingsCellModel(
        title: type.description,
        details: filter.details(for: type) ?? "---",
        hasChevron: true)
      nameCellModel.selectionAction = { [weak self] _, _ -> Void in
        guard let strongSelf = self else { return }
        strongSelf.delegate?.filterDataSource(
          strongSelf,
          selected: .edit(filter: strongSelf.filter, type: type))
      }
      cellModels.append(nameCellModel)
    }

    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return section
  }

}
