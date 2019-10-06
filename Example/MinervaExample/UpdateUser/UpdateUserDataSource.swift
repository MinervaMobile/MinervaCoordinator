//
//  UpdateUserDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

protocol UpdateUserDataSourceDelegate: AnyObject {
  func updateUserActionSheetDataSource(
    _ updateUserActionSheetDataSource: UpdateUserDataSource,
    selected action: UpdateUserDataSource.Action)
}

final class UpdateUserDataSource: BaseDataSource {
  enum Action {
    case save(user: User)
  }

  private static let emailCellModelIdentifier = "EmailCellModel"
  private static let caloriesCellModelIdentifier = "CaloriesCellModel"

  weak var delegate: UpdateUserDataSourceDelegate?

  private var user: UserProto

  // MARK: - Lifecycle

  init(user: User) {
    self.user = user.proto
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

  func loadCellModels() -> [ListCellModel] {
    let doneModel = LabelCell.Model(identifier: "doneModel", text: "Save", font: .titleLarge)
    doneModel.leftMargin = 0
    doneModel.rightMargin = 0
    doneModel.textAlignment = .center
    doneModel.textColor = .selectable
    doneModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.updateUserActionSheetDataSource(strongSelf, selected: .save(user: strongSelf.user))
    }

    return [
      MarginCellModel(cellIdentifier: "headerMarginModel", height: 12),
      createEmailCellModel(),
      MarginCellModel(cellIdentifier: "emailMarginModel", height: 12),
      createCaloriesCellModel(),
      MarginCellModel(cellIdentifier: "caloriesMarginModel", height: 12),
      doneModel,
      MarginCellModel(cellIdentifier: "doneMarginModel", height: 12)
    ]
  }

  // MARK: - Helpers

  private func createEmailCellModel() -> ListCellModel {
    let cellModel = TextInputCellModel(
      identifier: UpdateUserDataSource.emailCellModelIdentifier,
      placeholder: "Email",
      font: .subheadline)
    cellModel.text = user.email
    cellModel.keyboardType = .emailAddress
    cellModel.textContentType = .emailAddress
    cellModel.cursorColor = .selectable
    cellModel.textColor = .black
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .gray
    cellModel.bottomBorderColor = .black
    cellModel.delegate = self
    return cellModel
  }

  private func createCaloriesCellModel() -> ListCellModel {
    let cellModel = TextInputCellModel(
      identifier: UpdateUserDataSource.caloriesCellModelIdentifier,
      placeholder: "Daily Calories",
      font: .subheadline)
    cellModel.text = user.dailyCalories > 0 ? String(user.dailyCalories) : nil
    cellModel.keyboardType = .numberPad
    cellModel.cursorColor = .selectable
    cellModel.textColor = .black
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .gray
    cellModel.bottomBorderColor = .black
    cellModel.delegate = self
    return cellModel
  }
}

// MARK: - TextInputCellModelDelegate
extension UpdateUserDataSource: TextInputCellModelDelegate {
  func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?) {
    guard let text = text else { return }
    switch textInputCellModel.identifier {
    case UpdateUserDataSource.emailCellModelIdentifier:
      user.email = text
    case UpdateUserDataSource.caloriesCellModelIdentifier:
      user.dailyCalories = Int32(text) ?? user.dailyCalories
    default:
      assertionFailure("Unknown text input cell model")
    }
  }
}
