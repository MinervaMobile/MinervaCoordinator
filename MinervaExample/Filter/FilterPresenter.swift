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

public final class FilterPresenter: Presenter {
  public enum Action {
    case edit(filter: WorkoutFilter, type: FilterType)
  }

  private let actionsRelay = PublishRelay<Action>()
  public var actions: Observable<Action> { actionsRelay.asObservable() }

  public var sections = BehaviorRelay<[ListSection]>(value: [])

  private let disposeBag = DisposeBag()

  // MARK: - Lifecycle

  public init(filter: Observable<WorkoutFilter>) {
    filter.map({ [weak self] in self?.createSection(with: $0) ?? [] })
      .bind(to: sections)
      .disposed(by: disposeBag)
  }

  // MARK: - Private

  private func createSection(with filter: WorkoutFilter) -> [ListSection] {
    var cellModels = [ListCellModel]()

    cellModels.append(LabelCellModel.createSectionHeaderModel(title: "FILTERS"))

    for type in FilterType.allCases {
      let details = filter.details(for: type) ?? "---"
      let nameCellModel = FilterCellModel(
        identifier: "\(filter)-\(type)-\(details)",
        title: type.description,
        details: details,
        hasChevron: true)
      nameCellModel.selectionAction = { [weak self] _, _ -> Void in
        guard let strongSelf = self else { return }
        strongSelf.actionsRelay.accept(.edit(filter: filter, type: type))
      }
      cellModels.append(nameCellModel)
    }

    let section = ListSection(cellModels: cellModels, identifier: "SECTION")
    return [section]
  }

}
