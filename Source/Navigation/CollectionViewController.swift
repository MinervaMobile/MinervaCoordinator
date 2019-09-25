//
//  CollectionViewController.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//
import Foundation
import UIKit

public final class CollectionViewController: BaseViewController {

  public var hideNavigationBar: Bool = false
  public var backgroundImage: UIImage?

  // MARK: - UIViewController

  override public func viewDidLoad() {
    super.viewDidLoad()
    setupViewsAndConstraints()
    navigationItem.largeTitleDisplayMode = .never
  }

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(hideNavigationBar, animated: animated)
    collectionView.backgroundColor = backgroundImage == nil ? collectionView.backgroundColor : nil
  }

  // MARK: - Private

  private func setupViewsAndConstraints() {
    if let backgroundImage = backgroundImage {
      let imageView = UIImageView(image: backgroundImage)
      imageView.contentMode = .scaleAspectFill
      view.addSubview(imageView)
      imageView.anchor(to: view)
      collectionView.backgroundColor = nil
    }
    view.addSubview(collectionView)
    collectionView.anchorToTopSafeAreaLayoutGuide(in: view)
    view.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}
