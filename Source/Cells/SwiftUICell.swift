//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 13.0, tvOS 13.0, *)
public protocol SwiftUICell: AnyObject, ListTypedCell {
  associatedtype Content: View

  var hostingController: UIHostingController<Content>? { get set }

  func createView(with model: ModelType) -> Content
}

@available(iOS 13.0, tvOS 13.0, *)
extension SwiftUICell where Self: UICollectionViewCell {
  public func setupHostingController(with model: ModelType) {
    let view = createView(with: model)
    let hostingController = UIHostingController(rootView: view)
    self.hostingController = hostingController
    contentView.addSubview(hostingController.view)
    hostingController.view.anchor(to: contentView)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
