import Foundation
import Minerva
import RxSwift
import UIKit

public final class WorkoutSplitCoordinator: SplitViewCoordinator<
  WorkoutCoordinator, DefaultSplitDetailCoordinator
> {
  private let disposeBag = DisposeBag()
  private let dataManager: DataManager
  private let userID: String

  public init(navigator: Navigator, dataManager: DataManager, userID: String) {
    self.dataManager = dataManager
    self.userID = userID
    super
      .init(
        navigator: navigator,
        masterCoordinatorCreator: { masterNavigator in
          WorkoutCoordinator(
            navigator: masterNavigator,
            dataManager: dataManager,
            userID: userID
          )
        },
        detailCoordinatorCreator: { detailNavigator in
          DefaultSplitDetailCoordinator(navigator: detailNavigator)
        }
      )
    splitViewController.preferredPrimaryColumnWidthFraction = 0.5
    splitViewController.preferredDisplayMode = .allVisible
    splitViewController.maximumPrimaryColumnWidth = .greatestFiniteMagnitude

    masterCoordinator
      .actionRelay
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: handle(action:), onError: nil, onCompleted: nil, onDisposed: nil)
      .disposed(by: disposeBag)
  }

  // MARK: - Helpers

  private func createEditWorkoutCoordinator(with workout: Workout?) -> EditWorkoutCoordinator {
    let editing = workout != nil
    let workout =
      workout
        ?? WorkoutProto(
          workoutID: UUID().uuidString,
          userID: userID,
          text: "",
          calories: 0,
          date: Date()
        )
    return EditWorkoutCoordinator(
      navigator: splitNavigator,
      dataManager: dataManager,
      workout: workout,
      editing: editing
    )
  }

  private func createWorkoutDetailsCoordinator(with workout: Workout) -> WorkoutDetailsCoordinator {
    WorkoutDetailsCoordinator(
      navigator: splitNavigator,
      dataManager: dataManager,
      workout: workout,
      editing: true
    )
  }

  private func handle(action: WorkoutCoordinator.Action) {
    switch action {
    case .displayNewWorkout:
      let coordinator = createEditWorkoutCoordinator(with: nil)
      setDetailCoordinator(coordinator)
    case let .displayViewWorkout(workout):
      let coordinator = createWorkoutDetailsCoordinator(with: workout)
      setDetailCoordinator(coordinator)
    }
  }
}
