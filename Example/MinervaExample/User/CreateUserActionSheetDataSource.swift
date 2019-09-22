//
//  CreateUserActionSheetDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva

protocol CreateUserActionSheetDataSourceDelegate: class {
  func createUserActionSheetDataSource(
    _ createUserActionSheetDataSource: CreateUserActionSheetDataSource,
    selected action: CreateUserActionSheetDataSource.Action)
}

final class CreateUserActionSheetDataSource: ActionSheetDataSource {
  enum Action {
    case dismiss
    case create(email: String, password: String, dailyCalories: Int32, role: UserRole)
  }

  private static let emailCellModelIdentifier = "emailCellModelIdentifier"
  private static let passwordCellModelIdentifier = "passwordCellModelIdentifier"
  private static let caloriesCellModelIdentifier = "caloriesCellModelIdentifier"

  weak var delegate: CreateUserActionSheetDataSourceDelegate?

  private var email: String = ""
  private var password: String = ""
  private var dailyCalories: Int32 = 2000
  private var role: UserRole = .user

  // MARK: - Lifecycle

  init() {
  }

  // MARK: - Public

  func loadCellModels() -> [ListCellModel] {
    let leftAction: LabelCellModel.SelectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.createUserActionSheetDataSource(strongSelf, selected: .dismiss)
    }
    let rightAction: LabelCellModel.SelectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      let action = Action.create(
        email: strongSelf.email,
        password: strongSelf.password,
        dailyCalories: strongSelf.dailyCalories,
        role: strongSelf.role)
      strongSelf.delegate?.createUserActionSheetDataSource(strongSelf, selected: action)
    }
    let headerSectionModel = ActionSheetVC.createHeaderModel(
      identifier: "ActionSheetHeader",
      leftText: "Cancel",
      centerText: "Create User",
      rightText: "Save",
      leftAction: leftAction,
      rightAction: rightAction)

    return [
      headerSectionModel,
      MarginCellModel(cellIdentifier: "headerMarginModel", height: 12),
      createEmailCellModel(),
      MarginCellModel(cellIdentifier: "emailMarginModel", height: 12),
      createCaloriesCellModel(),
      MarginCellModel(cellIdentifier: "passwordMarginModel", height: 12),
      createPasswordCellModel(),
      MarginCellModel(cellIdentifier: "caloriesMarginModel", height: 12),
      createRoleCellModel(),
      MarginCellModel(cellIdentifier: "roleMarginModel", height: 12)
    ]
  }

  // MARK: - Helpers

  private func createEmailCellModel() -> ListCellModel {
    let cellModel = TextInputCellModel(
      identifier: CreateUserActionSheetDataSource.emailCellModelIdentifier,
      placeholder: "Email",
      font: .subheadline)
    cellModel.text = email
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
      identifier: CreateUserActionSheetDataSource.caloriesCellModelIdentifier,
      placeholder: "Daily Calories",
      font: .subheadline)
    cellModel.text = dailyCalories > 0 ? String(dailyCalories) : nil
    cellModel.keyboardType = .numberPad
    cellModel.cursorColor = .selectable
    cellModel.textColor = .black
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .gray
    cellModel.bottomBorderColor = .black
    cellModel.delegate = self
    return cellModel
  }

  private func createPasswordCellModel() -> ListCellModel {
    let inputFont = UIFont.headline
    let cellModel = TextInputCellModel(
      identifier: CreateUserActionSheetDataSource.passwordCellModelIdentifier,
      placeholder: "Password",
      font: inputFont)
    cellModel.keyboardType = .asciiCapable
    cellModel.isSecureTextEntry = true
    cellModel.textContentType = .password
    cellModel.autocorrectionType = .no
    cellModel.cursorColor = .selectable
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .darkGray
    cellModel.bottomBorderColor = .black
    cellModel.delegate = self
    return cellModel
  }

  private func createRoleCellModel() -> ListCellModel {
    let roleData = UserRole.allCases.map { role -> PickerDataRow in
      let text = NSAttributedString(string: role.description)
      return PickerDataRow(text: text, imageData: nil)
    }

    let startingRow = role.rawValue - 1

    let componentData = PickerDataComponent(
      data: roleData,
      textAlignment: .center,
      verticalMargin: 8,
      startingRow: startingRow
    )

    let pickerModel = PickerCellModel(
      identifier: "rolePickerCellModel", pickerDataComponents: [componentData]
    ) { [weak self] _, _, row, _ -> Void in
      guard let role = UserRole(rawValue: row + 1) else {
        assertionFailure("Role should exist at row \(row)")
        return
      }
      self?.role = role
    }
    pickerModel.height = 128
    return pickerModel
  }
}

// MARK: - TextInputCellModelDelegate
extension CreateUserActionSheetDataSource: TextInputCellModelDelegate {
  func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?) {
    guard let text = text else { return }
    switch textInputCellModel.identifier {
    case CreateUserActionSheetDataSource.emailCellModelIdentifier:
      email = text
    case CreateUserActionSheetDataSource.caloriesCellModelIdentifier:
      dailyCalories = Int32(text) ?? dailyCalories
    case CreateUserActionSheetDataSource.passwordCellModelIdentifier:
      password = text
    default:
      assertionFailure("Unknown text input cell model")
    }
  }
}
