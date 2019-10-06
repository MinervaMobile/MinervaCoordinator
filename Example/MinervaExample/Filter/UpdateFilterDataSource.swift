//
//  UpdateFilterDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

protocol UpdateFilterDataSourceDelegate: AnyObject {
  func updateFilterDataSource(
    _ updateFilterDataSource: UpdateFilterDataSource,
    selected action: UpdateFilterDataSource.Action)
}

final class UpdateFilterDataSource: BaseDataSource {
  enum Action {
    case update(filter: WorkoutFilter)
  }

  private static let dateCellModelIdentifier = "DateCellModel"

  weak var delegate: UpdateFilterDataSourceDelegate?

  private let type: FilterType
  private var filter: WorkoutFilterProto

  // MARK: - Lifecycle

  init(type: FilterType, filter: WorkoutFilter) {
    self.type = type
    self.filter = filter.proto
  }

  // MARK: - Public

  func reload(animated: Bool) {
    updateDelegate?.dataSourceStartedUpdate(self)
    let section = createSection()
    updateDelegate?.dataSource(self, update: [section], animated: animated, completion: nil)
    updateDelegate?.dataSourceCompletedUpdate(self)
  }

  // MARK: - Helpers

  private func createSection() -> ListSection {
    let cellModels = loadCellModels()
    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return section
  }

  private func loadCellModels() -> [ListCellModel] {

    let cancelModel = LabelCell.Model(identifier: "cancelModel", text: "Remove", font: .titleLarge)
    cancelModel.leftMargin = 0
    cancelModel.rightMargin = 0
    cancelModel.textAlignment = .center
    cancelModel.textColor = .selectable
    cancelModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      switch strongSelf.type {
      case .endDate:
        strongSelf.filter.endDate = nil
      case .endTime:
        strongSelf.filter.endTime = nil
      case .startDate:
        strongSelf.filter.startDate = nil
      case .startTime:
        strongSelf.filter.startTime = nil
      }
      strongSelf.delegate?.updateFilterDataSource(strongSelf, selected: .update(filter: strongSelf.filter))
    }

    let doneModel = LabelCell.Model(identifier: "doneModel", text: "Update", font: .titleLarge)
    doneModel.leftMargin = 0
    doneModel.rightMargin = 0
    doneModel.textAlignment = .center
    doneModel.textColor = .selectable
    doneModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.updateFilterDataSource(strongSelf, selected: .update(filter: strongSelf.filter))
    }

    return [
      MarginCellModel(cellIdentifier: "headerMarginModel", height: 12),
      createDateCellModel(),
      MarginCellModel(cellIdentifier: "dateMarginModel", height: 12),
      doneModel,
      MarginCellModel(cellIdentifier: "doneMarginModel", height: 12),
      cancelModel,
      MarginCellModel(cellIdentifier: "cancelMarginModel", height: 12)
    ]
  }

  private func createDateCellModel() -> ListCellModel {
    let startDate = filter.date(for: type) ?? Date()
    updateFilter(for: startDate)
    let cellModel = DatePickerCellModel(identifier: "dateCellModel", startDate: startDate)
    switch type {
    case .startDate:
      cellModel.maximumDate = filter.endDate
      cellModel.mode = .date
    case .endDate:
      cellModel.minimumDate = filter.startDate
      cellModel.mode = .date
    case .startTime:
      cellModel.maximumDate = filter.endTime
      cellModel.mode = .time
    case .endTime:
      cellModel.minimumDate = filter.startTime
      cellModel.mode = .time
    }
    cellModel.changedDate = { [weak self] _, date -> Void in
      guard let strongSelf = self else { return }
      strongSelf.updateFilter(for: date)
    }
    return cellModel
  }

  private func updateFilter(for date: Date) {
    switch type {
    case .endDate:
      filter.endDate = date
    case .endTime:
      filter.endTime = date
    case .startDate:
      filter.startDate = date
    case .startTime:
      filter.startTime = date
    }
  }
}
