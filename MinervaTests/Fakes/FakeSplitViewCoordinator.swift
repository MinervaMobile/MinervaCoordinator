//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift

public final class FakeSplitViewCoordinator: SplitViewCoordinator<FakeCoordinator, FakeCoordinator>
{
  public init(navigator: Navigator) {
    super
      .init(
        navigator: navigator,
        masterCoordinatorCreator: { masterNavigator -> FakeCoordinator in
          FakeCoordinator(navigator: masterNavigator)
        },
        detailCoordinatorCreator: { detailNavigator -> FakeCoordinator in
          FakeCoordinator(navigator: detailNavigator)
        }
      )

  }
}
