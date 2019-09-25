//
//  UpdateUserActionSheetDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

protocol UpdateUserActionSheetDataSourceDelegate: AnyObject {
  func updateUserActionSheetDataSource(
    _ updateUserActionSheetDataSource: UpdateUserActionSheetDataSource,
    selected action: UpdateUserActionSheetDataSource.Action)
}

final class UpdateUserActionSheetDataSource: ActionSheetDataSource {
  enum Action {
    case dismiss
    case save(user: User)
  }

  private static let emailCellModelIdentifier = "EmailCellModel"
  private static let caloriesCellModelIdentifier = "CaloriesCellModel"

  weak var delegate: UpdateUserActionSheetDataSourceDelegate?

  private var user: UserProto

  // MARK: - Lifecycle

  init(user: User) {
    self.user = user.proto
  }

  // MARK: - Public

  func loadCellModels() -> [ListCellModel] {
    let leftAction: LabelCellModel.SelectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.updateUserActionSheetDataSource(strongSelf, selected: .dismiss)
    }
    let rightAction: LabelCellModel.SelectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.updateUserActionSheetDataSource(strongSelf, selected: .save(user: strongSelf.user))
    }
    let headerSectionModel = ActionSheetVC.createHeaderModel(
      identifier: "ActionSheetHeader",
      leftText: "Cancel",
      centerText: "Edit User",
      rightText: "Save",
      leftAction: leftAction,
      rightAction: rightAction)

    return [
      headerSectionModel,
      MarginCellModel(cellIdentifier: "headerMarginModel", height: 12),
      createEmailCellModel(),
      MarginCellModel(cellIdentifier: "emailMarginModel", height: 12),
      createCaloriesCellModel(),
      MarginCellModel(cellIdentifier: "caloriesMarginModel", height: 12)
    ]
  }

  // MARK: - Helpers

  private func createEmailCellModel() -> ListCellModel {
    let cellModel = TextInputCellModel(
      identifier: UpdateUserActionSheetDataSource.emailCellModelIdentifier,
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
      identifier: UpdateUserActionSheetDataSource.caloriesCellModelIdentifier,
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
extension UpdateUserActionSheetDataSource: TextInputCellModelDelegate {
  func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?) {
    guard let text = text else { return }
    switch textInputCellModel.identifier {
    case UpdateUserActionSheetDataSource.emailCellModelIdentifier:
      user.email = text
    case UpdateUserActionSheetDataSource.caloriesCellModelIdentifier:
      user.dailyCalories = Int32(text) ?? user.dailyCalories
    default:
      assertionFailure("Unknown text input cell model")
    }
  }
}
