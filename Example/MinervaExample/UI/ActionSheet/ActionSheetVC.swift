//
//  ActionSheetVC.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import UIKit

import Minerva

protocol ActionSheetDataSource {
  func loadCellModels() -> [ListCellModel]
}

class ActionSheetVC: UIViewController {

  let backgroundButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = .black
    return button
  }()

  private var collectionBottomConstraint: NSLayoutConstraint?
  private(set) var containerHeightConstraint: NSLayoutConstraint!

  private let listController = ListController()

  private let collectionView: UICollectionView = {
    let layout = ListViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: true)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.contentInsetAdjustmentBehavior = .never
    return collectionView
  }()

  private let dataSource: ActionSheetDataSource

  // MARK: - Lifecycle

  required init(dataSource: ActionSheetDataSource) {
    self.dataSource = dataSource
    super.init(nibName: nil, bundle: nil)
    listController.viewController = self
    listController.collectionView = collectionView
    backgroundButton.addTarget(self, action: #selector(backgroundPressed), for: .touchUpInside)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @available(*, unavailable)
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("Unsupported")
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    collectionView.backgroundColor = .white
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
    setupViewsAndConstraints()
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    let context = collectionView.collectionViewLayout.invalidationContext(forBoundsChange: .zero)
    coordinator.animate(alongsideTransition: { [weak self] _ in
      self?.collectionView.collectionViewLayout.invalidateLayout(with: context)
    })
  }

  // MARK: - Public

  func reloadCollectionView() {
    let cellModels = dataSource.loadCellModels()
    let section = ListSection(cellModels: cellModels, identifier: "singleSection")
    listController.update(with: [section], animated: false, completion: nil)
    let collectionHeight = cellModels.reduce(0, { $0 + (listController.size(of: $1)?.height ?? 0) })
    containerHeightConstraint.constant = collectionHeight + view.safeAreaInsets.bottom
    collectionView.collectionViewLayout.invalidateLayout()
  }


  func present(from viewController: UIViewController) {
    preferredContentSize = viewController.view.frame.size
    modalPresentationStyle = .custom
    _ = self.view
    viewController.present(self, animated: true, completion: nil)
  }

  // MARK: - Helpers

  @objc
  private func backgroundPressed(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }

  @objc
  private func keyboardWillShow(notification: NSNotification) {
    keyboard(willShow: true, notification: notification)
  }

  @objc
  private func keyboardWillHide(notification: NSNotification) {
    keyboard(willShow: false, notification: notification)
  }

  private func keyboard(willShow: Bool, notification: NSNotification) {
    let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    let keyboardHeight = willShow ? keyboardSize?.height ?? 0: 0
    let cellModels = listController.cellModels
    let collectionHeight = cellModels.reduce(0, { $0 + (listController.size(of: $1)?.height ?? 0) })
    containerHeightConstraint.constant = collectionHeight + view.safeAreaInsets.bottom + keyboardHeight
    view.layoutIfNeeded()
  }

  private func setupViewsAndConstraints() {
    view.addSubview(backgroundButton)
    backgroundButton.anchor(to: view)

    view.addSubview(collectionView)

    collectionView.anchor(toLeading: view.leadingAnchor, top: nil, trailing: view.trailingAnchor, bottom: nil)
    collectionBottomConstraint = collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    collectionBottomConstraint?.isActive = true

    containerHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
    containerHeightConstraint.isActive = true

    view.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}

extension ActionSheetVC {
  public static func createHeaderModel(
    identifier: String,
    leftText: String?,
    centerText: String,
    rightText: String?,
    leftAction: LabelCellModel.SelectionAction?,
    rightAction: LabelCellModel.SelectionAction?
  ) -> ListCellModel {
    let cancelModel = LabelCellModel(identifier: "cancelModel", text: leftText ?? "", font: .headline)
    cancelModel.leftMargin = 0
    cancelModel.rightMargin = 0
    cancelModel.textAlignment = .left
    cancelModel.textColor = .selectable
    cancelModel.selectionAction = leftAction

    let titleModel = LabelCellModel(identifier: "titleModel", text: centerText, font: .headline)
    titleModel.leftMargin = 0
    titleModel.rightMargin = 0
    titleModel.textAlignment = .center
    titleModel.textColor = .black

    let doneModel = LabelCellModel(identifier: "doneModel", text: rightText ?? "", font: .boldHeadline)
    doneModel.leftMargin = 0
    doneModel.rightMargin = 0
    doneModel.textAlignment = .right
    doneModel.textColor = .selectable
    doneModel.selectionAction = rightAction

    let cellModels = [cancelModel, titleModel, doneModel]
    let collectionModel = HorizontalCollectionCellModel(
      identifier: identifier,
      cellModels: cellModels,
      distribution: .equally(cellsInRow: cellModels.count),
      listController: ListController()
    )
    collectionModel.followsInsets = true
    collectionModel.topMargin = 10
    collectionModel.bottomMargin = 10
    collectionModel.isScrollEnabled = false
    collectionModel.bottomSeparatorColor = .separator
    return collectionModel
  }
}
