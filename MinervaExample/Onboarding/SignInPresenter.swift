//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Minerva
import RxRelay
import RxSwift
import UIKit

public final class SignInPresenter: ListPresenter {
  private static let emailCellModelIdentifier = "emailInputCellModel"
  private static let passwordCellModelIdentifier = "passwordInputCellModel"

  public enum Action {
    case signIn(email: String, password: String, mode: Mode)
    case invalidInput
  }

  public enum Mode {
    case createAccount
    case login

    public var buttonText: String {
      switch self {
      case .createAccount: return "CREATE ACCOUNT"
      case .login: return "SIGN IN"
      }
    }
  }

  private let actionsRelay = PublishRelay<Action>()
  public var actions: Observable<Action> { actionsRelay.asObservable() }

  public var sections = BehaviorRelay<[ListSection]>(value: [])

  private let disposeBag = DisposeBag()

  private var email: String?
  private var password: String?

  private let mode: Mode

  // MARK: - Lifecycle

  public init(mode: Mode) {
    self.mode = mode
    sections.accept([createSection()])
  }

  // MARK: - Private

  private func createSection() -> ListSection {
    let topDynamicMarginModel = MarginCellModel()

    let logoModel = ImageCellModel(
      identifier: "logoCellModel",
      imageObservable: .just(Asset.Logo.image),
      imageSize: CGSize(width: 100.0, height: 80.0)
    )
    logoModel.directionalLayoutMargins.bottom = 60

    let emailModel = createEmailCellModel()
    let emailMarginModel = MarginCellModel(identifier: "emailMarginModel", height: 24)
    let passwordModel = createPasswordCellModel()
    let passwordMarginModel = MarginCellModel(identifier: "passwordMarginModel", height: 24)

    let signInButtonModel = ButtonCellModel(
      identifier: "signInButtonModel",
      text: mode.buttonText,
      font: .subheadline,
      textColor: .white
    )
    signInButtonModel.textAlignment = .center
    signInButtonModel.buttonColor = .selectable
    signInButtonModel.directionalLayoutMargins.bottom = 40
    signInButtonModel.buttonAction = { [weak self] _, _ -> Void in
      self?.handleContinueButtonPress()
    }

    let bottomDynamicMarginModel = MarginCellModel()

    let cellModels = [
      topDynamicMarginModel,
      logoModel,
      emailModel,
      emailMarginModel,
      passwordModel,
      passwordMarginModel,
      signInButtonModel,
      bottomDynamicMarginModel
    ]

    return ListSection(cellModels: cellModels, identifier: "SignInPresenterSection")
  }

  private func handleContinueButtonPress() {
    if let email = self.email, let password = self.password {
      actionsRelay.accept(.signIn(email: email, password: password, mode: self.mode))
    } else {
      actionsRelay.accept(.invalidInput)
    }
  }

  private func createEmailCellModel() -> ListCellModel {
    let inputFont = UIFont.headline
    let cellModel = TextInputCellModel(
      identifier: SignInPresenter.emailCellModelIdentifier,
      placeholder: "Email Address",
      font: inputFont
    )

    cellModel.keyboardType = .emailAddress
    cellModel.textContentType = .emailAddress
    cellModel.cursorColor = .selectable
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .darkGray
    cellModel.bottomBorderColor.onNext(.black)

    cellModel.textInputAction = { [weak self] _, text in
      self?.email = text
    }
    return cellModel
  }

  private func createPasswordCellModel() -> ListCellModel {
    let inputFont = UIFont.headline
    let cellModel = TextInputCellModel(
      identifier: SignInPresenter.passwordCellModelIdentifier,
      placeholder: "Password",
      font: inputFont
    )

    cellModel.keyboardType = .asciiCapable
    cellModel.isSecureTextEntry = true
    cellModel.textContentType = .password
    cellModel.autocorrectionType = .no
    cellModel.cursorColor = .selectable
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .darkGray
    cellModel.bottomBorderColor.onNext(.black)

    cellModel.textInputAction = { [weak self] _, text in
      self?.password = text
    }
    return cellModel
  }
}
