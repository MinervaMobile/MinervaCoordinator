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

final class WorkoutVC: UIViewController {

  enum Action {
    case createWorkout(userID: String)
    case update(filter: WorkoutFilter)
  }

  var isTabBarHidden = false
  weak var delegate: WorkoutVCDelegate?

  private let listController = ListController()

  private let collectionView: UICollectionView = {
    let layout = ListViewLayout(stickyHeaders: true, topContentInset: 0, stretchToEdge: true)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    collectionView.backgroundColor = .white
    return collectionView
  }()

  private let addButton: UIButton = {
    let addButton = UIButton(frame: .zero)
    addButton.setImage(Asset.Add.image.withRenderingMode(.alwaysTemplate), for: .normal)
    addButton.tintColor = .selectable
    addButton.sizeToFit()
    return addButton
  }()

  let userID: String
  private let dataSource: WorkoutDataSource
  private var filter: WorkoutFilter

  // MARK: - Lifecycle

  required init(userID: String, dataSource: WorkoutDataSource, filter: WorkoutFilter) {
    self.userID = userID
    self.dataSource = dataSource
    self.filter = filter
    super.init(nibName: nil, bundle: nil)
    listController.viewController = self
    listController.collectionView = collectionView
  }

  @available(*, unavailable)
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("Unsupported")
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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = false
    navigationController?.navigationBar.prefersLargeTitles = true
    tabBarHidden = isTabBarHidden
    loadModels(animated: true, completion: nil)
    dataSource.loadTitle().map { [weak self] title -> Void in
      self?.title = title
    }.catch { [weak self] error -> Void in
      UIAlertController.display(error, defaultTitle: "Failed to load users data", parentVC: self)
    }
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    let context = collectionView.collectionViewLayout.invalidationContext(forBoundsChange: .zero)
    coordinator.animate(alongsideTransition: { [weak self] _ in
      self?.collectionView.collectionViewLayout.invalidateLayout(with: context)
    })
  }

  // MARK: - Public

  func update(filter: WorkoutFilter) {
    self.filter = filter
  }

  func updateModels() {
    loadModels(animated: true, completion: nil)
  }

  // MARK: - Private

  private func loadModels(animated: Bool, completion: ((Bool) -> Void)?) {
    LoadingHUD.show(in: view)
    dataSource.loadSections(with: filter).done { [weak self] sections in
      guard let strongSelf = self else { return }
      strongSelf.listController.update(with: sections, animated: animated, completion: completion)
    }.catch { [weak self] error in
      UIAlertController.display(
        error,
        defaultTitle: "Failed to load your data",
        parentVC: self
      )
    }.finally { [weak self] in
      LoadingHUD.hide(from: self?.view)
    }
  }

  private func setupViewsAndConstraints() {
    view.backgroundColor = .white
    view.addSubview(collectionView)
    view.addSubview(addButton)

    collectionView.contentInset.bottom = addButton.frame.height + tabBarHeight

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
    delegate?.workoutVC(self, selected: .createWorkout(userID: userID))
  }

  @objc
  private func selectFilter() {
    delegate?.workoutVC(self, selected: .update(filter: filter))
  }
}
