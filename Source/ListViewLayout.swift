//
//  ListViewLayout.swift
//  Minerva
//
//  Created by Joe Laws
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import UIKit

import IGListKit

public class ListViewLayout: ListCollectionViewLayout {

  override public class var layoutAttributesClass: AnyClass {
    return ListViewLayoutAttributes.self
  }
}
