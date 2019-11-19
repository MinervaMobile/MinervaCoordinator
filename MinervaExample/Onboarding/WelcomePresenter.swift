//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class WelcomePresenter: Presenter {
  public enum Action {
    case createAccount
    case login
  }

  private let actionsSubject = PublishSubject<Action>()
  public var actions: Observable<Action> { actionsSubject.asObservable() }

  private let sectionsSubject = BehaviorSubject<[ListSection]>(value: [])
  public var sections: Observable<[ListSection]> { sectionsSubject.asObservable() }

  private let disposeBag = DisposeBag()

  public init() {
    sectionsSubject.onNext([createSection()])
  }

  // MARK: - Private

  private func createSection() -> ListSection {
    let topDynamicMarginModel = MarginCellModel(location: .top)

    let logoModel = ImageCellModel(image: Asset.Logo.image, imageSize: CGSize(width: 120.0, height: 120.0))
    logoModel.imageColor = .black
    logoModel.contentMode = .scaleAspectFit

    let personalizedGuidanceModel = LabelCellModel(text: "WORKOUTS", font: UIFont.title1.bold)
    personalizedGuidanceModel.textColor = .black
    personalizedGuidanceModel.textAlignment = .center
    personalizedGuidanceModel.directionalLayoutMargins.bottom = 20
    personalizedGuidanceModel.directionalLayoutMargins.top = 30

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 20
    let attributedString = NSAttributedString(
      string: "Quickly log your calorie intake for each workout and track your calories over time. Easily see when you hit and miss your daily calorie goal.",
      font: .subheadline,
      fontColor: .black
    )

    let mutableString = NSMutableAttributedString(attributedString: attributedString)
    mutableString.addAttribute(
      NSAttributedString.Key.paragraphStyle,
      value: paragraphStyle,
      range: NSRange(location: 0, length: mutableString.length)
    )
    let paragraphCellModel = LabelCellModel(attributedText: mutableString)
    paragraphCellModel.textAlignment = .center
    paragraphCellModel.directionalLayoutMargins.bottom = 60

    let newAccountModel = ButtonCellModel(text: "SETUP NEW ACCOUNT", font: .subheadline, textColor: .white)
    newAccountModel.textAlignment = .center
    newAccountModel.buttonColor = .selectable
    newAccountModel.selectionAction = { [weak self] _, _ in
      guard let strongSelf = self else { return }
      strongSelf.actionsSubject.onNext(.createAccount)
    }

    let existingAccountModel = LabelCellModel(text: "USE EXISTING ACCOUNT", font: .subheadline)
    existingAccountModel.textAlignment = .center
    existingAccountModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.actionsSubject.onNext(.login)
    }
    existingAccountModel.textColor = .selectable
    existingAccountModel.directionalLayoutMargins.top = 30

    let bottomDynamicMarginModel = MarginCellModel(location: .bottom)

    let cellModels: [ListCellModel] = [
      topDynamicMarginModel,
      logoModel,
      personalizedGuidanceModel,
      paragraphCellModel,
      newAccountModel,
      existingAccountModel,
      bottomDynamicMarginModel
    ]

    let section = ListSection(cellModels: cellModels, identifier: "SECTION")

    return section
  }

}
