//
//  UserListDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

protocol UserListDataSourceDelegate: AnyObject {
  func userListDataSource(_ userListDataSource: UserListDataSource, selected action: UserListDataSource.Action)
}

final class UserListDataSource: BaseDataSource {
  enum Action {
    case delete(user: User)
    case edit(user: User)
    case view(user: User)
  }

  weak var delegate: UserListDataSourceDelegate?

  private let dataManager: DataManager

  // MARK: - Lifecycle

  init(dataManager: DataManager) {
    self.dataManager = dataManager
  }

  // MARK: - Public

  func reload(animated: Bool) {
    let sectionsPromise = dataManager.loadUsers().map { [weak self] users -> [ListSection] in
      guard let strongSelf = self else { throw SystemError.cancelled }
      return [strongSelf.createSection(with: users.sorted { $0.email < $1.email })]
    }
    updateDelegate?.dataSource(self, process: sectionsPromise, animated: animated, completion: nil)
  }

  // MARK: - Private

  private func createSection(with users: [User]) -> ListSection {
    var cellModels = [ListCellModel]()

    let allowSelection = dataManager.userAuthorization.role == .admin
    for user in users {
      let userCellModel = createUserCellModel(for: user)
      if allowSelection {
        userCellModel.selectionAction = { [weak self] _, _ -> Void in
          guard let strongSelf = self else { return }
          strongSelf.delegate?.userListDataSource(strongSelf, selected: .view(user: user))
        }
      }
      cellModels.append(userCellModel)
    }

    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return section
  }

  private func createUserCellModel(for user: User) -> SwipeableLabelCellModel {
    let cellModel = SwipeableLabelCellModel(
      identifier: user.description,
      title: user.email,
      details: String(user.dailyCalories))
    cellModel.bottomSeparatorColor = .separator
    cellModel.bottomSeparatorLeftInset = true
    cellModel.deleteAction = { [weak self] _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.userListDataSource(strongSelf, selected: .delete(user: user))
    }
    cellModel.editAction = { [weak self] _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.userListDataSource(strongSelf, selected: .edit(user: user))
    }
    return cellModel
  }

}
