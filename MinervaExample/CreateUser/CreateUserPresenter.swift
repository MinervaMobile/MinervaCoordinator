//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxRelay
import RxSwift
import UIKit

public final class CreateUserPresenter: Presenter {
  public enum Action {
    case create(email: String, password: String, dailyCalories: Int32, role: UserRole)
  }

  private static let emailCellModelIdentifier = "emailCellModelIdentifier"
  private static let passwordCellModelIdentifier = "passwordCellModelIdentifier"
  private static let caloriesCellModelIdentifier = "caloriesCellModelIdentifier"

  private let actionsRelay = PublishRelay<Action>()
  public var actions: Observable<Action> { actionsRelay.asObservable() }

  public var sections = BehaviorRelay<[ListSection]>(value: [])

  private let disposeBag = DisposeBag()

  private var email: String = ""
  private var password: String = ""
  private var dailyCalories: Int32 = 2_000
  private var role: UserRole = .user

  public init() {
    sections.accept([createSection()])
  }

  // MARK: - Private

  private func createSection() -> ListSection {
    let cellModels = loadCellModels()
    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return section
  }

  private func loadCellModels() -> [ListCellModel] {
    let doneModel = SelectableLabelCellModel(identifier: "doneModel", text: "Save", font: .title1)
    doneModel.directionalLayoutMargins.leading = 0
    doneModel.directionalLayoutMargins.trailing = 0
    doneModel.textAlignment = .center
    doneModel.textColor = .selectable
    doneModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      let action = Action.create(
        email: strongSelf.email,
        password: strongSelf.password,
        dailyCalories: strongSelf.dailyCalories,
        role: strongSelf.role)
      strongSelf.actionsRelay.accept(action)
    }

    return [
      MarginCellModel(identifier: "headerMarginModel", height: 12),
      createEmailCellModel(),
      MarginCellModel(identifier: "emailMarginModel", height: 12),
      createCaloriesCellModel(),
      MarginCellModel(identifier: "passwordMarginModel", height: 12),
      createPasswordCellModel(),
      MarginCellModel(identifier: "caloriesMarginModel", height: 12),
      createRoleCellModel(),
      MarginCellModel(identifier: "roleMarginModel", height: 12),
      doneModel,
      MarginCellModel(identifier: "doneMarginModel", height: 12)
    ]
  }

  private func createEmailCellModel() -> ListCellModel {
    let cellModel = TextInputCellModel(
      identifier: CreateUserPresenter.emailCellModelIdentifier,
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
      identifier: CreateUserPresenter.caloriesCellModelIdentifier,
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
      identifier: CreateUserPresenter.passwordCellModelIdentifier,
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
      identifier: "rolePickerCellModel",
      pickerDataComponents: [componentData]
    ) { [weak self] _, _, row, _ -> Void in
      guard let role = UserRole(rawValue: row + 1) else {
        assertionFailure("Role should exist at row \(row)")
        return
      }
      self?.role = role
    }
    return pickerModel
  }
}

// MARK: - TextInputCellModelDelegate
extension CreateUserPresenter: TextInputCellModelDelegate {
  public func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?) {
    guard let text = text else { return }
    switch textInputCellModel.identifier {
    case CreateUserPresenter.emailCellModelIdentifier:
      email = text
    case CreateUserPresenter.caloriesCellModelIdentifier:
      dailyCalories = Int32(text) ?? dailyCalories
    case CreateUserPresenter.passwordCellModelIdentifier:
      password = text
    default:
      assertionFailure("Unknown text input cell model")
    }
  }
}
