//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxRelay
import RxSwift
import UIKit

public final class SettingsPresenter: ListPresenter {
  public enum Action {
    case deleteAccount
    case logout
    case update(user: User, indexPath: IndexPath)
  }

  private let actionsRelay = PublishRelay<Action>()
  public var actions: Observable<Action> { actionsRelay.asObservable() }
  public var sections = BehaviorRelay<[ListSection]>(value: [])

  private let disposeBag = DisposeBag()

  private let dataManager: DataManager

  // MARK: - Lifecycle

  public init(dataManager: DataManager) {
    self.dataManager = dataManager
    dataManager.user(withID: dataManager.userAuthorization.userID)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onSuccess: { [weak self] (user: User?) -> Void in
          guard let strongSelf = self else { return }
          strongSelf.sections.accept(strongSelf.createSections(with: user))
        },
        onError: { [weak self] _ -> Void in
          guard let strongSelf = self else { return }
          strongSelf.sections.accept(strongSelf.createSections(with: nil))
        }
      )
      .disposed(by: disposeBag)
  }

  // MARK: - Private

  private func createSections(with user: User?) -> [ListSection] {
    var sections = [ListSection]()

    if let user = user {
      var cellModels = [ListCellModel]()

      let nameCellModel = SwiftUITextCellModel(title: "Name", subtitle: user.email)
      nameCellModel.selectionAction = { [weak self] _, indexPath -> Void in
        guard let strongSelf = self else { return }
        strongSelf.actionsRelay.accept(.update(user: user, indexPath: indexPath))
      }
      cellModels.append(nameCellModel)

      let caloriesCellModel = SwiftUITextCellModel(
        title: "Daily Calories",
        subtitle: String(user.dailyCalories)
      )
      caloriesCellModel.selectionAction = { [weak self] _, indexPath -> Void in
        guard let strongSelf = self else { return }
        strongSelf.actionsRelay.accept(.update(user: user, indexPath: indexPath))
      }
      cellModels.append(caloriesCellModel)

      let roleCellModel = SwiftUITextCellModel(
        title: "Role",
        subtitle: dataManager.userAuthorization.role.description,
        hasChevron: false
      )
      roleCellModel.imagePublisher = dataManager.combineImage(forWorkoutID: "")
        .eraseToAnyPublisher()

      cellModels.append(roleCellModel)

      var section = ListSection(cellModels: cellModels, identifier: "USER")
      let headerModel = SwiftUITextCellModel(title: "USER", hasChevron: false)
      headerModel.backgroundColor = .secondarySystemBackground
      section.headerModel = headerModel
      sections.append(section)
    }

    var cellModels = [ListCellModel]()
    let logoutCellModel = SwiftUITextCellModel(title: "Logout")
    logoutCellModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.actionsRelay.accept(.logout)
    }
    cellModels.append(logoutCellModel)

    let deleteCellModel = SwiftUITextCellModel(title: "Delete")
    deleteCellModel.imageObservable = dataManager.image(forWorkoutID: "a").asObservable()

    deleteCellModel.selectionAction = { [weak self] _, _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.actionsRelay.accept(.deleteAccount)
    }
    cellModels.append(deleteCellModel)

    var section = ListSection(cellModels: cellModels, identifier: "ACCOUNT")
    let headerModel = SwiftUITextCellModel(title: "ACCOUNT", hasChevron: false)
    headerModel.backgroundColor = .secondarySystemBackground
    section.headerModel = headerModel
    sections.append(section)

    return sections
  }
}
