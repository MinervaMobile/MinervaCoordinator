//
//  SignInDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import UIKit
import Minerva
import RxSwift

final class SignInDataSource: DataSource {
  private static let emailCellModelIdentifier = "emailInputCellModel"
  private static let passwordCellModelIdentifier = "passwordInputCellModel"

  enum Action {
    case signIn(email: String, password: String, mode: Mode)
    case invalidInput
  }

  enum Mode {
    case createAccount
    case login

    var buttonText: String {
      switch self {
      case .createAccount: return "CREATE ACCOUNT"
      case .login: return "SIGN IN"
      }
    }
  }

  private let actionsSubject = PublishSubject<Action>()
  public var actions: Observable<Action> { actionsSubject.asObservable() }

  private let sectionsSubject = BehaviorSubject<[ListSection]>(value: [])
  public var sections: Observable<[ListSection]> { sectionsSubject.asObservable() }

  private let disposeBag = DisposeBag()

  private var email: String?
  private var password: String?

  private let mode: Mode

  // MARK: - Lifecycle

  init(mode: Mode) {
    self.mode = mode
    sectionsSubject.onNext([createSection()])
  }

  // MARK: - Private

  private func createSection() -> ListSection {
    let topDynamicMarginModel = MarginCellModel(
      cellIdentifier: "topDynamicMarginModel",
      height: nil
    )

    let logoModel = ImageCellModel(
      identifier: "logoCellModel",
      image: Asset.Logo.image,
      width: 100.0,
      height: 80.0)
    logoModel.bottomMargin = 60

    let emailModel = createEmailCellModel()
    let emailMarginModel = MarginCellModel(cellIdentifier: "emailMarginModel", height: 24)
    let passwordModel = createPasswordCellModel()
    let passwordMarginModel = MarginCellModel(cellIdentifier: "passwordMarginModel", height: 24)

    let signInButtonModel = BorderLabelCellModel(
      identifier: "signInButtonModel",
      text: mode.buttonText,
      font: .subheadline,
      textColor: .white)
    signInButtonModel.textAlignment = .center
    signInButtonModel.buttonColor = .selectable
    signInButtonModel.bottomMargin = 40
    signInButtonModel.selectionAction = { [weak self] _, _ -> Void in
      self?.handleContinueButtonPress()
    }

    let bottomDynamicMarginModel = MarginCellModel(cellIdentifier: "bottomDynamicMarginModel", height: nil)

    let bottomMarginModel = BottomMarginCellModel()

    let cellModels = [
      topDynamicMarginModel,
      logoModel,
      emailModel,
      emailMarginModel,
      passwordModel,
      passwordMarginModel,
      signInButtonModel,
      bottomDynamicMarginModel,
      bottomMarginModel
    ]

    return ListSection(cellModels: cellModels, identifier: "SignInDataSourceSection")
  }

  private func handleContinueButtonPress() {
    if let email = self.email, let password = self.password {
      actionsSubject.onNext(.signIn(email: email, password: password, mode: self.mode))
    } else {
      actionsSubject.onNext(.invalidInput)
    }
  }

  private func createEmailCellModel() -> ListCellModel {
    let inputFont = UIFont.headline
    let cellModel = TextInputCellModel(
      identifier: SignInDataSource.emailCellModelIdentifier,
      placeholder: "Email Address",
      font: inputFont)

    cellModel.keyboardType = .emailAddress
    cellModel.textContentType = .emailAddress
    cellModel.cursorColor = .selectable
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .darkGray
    cellModel.bottomBorderColor.onNext(.black)

    cellModel.delegate = self
    return cellModel
  }

  private func createPasswordCellModel() -> ListCellModel {
    let inputFont = UIFont.headline
    let cellModel = TextInputCellModel(
      identifier: SignInDataSource.passwordCellModelIdentifier,
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
}

// MARK: - TextInputCellModelDelegate
extension SignInDataSource: TextInputCellModelDelegate {
  func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?) {
    switch textInputCellModel.identifier {
    case SignInDataSource.emailCellModelIdentifier:
      email = text
    case SignInDataSource.passwordCellModelIdentifier:
      password = text
    default:
      assertionFailure("Invalid text input cell \(textInputCellModel.identifier)")
    }
  }
}
