//
//  UserVC.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import PromiseKit

protocol UserVCDelegate: class {
  func userVC(_ userVC: UserVC, selected tab: UserVC.Tab)
}

final class UserVC: UIViewController, TabBarManager {

  enum Tab: Int {
    case workouts = 1
    case users = 2
    case settings = 3

    fileprivate var item: UITabBarItem? {
      return Tab.tabBarItems[self]
    }

    fileprivate static func tabs(for role: UserRole) -> [Tab] {
      switch role {
      case .user: return [.workouts, .settings]
      case .admin, .userManager: return [.workouts, .users, .settings]
      }
    }

    private static func item(for tab: Tab) -> UITabBarItem {
      let tabBarItem = UITabBarItem()
      tabBarItem.tag = tab.rawValue
      switch tab {
      case .workouts:
        tabBarItem.title = "Workouts"
        tabBarItem.image = Asset.Workouts.image.withRenderingMode(.alwaysTemplate)
      case .users:
        tabBarItem.title = "Users"
        tabBarItem.image = Asset.Users.image.withRenderingMode(.alwaysTemplate)
      case .settings:
        tabBarItem.title = "Settings"
        tabBarItem.image = Asset.Settings.image.withRenderingMode(.alwaysTemplate)
      }
      return tabBarItem
    }

    private static var tabBarItems: [Tab: UITabBarItem] = {
      return [
          .workouts: item(for: .workouts),
          .users: item(for: .users),
          .settings: item(for: .settings)
      ]
    }()
  }

  weak var delegate: UserVCDelegate?

  let navigationVC: UINavigationController

  private let tabBar: UITabBar = {
    let tabBar = UITabBar(frame: .zero)
    tabBar.itemPositioning = .automatic
    tabBar.tintColor = .selectable
    tabBar.backgroundImage = UIImage()
    tabBar.backgroundColor = .controllers
    tabBar.unselectedItemTintColor = .lightGray
    return tabBar
  }()

  private var tab: Tab
  private var tabBarBottomConstraint: NSLayoutConstraint?

  private let userAuthorization: UserAuthorization

  // MARK: - TabBarManager

  var tabBarIsHidden: Bool {
    get { return (tabBarBottomConstraint?.constant ?? 0) > 0 }
    set { setTabBarHidden(newValue) }
  }

  var tabHeight: CGFloat {
    return self.tabBar.bounds.height
  }

  // MARK: - Lifecycle

  required init(userAuthorization: UserAuthorization) {
    self.userAuthorization = userAuthorization
    self.tab = .workouts
    self.navigationVC = UINavigationController()
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("Unsupported")
  }

  // MARK: - UIViewController

  override var childForStatusBarStyle: UIViewController? {
    return navigationController
  }

  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return UIApplication.shared.statusBarOrientation
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    self.tabBar.setItems(Tab.tabs(for: userAuthorization.role).compactMap { $0.item }, animated: false)
    self.tabBar.delegate = self
    self.setupConstraints()
    self.change(to: tab)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard !tabBarIsHidden else { return }
    restoreTabBarHeight()
  }

  // MARK: - Private

  private func setTabBarHidden(_ hidden: Bool) {
    guard hidden != tabBarIsHidden else { return }
    if hidden {
      tabBarBottomConstraint?.constant = tabBar.frame.height
    } else {
      restoreTabBarHeight()
    }
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }

  private func setupConstraints() {
    view.addSubview(tabBar)

    navigationVC.willMove(toParent: self)
    addChild(navigationVC)
    view.addSubview(navigationVC.view)

    tabBar.anchor(
      toLeading: view.leadingAnchor,
      top: navigationVC.view.bottomAnchor,
      trailing: view.trailingAnchor,
      bottom: nil)

    tabBarBottomConstraint = tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    tabBarBottomConstraint?.priority = .defaultLow
    tabBarBottomConstraint?.isActive = true

    navigationVC.view.anchor(
      toLeading: view.leadingAnchor,
      top: view.topAnchor,
      trailing: view.trailingAnchor,
      bottom: nil)

    navigationVC.didMove(toParent: self)

    tabBar.shouldTranslateAutoresizingMaskIntoConstraints(false)
    view.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }

  private func restoreTabBarHeight() {
    tabBarBottomConstraint?.constant = 0
    tabBar.invalidateIntrinsicContentSize()
    tabBar.updateConstraints()
  }

  private func activate(_ tab: Tab) {
    guard self.tab != tab else {
      return
    }
    change(to: tab)
  }

  private func change(to tab: Tab) {
    tabBar.selectedItem = tabBar.items?.first { $0.tag == tab.rawValue }
    self.tab = tab
    delegate?.userVC(self, selected: tab)
  }
}

// MARK: - UITabBarDelegate
extension UserVC: UITabBarDelegate {
  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    guard let tab = Tab(rawValue: item.tag) else {
      assertionFailure("Unknown tab \(item.tag)")
      return
    }
    activate(tab)
  }
}
