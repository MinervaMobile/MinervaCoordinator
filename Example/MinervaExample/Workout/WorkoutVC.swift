//
//  WorkoutVC.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import RxSwift

final class WorkoutVC: BaseViewController {

  enum Action {
    case createWorkout
    case updateFilter
    case toggleAll
  }

  var actions: Observable<Action> {
    actionsSubject.asObservable()
  }

  private let actionsSubject: PublishSubject<Action>

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
    let layout = ListViewLayout(stickyHeaders: true, topContentInset: 0, stretchToEdge: true)
    super.init(layout: layout)
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    collectionView.backgroundColor = .white
  }

  // MARK: - Public
  func showFailuresOnly(_ showFailuresOnly: Bool) {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: showFailuresOnly ? "Failures Only" : "All",
      style: .plain,
      target: self,
      action: #selector(toggleAll))
    navigationItem.leftBarButtonItem?.tintColor = .selectable
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "ALL",
      style: .plain,
      target: self,
      action: #selector(toggleAll))
    navigationItem.leftBarButtonItem?.tintColor = .selectable

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: Asset.Filter.image.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: self,
      action: #selector(selectFilter))
    navigationItem.rightBarButtonItem?.tintColor = .selectable
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
    actionsSubject.on(.next(.createWorkout))
  }

  @objc
  private func selectFilter() {
    actionsSubject.on(.next(.updateFilter))
  }

  @objc
  private func toggleAll() {
    actionsSubject.on(.next(.toggleAll))
  }
}
