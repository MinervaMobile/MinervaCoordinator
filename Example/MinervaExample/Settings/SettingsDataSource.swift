//
//  SettingsDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

protocol SettingsDataSourceDelegate: AnyObject {
  func settingsDataSource(_ settingsDataSource: SettingsDataSource, selected action: SettingsDataSource.Action)
}

final class SettingsDataSource: CollectionViewControllerDataSource {
  enum Action {
    case deleteAccount
    case logout
    case update(user: User)
  }

  weak var delegate: SettingsDataSourceDelegate?
  private var user: User = UserProto(userID: UUID().uuidString, email: "unknown", dailyCalories: 2_000)

  private let dataManager: DataManager
  // MARK: - Lifecycle

  init(dataManager: DataManager) {
    self.dataManager = dataManager
  }

  // MARK: - Public

  func loadSections() -> Promise<[ListSection]> {
    return dataManager.loadUser(
      withID: dataManager.userAuthorization.userID
    ).then { [weak self] user -> Promise<[ListSection]> in
      guard let strongSelf = self else { return .init(error: SystemError.cancelled) }
      guard let user = user else { return .init(error: SystemError.doesNotExist) }
      strongSelf.user = user
      return .value([strongSelf.createSection()])
    }.recover { [weak self] error -> Promise<[ListSection]> in
      guard let strongSelf = self else { return .init(error: SystemError.cancelled) }
      return .value([strongSelf.createSection()])
    }
  }

  // MARK: - Private

  private func createSection() -> ListSection {
    var cellModels = [ListCellModel]()

    cellModels.append(LabelCellModel.createSectionHeaderModel(title: "USER"))

    let nameCellModel = LabelAccessoryCellModel.createSettingsCellModel(title: "Name", details: user.email, hasChevron: true)
    nameCellModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.settingsDataSource(strongSelf, selected: .update(user: strongSelf.user))
    }
    cellModels.append(nameCellModel)

    let caloriesCellModel = LabelAccessoryCellModel.createSettingsCellModel(
      title: "Daily Calories",
      details: String(user.dailyCalories),
      hasChevron: true)
    caloriesCellModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.settingsDataSource(strongSelf, selected: .update(user: strongSelf.user))
    }
    cellModels.append(caloriesCellModel)

    let roleCellModel = LabelAccessoryCellModel.createSettingsCellModel(
      title: "Role",
      details: dataManager.userAuthorization.role.description,
      hasChevron: false)
    cellModels.append(roleCellModel)

    cellModels.append(LabelCellModel.createSectionHeaderModel(title: "ACCOUNT"))

    let logoutCellModel = LabelAccessoryCellModel.createSettingsCellModel(title: "Logout", details: nil, hasChevron: true)
    logoutCellModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.settingsDataSource(strongSelf, selected: .logout)
    }
    cellModels.append(logoutCellModel)

    let deleteCellModel = LabelAccessoryCellModel.createSettingsCellModel(title: "Delete", details: nil, hasChevron: true)
    deleteCellModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.settingsDataSource(strongSelf, selected: .deleteAccount)
    }
    cellModels.append(deleteCellModel)

    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return section
  }

}
