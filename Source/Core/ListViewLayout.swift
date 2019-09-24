//
//  ListViewLayout.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

// TODO: Remove this dependency on IGListKit's ListCollectionViewLayout
public class ListViewLayout: ListCollectionViewLayout {

  override public class var layoutAttributesClass: AnyClass {
    return ListViewLayoutAttributes.self
  }
}
