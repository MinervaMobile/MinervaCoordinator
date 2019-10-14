//
//  CollectionViewController.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//
import Foundation
import UIKit

open class CollectionViewController: BaseViewController {

  public var hideNavigationBar: Bool = false
  public var backgroundImage: UIImage?
  public var backgroundColor: UIColor = .white

  // MARK: - UIViewController

  override public func viewDidLoad() {
    super.viewDidLoad()
    setupViewsAndConstraints()
  }

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(hideNavigationBar, animated: animated)
    if backgroundImage != nil {
      collectionView.backgroundColor = nil
    }
  }

  // MARK: - Private

  private func setupViewsAndConstraints() {
    if let backgroundImage = backgroundImage {
      let imageView = UIImageView(image: backgroundImage)
      imageView.contentMode = .scaleAspectFill
      view.addSubview(imageView)
      imageView.anchor(to: view)
      collectionView.backgroundColor = nil
    } else {
      collectionView.backgroundColor = backgroundColor
    }
    view.addSubview(collectionView)
    collectionView.anchor(to: view)
    view.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
