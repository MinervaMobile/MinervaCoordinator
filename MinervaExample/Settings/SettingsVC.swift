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

public final class SettingsVC: CollectionViewController {

  public enum Action {
    case editUser(barButtonItem: UIBarButtonItem)
  }

  public let actionRelay = PublishRelay<Action>()

  override public func viewDidLoad() {
    super.viewDidLoad()
    title = "Settings"

    navigationItem.rightBarButtonItem = BlockBarButtonItem(
      image: Asset.Settings.image.withRenderingMode(.alwaysTemplate),
      style: .plain
    ) { [weak self] barButtonItem -> Void in
      self?.actionRelay.accept(.editUser(barButtonItem: barButtonItem))
    }
    navigationItem.rightBarButtonItem?.tintColor = .selectable
  }

}
