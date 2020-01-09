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

public final class UpdateUserPresenter: Presenter {
  public enum Action {
    case save(user: User)
  }

  private static let emailCellModelIdentifier = "EmailCellModel"
  private static let caloriesCellModelIdentifier = "CaloriesCellModel"

  private let actionsRelay = PublishRelay<Action>()
  public var actions: Observable<Action> { actionsRelay.asObservable() }

  public var sections = BehaviorRelay<[ListSection]>(value: [])

  private let disposeBag = DisposeBag()

  private var user: UserProto {
    didSet {
      userSubject.onNext(user)
    }
  }
  private let userSubject: BehaviorSubject<UserProto>

  // MARK: - Lifecycle

  public init(user: User) {
    self.user = user.proto
    self.userSubject = BehaviorSubject(value: self.user)
    userSubject.map({ [weak self] _ -> [ListSection] in self?.createSections() ?? [] })
      .bind(to: sections)
      .disposed(by: disposeBag)
  }

  // MARK: - Private

  private func createSections() -> [ListSection] {
    let cellModels = loadCellModels()
    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return [section]
  }

  private func loadCellModels() -> [ListCellModel] {
    let doneModel = SelectableLabelCellModel(identifier: "doneModel", text: "Save", font: .title1)
    doneModel.directionalLayoutMargins.leading = 0
    doneModel.directionalLayoutMargins.trailing = 0
    doneModel.textAlignment = .center
    doneModel.textColor = .selectable
    doneModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.actionsRelay.accept(.save(user: strongSelf.user))
    }

    return [
      MarginCellModel(identifier: "headerMarginModel", height: 12),
      createEmailCellModel(),
      MarginCellModel(identifier: "emailMarginModel", height: 12),
      createCaloriesCellModel(),
      MarginCellModel(identifier: "caloriesMarginModel", height: 12),
      doneModel,
      MarginCellModel(identifier: "doneMarginModel", height: 12)
    ]
  }

  private func createEmailCellModel() -> ListCellModel {
    let cellModel = TextInputCellModel(
      identifier: UpdateUserPresenter.emailCellModelIdentifier,
      placeholder: "Email",
      font: .subheadline)
    cellModel.text = user.email
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
      identifier: UpdateUserPresenter.caloriesCellModelIdentifier,
      placeholder: "Daily Calories",
      font: .subheadline)
    cellModel.text = user.dailyCalories > 0 ? String(user.dailyCalories) : nil
    cellModel.keyboardType = .numberPad
    cellModel.cursorColor = .selectable
    cellModel.textColor = .black
    cellModel.inputTextColor = .black
    cellModel.placeholderTextColor = .gray
    cellModel.bottomBorderColor.onNext(.black)
    cellModel.delegate = self
    return cellModel
  }
}

// MARK: - TextInputCellModelDelegate
extension UpdateUserPresenter: TextInputCellModelDelegate {
  public func textInputCellModel(_ textInputCellModel: TextInputCellModel, textChangedTo text: String?) {
    guard let text = text else { return }
    switch textInputCellModel.identifier {
    case UpdateUserPresenter.emailCellModelIdentifier:
      user.email = text
    case UpdateUserPresenter.caloriesCellModelIdentifier:
      user.dailyCalories = Int32(text) ?? user.dailyCalories
    default:
      assertionFailure("Unknown text input cell model")
    }
  }
}
