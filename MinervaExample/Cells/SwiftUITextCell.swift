//
// Copyright © 2020 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Combine
import Foundation
import Minerva
import RxSwift
import SwiftUI
import UIKit

@available(iOS 13.0, *)
public final class SwiftUITextCellModel: BaseListCellModel, ObservableObject,
  ListSelectableCellModel
{
  public typealias SelectableModelType = SwiftUITextCellModel
  public var selectionAction: SelectionAction?

  public var title: String
  public var subtitle: String?
  public var hasChevron: Bool
  public var backgroundColor: UIColor?
  public var titleColor: UIColor?
  public var subtitleColor: UIColor?

  private var cancelleable: AnyCancellable?
  public var imagePublisher: AnyPublisher<UIImage?, Error>? {
    didSet {
      cancelleable = imagePublisher?.receive(on: DispatchQueue.main)
        .sink(
          receiveCompletion: { _ in
          },
          receiveValue: { [weak self] i in
            self?.image = i
          }
        )
    }
  }
  public var imageObservable: Observable<UIImage?>? {
    didSet {
      imageObservable?
        .observeOn(MainScheduler.asyncInstance)
        .subscribe(onNext: { [weak self] i in
          self?.image = i
        })
        .disposed(by: disposeBag)
    }
  }

  private var disposeBag = DisposeBag()

  @Published public var image: UIImage?

  public init(
    title: String,
    subtitle: String? = nil,
    hasChevron: Bool = true
  ) {
    self.title = title
    self.subtitle = subtitle
    self.hasChevron = hasChevron
    super.init()
  }

  // MARK: - BaseListCellModel
  override public var identifier: String { title }

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return title == model.title
      && subtitle == model.subtitle
      && hasChevron == model.hasChevron
      && backgroundColor == model.backgroundColor
      && titleColor == model.titleColor
      && subtitleColor == model.subtitleColor
  }
}

@available(iOS 13.0, *)
public final class SwiftUITextCell: UICollectionViewCell, SwiftUICell {
  public var model: SwiftUITextCellModel?
  public var hostingController: UIHostingController<SwiftUITextView>?

  public func bindViewModel(_ viewModel: Any) { bind(viewModel) }
  public func bind(model: SwiftUITextCellModel, sizing: Bool) {
    setupHostingController(with: model)
    hostingController?.rootView.model = model
  }

  public func createView(with model: SwiftUITextCellModel) -> SwiftUITextView {
    SwiftUITextView(model: model)
  }
}

@available(iOS 13.0, *)
public struct SwiftUITextView: View {
  @ObservedObject public var model: SwiftUITextCellModel

  public var body: some View {
    ZStack {
      if model.backgroundColor != nil {
        Color(model.backgroundColor!)
      }
      HStack(spacing: 8) {
        if model.image != nil {
          Image(uiImage: model.image!)
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .animation(.easeInOut)
        }
        VStack(alignment: .leading, spacing: 4) {
          Text(model.title)
            .foregroundColor(Color(model.titleColor ?? .label))
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
          if model.subtitle != nil {
            Text(model.subtitle!)
              .foregroundColor(Color(model.subtitleColor ?? .secondaryLabel))
              .multilineTextAlignment(.leading)
              .lineLimit(nil)
          }
        }
        Spacer()
        if model.hasChevron {
          Image(Asset.Disclosure.rawValue)
            .renderingMode(.template)
            .scaledToFit()
        }
      }
      .padding()
    }
  }
}

@available(iOS 13.0, *)
public struct SwiftUITextViewPreviews: PreviewProvider {
  private static var cells: some View {
    List {
      SwiftUITextView(
        model: SwiftUITextCellModel(title: "Hello  World!!!", subtitle: "Bye World!!!")
      )
      SwiftUITextView(
        model: SwiftUITextCellModel(
          title: "Hello My Very Very Very Very Very Long World!!!",
          subtitle: "Bye World!!!"
        )
      )
      SwiftUITextView(
        model: SwiftUITextCellModel(
          title: "Hello World!!!",
          subtitle: "Bye World!!!",
          hasChevron: false
        )
      )
      SwiftUITextView(model: SwiftUITextCellModel(title: "Hello World!!!", hasChevron: false))
      SwiftUITextView(model: SwiftUITextCellModel(title: "Hello World!!!"))
    }
  }
  public static var previews: some View {
    Group {
      cells
      cells.environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
      cells.environment(\.colorScheme, .dark)
    }
  }
}
