//
//  UserListVC.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import RxSwift

final class UserListVC: BaseViewController {

  enum Action {
    case createUser
  }

  var actions: Observable<Action> {
    actionsSubject.asObservable()
  }

  private let actionsSubject: PublishSubject<Action>
  private let listController = ListController()

  private let addButton: UIButton = {
    let addButton = UIButton(frame: .zero)
    addButton.setImage(Asset.Add.image.withRenderingMode(.alwaysTemplate), for: .normal)
    addButton.tintColor = .selectable
    addButton.sizeToFit()
    return addButton
  }()

  // MARK: - Lifecycle

  required init() {
    self.actionsSubject = PublishSubject()
    super.init()

    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    collectionView.backgroundColor = .white

    self.title = "Users"
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewsAndConstraints()
  }

  // MARK: - Private

  private func setupViewsAndConstraints() {
    view.backgroundColor = .white
    view.addSubview(collectionView)
    view.addSubview(addButton)

    collectionView.contentInset.bottom = addButton.frame.height + 20

    anchorViewToTopSafeAreaLayoutGuide(collectionView)
    view.shouldTranslateAutoresizingMaskIntoConstraints(false)

    addButton.addTarget(
      self,
      action: #selector(addButtonPressed),
      for: .touchUpInside)
    addButton.equalHorizontalCenter(with: view)
    addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
  }

  @objc
  private func addButtonPressed() {
    actionsSubject.on(.next(.createUser))
  }
}
