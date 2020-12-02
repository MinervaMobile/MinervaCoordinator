//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import PanModal
import UIKit

extension CoordinatorNavigator {
  public func presentPanModal(
    _ coordinator: PanModalCoordinatorPresentable,
    animated: Bool = true,
    animationCompletion: AnimationCompletion? = nil
  ) {
    addChild(coordinator)
    presentedCoordinator = coordinator
    navigator.present(
      coordinator.panModalPresentableVC,
      animated: animated,
      removalCompletion: { [weak self, weak coordinator] _ in
        guard let coordinator = coordinator else { return }
        self?.removeChild(coordinator)
      },
      animationCompletion: animationCompletion
    )
  }
}
