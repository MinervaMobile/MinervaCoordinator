import Foundation
import Minerva
import UIKit

public final class WorkoutCellModel: SwipeableLabelCellModel, ListSelectableCellModel {

  public let workout: Workout

  public init(workout: Workout) {
    self.workout = workout

    super
      .init(
        identifier: workout.description,
        attributedText: NSAttributedString(string: "\(workout.details)\n\(workout.text)")
      )
    backgroundColor = .systemBackground
  }

  override public var cellType: ListCollectionViewCell.Type {
    SwipeableLabelCell.self
  }

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return workout.proto == model.workout.proto
  }

  // MARK: - ListSelectableCellModel
  public typealias SelectableModelType = WorkoutCellModel
  public var selectionAction: SelectionAction?
}
