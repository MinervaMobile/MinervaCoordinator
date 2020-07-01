//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import Minerva
import RxSwift
import XCTest

public class CommonSetupTestCase: XCTestCase {
  public var listController: ListController!
  public var collectionVC: UICollectionViewController!

  override public func setUp() {
    super.setUp()
    collectionVC = UICollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    listController = LegacyListController()
    listController.collectionView = collectionVC.collectionView
    listController.viewController = collectionVC
    collectionVC.view.frame = CGRect(x: 0, y: 0, width: 200, height: 500)
  }

  override public func tearDown() {
    listController = nil
    super.tearDown()
  }

  public func verifySizeOfCell(at indexPath: IndexPath, matches expectedSize: CGSize) {
    guard
      let layout = listController.collectionView?.collectionViewLayout,
      let attributes = layout.layoutAttributesForItem(at: indexPath)
    else {
      XCTFail("Could not load layout attributes for item")
      return
    }

    XCTAssertEqual(attributes.frame.size, expectedSize)
  }
}
