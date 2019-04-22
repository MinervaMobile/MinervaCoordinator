//
//  WelcomeDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

protocol WelcomeDataSourceDelegate: class {
  func welcomeDataSource(_ welcomeDataSource: WelcomeDataSource, selected action: WelcomeDataSource.Action)
}

final class WelcomeDataSource: CollectionViewControllerDataSource {
  enum Action {
    case createAccount
    case login
  }

  weak var delegate: WelcomeDataSourceDelegate?

  // MARK: - Lifecycle

  init() {
  }

  // MARK: - Public

  func loadSections() -> Promise<[ListSection]> {
    return .value([createSection()])
  }

  // MARK: - Private

  private func createSection() -> ListSection {
    let topDynamicMarginModel = MarginCellModel(cellIdentifier: "topDynamicMarginModel", height: nil)

    let logoModel = ImageCellModel(image: Asset.Logo.image, width: 120.0, height: 120.0)
    logoModel.imageColor = .black
    logoModel.contentMode = .scaleAspectFit

    let personalizedGuidanceModel = LabelCellModel(text: "WORKOUTS", font: .boldTitleLarge)
    personalizedGuidanceModel.textColor = .black
    personalizedGuidanceModel.textAlignment = .center
    personalizedGuidanceModel.bottomMargin = 20
    personalizedGuidanceModel.topMargin = 30

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
    paragraphCellModel.bottomMargin = 60

    let newAccountModel = BorderLabelCellModel(text: "SETUP NEW ACCOUNT", font: .subheadline, textColor: .white)
    newAccountModel.maxCellWidth = 340
    newAccountModel.textAlignment = .center
    newAccountModel.buttonColor = .selectable
    newAccountModel.selectionAction = { [weak self] _, _ in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.welcomeDataSource(strongSelf, selected: .createAccount)
    }

    let existingAccountModel = LabelCellModel(text: "USE EXISTING ACCOUNT", font: .subheadline)
    existingAccountModel.textAlignment = .center
    existingAccountModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.welcomeDataSource(strongSelf, selected: .login)
    }
    existingAccountModel.textColor = .selectable
    existingAccountModel.topMargin = 30

    let bottomDynamicMarginModel = MarginCellModel(cellIdentifier: "bottomDynamicMarginModel", height: nil)
    let bottomMarginModel = BottomMarginCellModel()

    let cellModels = [
      topDynamicMarginModel,
      logoModel,
      personalizedGuidanceModel,
      paragraphCellModel,
      newAccountModel,
      existingAccountModel,
      bottomDynamicMarginModel,
      bottomMarginModel
    ]

    let section = ListSection(cellModels: cellModels, identifier: "SECTION")

    return section
  }

}
