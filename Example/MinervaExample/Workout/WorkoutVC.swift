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
    case update(filter: WorkoutFilter)
  }

  private let actionsSubject: PublishSubject<Action>
  var actions: Observable<Action> {
    actionsSubject.asObservable()
  }

  private let addButton: UIButton = {
    let addButton = UIButton(frame: .zero)
    addButton.setImage(Asset.Add.image.withRenderingMode(.alwaysTemplate), for: .normal)
    addButton.tintColor = .selectable
    addButton.sizeToFit()
    return addButton
  }()

  private let disposeBag = DisposeBag()
  private var showFailuresOnly: Bool = false
  private var filter: WorkoutFilter = WorkoutFilterProto()
  private let interactor: WorkoutInteractor

  // MARK: - Lifecycle

  required init(interactor: WorkoutInteractor) {
    self.interactor = interactor
    self.actionsSubject = PublishSubject()
    let layout = ListViewLayout(stickyHeaders: true, topContentInset: 0, stretchToEdge: true)
    super.init(layout: layout)
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    collectionView.backgroundColor = .white
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: Asset.Filter.image.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: self,
      action: #selector(selectFilter))
    navigationItem.rightBarButtonItem?.tintColor = .selectable
    setupViewsAndConstraints()

    interactor.failuresOnly
      .subscribe(onNext: showFailuresOnly(_:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)

    interactor.filter
      .subscribe(onNext: updated(filter:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)

    interactor.user
      .subscribe(onNext: updated(user:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)
  }

  // MARK: - Private

  private func updated(user: Result<User, Error>) {
    switch user {
    case .success(let user):
      title = user.email
    case .failure(let error):
      alert(error, title: "Failed to load users data")
    }
  }

  private func updated(filter: WorkoutFilter) {
    self.filter = filter
  }

  private func showFailuresOnly(_ showFailuresOnly: Bool) {
    self.showFailuresOnly = showFailuresOnly
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: showFailuresOnly ? "Failures Only" : "All",
      style: .plain,
      target: self,
      action: #selector(toggleShowFailuresOnly))
    navigationItem.leftBarButtonItem?.tintColor = .selectable
  }

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
    actionsSubject.on(.next(.update(filter: filter)))
  }

  @objc
  private func toggleShowFailuresOnly() {
    interactor.showFailuresOnly(!showFailuresOnly)
  }
}
