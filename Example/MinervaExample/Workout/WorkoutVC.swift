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

  private let addButton: UIButton = {
    let addButton = UIButton(frame: .zero)
    addButton.setImage(Asset.Add.image.withRenderingMode(.alwaysTemplate), for: .normal)
    addButton.tintColor = .selectable
    addButton.sizeToFit()
    return addButton
  }()

  private let disposeBag = DisposeBag()
  private let interactor: WorkoutInteractor
  private let presenter: WorkoutPresenter
  private let listController: ListController

  // MARK: - Lifecycle

  required init(interactor: WorkoutInteractor, presenter: WorkoutPresenter, listController: ListController) {
    self.interactor = interactor
    self.presenter = presenter
    self.listController = listController
    let layout = ListViewLayout(stickyHeaders: true, topContentInset: 0, stretchToEdge: true)
    super.init(layout: layout)
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    collectionView.backgroundColor = .white
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewsAndConstraints()

    presenter.persistentState
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: updated(_:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)

    presenter.transientState
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: updated(_:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)
  }

  // MARK: - Private
  private func updated(_ state: WorkoutPresenter.TransientState) {
    if state.showLoadingHUD {
      LoadingHUD.show(in: view)
    }
    if state.hideLoadingHUD {
      LoadingHUD.hide(from: view)
    }
    if let error = state.error {
      alert(error, title: "Something went wrong.")
    }
    interactor.clearTransientState()
  }

  private func updated(_ state: WorkoutPresenter.PersistentState) {
    title = state.title

    navigationItem.rightBarButtonItem = BlockBarButtonItem(
      image: Asset.Filter.image.withRenderingMode(.alwaysTemplate),
      style: .plain
    ) { [weak self] _ -> Void in
      self?.interactor.updateFilter(with: state.filter)
    }
    navigationItem.rightBarButtonItem?.tintColor = .selectable

    navigationItem.leftBarButtonItem = BlockBarButtonItem(
      title: state.showFailuresOnly ? "Failures Only" : "All",
      style: .plain
    ) { [weak self] _ -> Void in
      self?.interactor.showFailuresOnly(!state.showFailuresOnly)
    }
    navigationItem.leftBarButtonItem?.tintColor = .selectable

    listController.update(with: state.sections, animated: true, completion: nil)
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
    interactor.createWorkout()
  }
}
