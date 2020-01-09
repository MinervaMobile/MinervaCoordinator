//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxRelay
import RxSwift
import UIKit

public final class UserListPresenter: Presenter {
  // TODO: Update the old presenter to use the new persistent / transient state model
  public var sections = BehaviorRelay<[ListSection]>(value: [])

  public enum Action {
    case delete(user: User)
    case edit(user: User)
    case view(user: User)
  }
  public enum State {
    case loading
    case failure(error: Error)
    case loaded(sections: [ListSection])
  }

  public private(set) var state: Observable<State>
  public var actions: Observable<Action> {
    actionsRelay.asObservable()
  }

  private let actionsRelay: PublishRelay<Action>
  private let repository: UserListRepository

  // MARK: - Lifecycle

  public init(repository: UserListRepository) {
    self.repository = repository
    self.actionsRelay = PublishRelay()
    self.state = Observable.just(.loading)
    self.state = self.state.concat(repository.users.map { [weak self] usersResult -> State in
      guard let strongSelf = self else {
        return .failure(error: SystemError.cancelled)
      }
      switch usersResult {
      case .success(let users):
        let sections = [strongSelf.createSection(with: users.sorted { $0.email < $1.email })]
        return .loaded(sections: sections)
      case .failure(let error):
        return .failure(error: error)
      }
    })
  }

  // MARK: - Private

  private func createSection(with users: [User]) -> ListSection {
    var cellModels = [ListCellModel]()

    let allowSelection = repository.allowSelection
    for user in users {
      let userCellModel = createUserCellModel(for: user)
      if allowSelection {
        userCellModel.selectionAction = { [weak self] _, _ -> Void in
          guard let strongSelf = self else { return }
          strongSelf.actionsRelay.accept(.view(user: user))
        }
      }
      cellModels.append(userCellModel)
    }

    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return section
  }

  private func createUserCellModel(for user: User) -> SwipeableLabelCellModel {
    let cellModel = SwipeableLabelCellModel(
      identifier: user.description,
      attributedText: NSAttributedString(string: "\(user.email)\n\(user.dailyCalories)", font: .body, fontColor: .label)
    )
    cellModel.backgroundColor = .systemBackground
    cellModel.deleteAction = { [weak self] _ -> Void in
      guard let strongSelf = self else { return }
      strongSelf.actionsRelay.accept(.delete(user: user))
    }
    return cellModel
  }

}
