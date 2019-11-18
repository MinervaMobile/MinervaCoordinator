//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Minerva
import RxSwift
import XCTest

public final class IntegrationTests: XCTestCase {

  private var coordinator: BaseCoordinator<FakePresenter, CollectionViewController>!

  override public func setUp() {
    super.setUp()
    let layout = ListViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
    let collectionVC = CollectionViewController(layout: layout)
    collectionVC.backgroundImage = UIImage()
    let listController = LegacyListController()
    listController.viewController = collectionVC
    listController.collectionView = collectionVC.collectionView
    let navigator = BasicNavigator()
    let presenter = FakePresenter()
    coordinator = BaseCoordinator(
      navigator: navigator,
      viewController: collectionVC,
      presenter: presenter,
      listController: listController)
    collectionVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 10_000)
  }

  override public func tearDown() {
    coordinator = nil
    super.tearDown()
  }

  public func testUpdate() {
    let updateExpectation = expectation(description: "Update Expectation")
    let disposable = coordinator.presenter.sections
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { sections in
          XCTAssertEqual(sections.count, 2)
          // Force the listcontroller to update so we dont need to wait for the animations to finish
          self.coordinator.listController.update(with: sections, animated: false) { finished in
            XCTAssert(finished)
            updateExpectation.fulfill()
          }
        }
      )
    wait(for: [updateExpectation], timeout: 1)
    disposable.dispose()

    assertCellTypesMatch(coordinator.presenter.listSections)
  }

  public func testReloadAfterReorder() {
    var sections = coordinator.presenter.listSections
    let updateExpectation1 = expectation(description: "1st Update Expectation")
    self.coordinator.listController.update(with: sections, animated: false) { finished in
      XCTAssert(finished)
      updateExpectation1.fulfill()
    }
    wait(for: [updateExpectation1], timeout: 1)

    sections = sections.map { section -> ListSection in
      var section = section
      section.cellModels.reverse()
      return section
    }

    let updateExpectation2 = expectation(description: "2nd Update Expectation")
    self.coordinator.listController.update(with: sections, animated: false) { finished in
      XCTAssert(finished)
      updateExpectation2.fulfill()
    }
    wait(for: [updateExpectation2], timeout: 1)

    assertCellTypesMatch(sections)
  }

  // MARK: - Private
  private func assertCellTypesMatch(_ sections: [ListSection]) {
    for (sectionIndex, section) in sections.enumerated() {
      for (index, model) in section.cellModels.enumerated() {
        let cell = coordinator.viewController.collectionView.cellForItem(
          at: IndexPath(row: index, section: sectionIndex)
        )!
        let modelCellType = model.cellType
        let actualCellType = type(of: cell)
        XCTAssert(modelCellType === actualCellType)
      }
    }
  }
}

// MARK: - FakePresenter
fileprivate final class FakePresenter: Presenter {
  fileprivate let cellModels: [ListCellModel] = {
    let font = UIFont.preferredFont(forTextStyle: .body)
    let color = UIColor.label
    let size = CGSize(width: 24, height: 24)
    let text = "text"
    let attrText = NSAttributedString(string: text)
    let image = UIImage()
    let cellModels = [
      // Cells
      ButtonCellModel(text: "ButtonCellModel", font: font, textColor: color),
      ButtonImageCellModel(imageSize: size, text: "ButtonImageCellModel", font: font),
      DatePickerCellModel(identifier: "DatePickerCellModel", startDate: Date()),
      DetailedLabelCellModel(
        identifier: "DetailedLabelCellModel",
        attributedTitle: attrText,
        attributedDetails: attrText
      ),
      IconTextCellModel(imageSize: size, text: "IconTextCellModel", font: font),
      ImageButtonCardCellModel(
        identifier: "ImageButtonCardCellModel",
        attributedText: attrText,
        selectedAttributedText: attrText,
        image: image,
        imageSize: size,
        isSelected: true
      ),
      ImageCellModel(image: image, imageSize: size),
      ImageLabelBorderCellModel(text: "ImageLabelBorderCellModel", font: font, image: image, imageSize: size),
      ImageTextCardCellModel(attributedText: NSAttributedString(string: "ImageTextCardCellModel")),
      ImageTextCellModel(identifier: "ImageTextCellModel", attributedText: attrText),
      LabelAccessoryCellModel(identifier: "LabelAccessoryCellModel", attributedText: attrText),
      LabelCellModel(identifier: "LabelCellModel", attributedText: attrText),
      MarginCellModel(identifier: "MarginCellModel", height: size.height),
      PickerCellModel(identifier: "PickerCellModel", pickerDataComponents: [], changedValue: { _, _, _, _ in }),
      PickerLabelCellModel(
        identifier: "PickerLabelCellModel",
        pickerData: PickerData(data: [], options: nil),
        changedValue: { _, _, _, _ in }
      ),
      SegmentedControlCellModel(selectedSegment: 0, segmentTitles: [text]),
      SeparatorCellModel(location: .bottom(cellModelID: "SeparatorCellModel"), color: color),
      SwitchTextCellModel(text: "SwitchTextCellModel", font: font, textColor: color, switchColor: color, isOn: true),
      TextInputCellModel(identifier: "TextInputCellModel", placeholder: text, font: font),
      TextSeparatorCellModel(text: "TextSeparatorCellModel"),
      TextViewCellModel(identifier: "TextViewCellModel", text: nil, font: font, changedValue: { _, _ in }),
      // Swipe Cells
      SwipeableDetailedLabelCellModel(
        identifier: "SwipeableDetailedLabelCellModel",
        attributedText: attrText,
        detailsText: attrText
      ),
      SwipeableLabelCellModel(identifier: "SwipeableLabelCellModel", attributedText: attrText)
    ]
    return cellModels
  }()

  fileprivate let listSections: [ListSection]

  fileprivate init() {
    let mainSection = ListSection(cellModels: cellModels, identifier: "Section")

    let horizontalCellModel = HorizontalCollectionCellModel(
      identifier: "HorizontalCollectionCellModel",
      cellModels: [ImageCellModel(image: UIImage(), imageSize: CGSize(width: 24, height: 24))],
      distribution: .entireRow,
      listController: LegacyListController()
    )!
    var horizontalSection = ListSection(cellModels: [horizontalCellModel], identifier: "HorizontalSection")
    horizontalSection.constraints.scrollDirection = .horizontal
    listSections = [mainSection, horizontalSection]
  }

  fileprivate var sections: Observable<[ListSection]> {
    return .just(listSections)
  }
}
