//
//  FilterActionSheetDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

protocol FilterActionSheetDataSourceDelegate: class {
  func filterActionSheetDataSource(
    _ filterActionSheetDataSource: FilterActionSheetDataSource,
    selected action: FilterActionSheetDataSource.Action)
}

final class FilterActionSheetDataSource: ActionSheetDataSource {
  enum Action {
    case update(filter: WorkoutFilter)
  }

  private static let dateCellModelIdentifier = "DateCellModel"

  weak var delegate: FilterActionSheetDataSourceDelegate?

  private let type: FilterType
  private var filter: WorkoutFilterProto

  // MARK: - Lifecycle

  init(type: FilterType, filter: WorkoutFilter) {
    self.type = type
    self.filter = filter.proto
  }

  // MARK: - Public

  func loadCellModels() -> [ListCellModel] {
    let leftAction: LabelCellModel.SelectionAction = { [weak self] _, _ -> Void in
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
      strongSelf.delegate?.filterActionSheetDataSource(strongSelf, selected: .update(filter: strongSelf.filter))
    }
    let rightAction: LabelCellModel.SelectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.filterActionSheetDataSource(strongSelf, selected: .update(filter: strongSelf.filter))
    }
    let headerSectionModel = ActionSheetVC.createHeaderModel(
      identifier: "ActionSheetHeader",
      leftText: "Remove",
      centerText: type.description,
      rightText: "Update",
      leftAction: leftAction,
      rightAction: rightAction)

    return [
      headerSectionModel,
      MarginCellModel(cellIdentifier: "headerMarginModel", height: 12),
      createDateCellModel(),
      MarginCellModel(cellIdentifier: "dateMarginModel", height: 12)
    ]
  }

  // MARK: - Helpers

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
