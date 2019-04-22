//
//  Assets.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import UIKit.UIImage

enum Asset: String {

  case Add = "add"
  case Disclosure = "disclosure"
  case Filter = "filter"
  case Logo = "logo"
  case Workouts = "workouts"
  case Settings = "settings"
  case Users = "users"

  var image: UIImage {
    let bundle = Bundle(for: ImageBundleToken.self)
    guard let image = UIImage(named: self.rawValue, in: bundle, compatibleWith: nil) else {
      assertionFailure("Missing image for \(self.rawValue)")
      return UIImage()
    }
    return image
  }
}

fileprivate final class ImageBundleToken { }

