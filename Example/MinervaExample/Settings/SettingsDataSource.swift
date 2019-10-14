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
import RxSwift

protocol SettingsDataSourceDelegate: AnyObject {
  func settingsDataSource(_ settingsDataSource: SettingsDataSource, selected action: SettingsDataSource.Action)
}

final class SettingsDataSource: BaseDataSource {
  enum Action {
    case deleteAccount
    case logout
    case update(user: User)
  }

  weak var delegate: SettingsDataSourceDelegate?

  private let dataManager: DataManager

  // MARK: - Lifecycle

  init(dataManager: DataManager) {
    self.dataManager = dataManager
  }

  // MARK: - Public

  func reload(animated: Bool) {
    let sectionsPromise = dataManager.loadUser(
      withID: dataManager.userAuthorization.userID
    ).map { [weak self] user -> [ListSection] in
      guard let strongSelf = self else { throw SystemError.cancelled }
      guard let user = user else { throw SystemError.doesNotExist }
      return strongSelf.createSections(with: user)
    }.recover { [weak self] error -> Promise<[ListSection]> in
      guard let strongSelf = self else { return Promise(error: error) }
      strongSelf.updateDelegate?.dataSource(strongSelf, encountered: error)
      return .value(strongSelf.createSections(with: nil))
    }
    updateDelegate?.dataSource(self, process: sectionsPromise, animated: animated, completion: nil)
  }

  // MARK: - Private

  private func createSections(with user: User?) -> [ListSection] {
    var sections = [ListSection]()

    if let user = user {
      var cellModels = [ListCellModel]()

      let nameCellModel = SwiftUITextCellModel(title: "Name", subtitle: user.email)
      nameCellModel.selectionAction = { [weak self] _, _ -> Void in
        guard let strongSelf = self else { return }
        strongSelf.delegate?.settingsDataSource(strongSelf, selected: .update(user: user))
      }
      cellModels.append(nameCellModel)

      let caloriesCellModel = SwiftUITextCellModel(title: "Daily Calories", subtitle: String(user.dailyCalories))
      caloriesCellModel.selectionAction = { [weak self] _, _ -> Void in
        guard let strongSelf = self else { return }
        strongSelf.delegate?.settingsDataSource(strongSelf, selected: .update(user: user))
      }
      cellModels.append(caloriesCellModel)

      let roleCellModel = SwiftUITextCellModel(
        title: "Role",
        subtitle: dataManager.userAuthorization.role.description,
        hasChevron: false)
      roleCellModel.willBindAction = { [weak self] model in
        guard let strongSelf = self else { return }
        model.imagePublisher = strongSelf.dataManager.combineImage(forWorkoutID: "").eraseToAnyPublisher()
      }
      cellModels.append(roleCellModel)

      var section = ListSection(cellModels: cellModels, identifier: "USER")
      let headerModel = SwiftUITextCellModel(title: "USER", hasChevron: false)
      headerModel.backgroundColor = .secondarySystemBackground
      section.headerModel = headerModel
      sections.append(section)
    }

    var cellModels = [ListCellModel]()
    let logoutCellModel = SwiftUITextCellModel(title: "Logout")
    logoutCellModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.settingsDataSource(strongSelf, selected: .logout)
    }
    cellModels.append(logoutCellModel)

    let deleteCellModel = SwiftUITextCellModel(title: "Delete")
    deleteCellModel.willBindAction = { [weak self] model in
      guard let strongSelf = self else { return }
      model.imageObservable = strongSelf.dataManager.image(forWorkoutID: "a").asObservable()
    }
    deleteCellModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.settingsDataSource(strongSelf, selected: .deleteAccount)
    }
    cellModels.append(deleteCellModel)

    var section = ListSection(cellModels: cellModels, identifier: "ACCOUNT")
    let headerModel = SwiftUITextCellModel(title: "ACCOUNT", hasChevron: false)
    headerModel.backgroundColor = .secondarySystemBackground
    section.headerModel = headerModel
    sections.append(section)

    return sections
  }

}
