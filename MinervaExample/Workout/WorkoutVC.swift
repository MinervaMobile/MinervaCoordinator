//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class WorkoutVC: BaseViewController {

  private let addButton: UIButton = {
    let addButton = UIButton(frame: .zero)
    addButton.setImage(Asset.Add.image.withRenderingMode(.alwaysTemplate), for: .normal)
    addButton.tintColor = .selectable
    addButton.sizeToFit()
    return addButton
  }()

  private let disposeBag = DisposeBag()
  private let presenter: WorkoutPresenter
  private let listController: ListController

  // MARK: - Lifecycle

  public required init(presenter: WorkoutPresenter, listController: ListController) {
    self.presenter = presenter
    self.listController = listController
    let layout = ListViewLayout(stickyHeaders: true, topContentInset: 0, stretchToEdge: true)
    super.init(layout: layout)
    collectionView.backgroundColor = .white
  }

  // MARK: - UIViewController

  override public func viewDidLoad() {
    super.viewDidLoad()
    setupViewsAndConstraints()

    presenter.sections
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: updated(_:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)

    presenter.persistentState
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: updated(_:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)

    presenter.transientState
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: updated(_:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)

    navigationItem.rightBarButtonItem = BlockBarButtonItem(
      image: Asset.Filter.image.withRenderingMode(.alwaysTemplate),
      style: .plain
    ) { [weak self] _ -> Void in
      self?.presenter.editFilter()
    }
    navigationItem.rightBarButtonItem?.tintColor = .selectable
  }

  // MARK: - State Change

  private func updated(_ sections: [ListSection]) {
    listController.update(with: sections, animated: true, completion: nil)
  }

  private func updated(_ state: WorkoutPresenter.TransientState) {
    if state.loading {
      LoadingHUD.show(in: view)
    } else {
      LoadingHUD.hide(from: view)
    }
    if let error = state.error {
      alert(error, title: "Something went wrong.")
    }
  }

  private func updated(_ state: WorkoutPresenter.PersistentState) {
    title = state.title
  }

  // MARK: - Private

  private func setupViewsAndConstraints() {
    view.backgroundColor = .white
    view.addSubview(collectionView)
    view.addSubview(addButton)

    collectionView.contentInset.bottom = addButton.frame.height + 20

    collectionView.anchor(to: view)
    view.shouldTranslateAutoresizingMaskIntoConstraints(false)

    addButton.addTarget(
      self,
      action: #selector(addButtonPressed),
      for: .touchUpInside
    )
    addButton.equalHorizontalCenter(with: view)
    addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
      .isActive = true
  }

  @objc
  private func addButtonPressed() {
    presenter.createWorkout()
  }
}
