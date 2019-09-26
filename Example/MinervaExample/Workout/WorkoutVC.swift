//
//  WorkoutVC.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import Minerva
import PromiseKit

protocol WorkoutVCDelegate: AnyObject {
  func workoutVC(_ workoutVC: WorkoutVC, selected action: WorkoutVC.Action)
}

final class WorkoutVC: BaseViewController {

  enum Action {
    case createWorkout
    case updateFilter
  }

  weak var delegate: WorkoutVCDelegate?

  private let addButton: UIButton = {
    let addButton = UIButton(frame: .zero)
    addButton.setImage(Asset.Add.image.withRenderingMode(.alwaysTemplate), for: .normal)
    addButton.tintColor = .selectable
    addButton.sizeToFit()
    return addButton
  }()

  // MARK: - Lifecycle

  required override init() {
    super.init()
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
    delegate?.workoutVC(self, selected: .createWorkout)
  }

  @objc
  private func selectFilter() {
    delegate?.workoutVC(self, selected: .updateFilter)
  }
}
