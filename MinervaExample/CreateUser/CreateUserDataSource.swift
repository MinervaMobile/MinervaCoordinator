//
//  CreateUserDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Minerva

final class CreateUserDataSource: DataSource {
  enum Action {
    case create(email: String, password: String, dailyCalories: Int32, role: UserRole)
  }

  private static let emailCellModelIdentifier = "emailCellModelIdentifier"
  private static let passwordCellModelIdentifier = "passwordCellModelIdentifier"
  private static let caloriesCellModelIdentifier = "caloriesCellModelIdentifier"

  private let actionsSubject = PublishSubject<Action>()
  public var actions: Observable<Action> { actionsSubject.asObservable() }

  private let sectionsSubject = BehaviorSubject<[ListSection]>(value: [])
  public var sections: Observable<[ListSection]> { sectionsSubject.asObservable() }

  private let disposeBag = DisposeBag()

  private var email: String = ""
  private var password: String = ""
  private var dailyCalories: Int32 = 2_000
  private var role: UserRole = .user

  public init() {
    sectionsSubject.onNext([createSection()])
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
      let action = Action.create(
        email: strongSelf.email,
        password: strongSelf.password,
        dailyCalories: strongSelf.dailyCalories,
        role: strongSelf.role)
      strongSelf.actionsSubject.onNext(action)
    }

    return [
      MarginCellModel(cellIdentifier: "headerMarginModel", height: 12),
      createEmailCellModel(),
      MarginCellModel(cellIdentifier: "emailMarginModel", height: 12),
      createCaloriesCellModel(),
      MarginCellModel(cellIdentifier: "passwordMarginModel", height: 12),
      createPasswordCellModel(),
      MarginCellModel(cellIdentifier: "caloriesMarginModel", height: 12),
      createRoleCellModel(),
      MarginCellModel(cellIdentifier: "roleMarginModel", height: 12),
      doneModel,
      MarginCellModel(cellIdentifier: "doneMarginModel", height: 12)
    ]
  }

  // MARK: - Helpers

  private func createEmailCellModel() -> ListCellModel {
    let cellModel = TextInputCellModel(
      identifier: CreateUserDataSource.emailCellModelIdentifier,
      placeholder: "Email",
      font: .subheadline)
    cellModel.text = email
    cellModel.keyboardType = .emailAddress
    cellModel.textContentType = .emailAddress
    cellModel.cursorColor = .selectable
    cellModel.textColor = .black
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .gray
    cellModel.bottomBorderColor.onNext(.black)
    cellModel.delegate = self
    return cellModel
  }

  private func createCaloriesCellModel() -> ListCellModel {
    let cellModel = TextInputCellModel(
      identifier: CreateUserDataSource.caloriesCellModelIdentifier,
      placeholder: "Daily Calories",
      font: .subheadline)
    cellModel.text = dailyCalories > 0 ? String(dailyCalories) : nil
    cellModel.keyboardType = .numberPad
    cellModel.cursorColor = .selectable
    cellModel.textColor = .black
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .gray
    cellModel.bottomBorderColor.onNext(.black)
    cellModel.delegate = self
    return cellModel
  }

  private func createPasswordCellModel() -> ListCellModel {
    let inputFont = UIFont.headline
    let cellModel = TextInputCellModel(
      identifier: CreateUserDataSource.passwordCellModelIdentifier,
      placeholder: "Password",
      font: inputFont)
    cellModel.keyboardType = .asciiCapable
    cellModel.isSecureTextEntry = true
    cellModel.textContentType = .password
    cellModel.autocorrectionType = .no
    cellModel.cursorColor = .selectable
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .darkGray
    cellModel.bottomBorderColor.onNext(.black)
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
extension CreateUserDataSource: TextInputCellModelDelegate {
  func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?) {
    guard let text = text else { return }
    switch textInputCellModel.identifier {
    case CreateUserDataSource.emailCellModelIdentifier:
      email = text
    case CreateUserDataSource.caloriesCellModelIdentifier:
      dailyCalories = Int32(text) ?? dailyCalories
    case CreateUserDataSource.passwordCellModelIdentifier:
      password = text
    default:
      assertionFailure("Unknown text input cell model")
    }
  }
}
