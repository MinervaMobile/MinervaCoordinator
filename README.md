# Minerva

[![Build Status](https://travis-ci.org/OptimizeFitness/Minerva.svg?branch=master)](https://travis-ci.org/OptimizeFitness/Minerva)
[![codecov](https://codecov.io/gh/OptimizeFitness/Minerva/branch/master/graph/badge.svg)](https://codecov.io/gh/OptimizeFitness/Minerva)
[![Version](https://img.shields.io/cocoapods/v/Minerva.svg?style=flat)](http://cocoapods.org/pods/Minerva)
[![License](https://img.shields.io/cocoapods/l/Minerva.svg?style=flat)](http://cocoapods.org/pods/Minerva)

Minerva is an easy to use framework for structuring iOS, iPadOS and TvOS applications. It's key features include:

* A simplified Swift friendly MVVM framework built on top of IGListKit.
* A Coordinator framework that is similar to working with UIViewControllers.
* Common re-usable CollectionView cells for building an application.

## QuickStart

See the MinervaExample project for a full-featured example application built with Minerva.

### Coordinator

```swift
/// A Coordinator handles the state transition between Coordinators. This logic was previously part of the UIViewController's.
public protocol Coordinator: AnyObject {
	var parent: Coordinator? { get set }
	var childCoordinators: [Coordinator] { get set }
}
```

### Navigator

```swift
/// Manages the presentation of view controllers both modally and through a navigation controller.
public protocol Navigator: UIAdaptivePresentationControllerDelegate, UINavigationControllerDelegate {
	/// The block to use when a view controller is removed from the navigation controller.
	typealias RemovalCompletion = (UIViewController) -> Void

	/// Displays a view controller modally.
	/// - Parameter viewController: The view controller to display.
	/// - Parameter animated: Whether or not to animate the transition.
	/// - Parameter completion: The completion to be called when the view controller is no longer on the view stack.
	func present(_ viewController: UIViewController, animated: Bool, completion: RemovalCompletion?)

	/// Removes a modally presented view controller from the view stack.
	/// - Parameter viewController: The view controller to remove.
	/// - Parameter animated: Whether or not to animate the transition.
	/// - Parameter completion: The completion to be called when the view controller is no longer on the view stack.
	func dismiss(_ viewController: UIViewController, animated: Bool, completion: RemovalCompletion?)

	/// Displays a view controller in the navigators navigation controller.
	/// - Parameter viewController: The view controller to display.
	/// - Parameter animated: Whether or not to animate the transition.
	/// - Parameter completion: The completion to be called when the view controller is no longer on the view stack.
	func push(_ viewController: UIViewController, animated: Bool, completion: RemovalCompletion?)

	/// Sets the view controller's in the navigators navigation controller.
	/// - Parameter viewControllers: The view controllers to display.
	/// - Parameter animated: Whether or not to animate the transition.
	/// - Parameter completion: The completion to be called when the view controller is no longer on the view stack.
	func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion: RemovalCompletion?)

	/// Removes all but the top view controller from the Navigator's navigation controller.
	/// - Parameter animated: Whether or not to animate the transition.
	@discardableResult
	func popToRootViewController(animated: Bool) -> [UIViewController]?

	/// Removes all view controller's above the provided view controller from the Navigator's navigation controller.
	/// - Parameter viewController: The view controller to display.
	/// - Parameter animated: Whether or not to animate the transition.
	@discardableResult
	func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?

	/// Removes the top navigation controller from the navigation stack.
	/// - Parameter animated: Whether or not to animate the transition.
	@discardableResult
	func popViewController(animated: Bool) -> UIViewController?
}
```

### ListCellModel

```swift
/// The model that will bind to a cell.
public protocol ListCellModel {
	/// A unique identifier for the cell model. If the model identifiers are different,
	/// the cells are assumed to be completely different triggering a delete and
	/// an insert of a new cell.
	var identifier: String { get }

	/// The type of list cell that this model should be bound to.
	var cellType: ListCollectionViewCell.Type { get }

	/// Determines if two models with the same identifier are equal. If they are not, then the cell is reloaded and bound to the new model.
	/// - Parameter model: The model to compare against.
	func identical(to model: ListCellModel) -> Bool

	/// Provides the size that the models cell will need.
	/// - Parameter containerSize: The max size that the cell can occupy.
	/// - Parameter templateProvider: Provides a template cell to size against when supplying an explicit size.
	func size(constrainedTo containerSize: CGSize, with templateProvider: () -> ListCollectionViewCell) -> ListCellSize
}
```

## Installation

### CocoaPods

Minerva supports installation via CocoaPods. You can depend on Minerva by adding the following to your Podfile:

```
pod "Minerva"
```

## Bugs / Contributions

If you encounter bugs or missing features in Minerva, please feel free to open a GitHub issue or send out a PR.

Contributions and bug fixes are appreciated.

## License

Minerva is licensed under the permissive MIT license.

## See Also

* [Optimize Fitness](https://optimize.fitness/): An iOS application built using Minerva
