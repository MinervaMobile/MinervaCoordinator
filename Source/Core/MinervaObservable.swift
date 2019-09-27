//
//  MinervaObservable.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Darwin
import Foundation

public protocol MinervaDisposable {
  func unsubscribe(_ token: MinervaObserverToken)
}

private class MinervaMinervaDisposableItem {
  private let disposable: MinervaDisposable
  private let token: MinervaObserverToken

  fileprivate init(disposable: MinervaDisposable, token: MinervaObserverToken) {
    self.disposable = disposable
    self.token = token
  }

  deinit {
    cancel()
  }

  fileprivate func cancel() {
    disposable.unsubscribe(token)
  }
}

public final class MinervaDisposeBag {
  private var disposables = [MinervaMinervaDisposableItem]()

  public init() {
  }

  deinit {
    clear()
  }

  fileprivate func add<T>(_ observable: MinervaObservable<T>, with token: MinervaObserverToken) {
    disposables.append(MinervaMinervaDisposableItem(disposable: observable, token: token))
  }

  public func clear() {
    disposables.forEach { $0.cancel() }
    disposables = []
  }
}

public struct MinervaObserverToken: Hashable {
  public let id: Int

  public init() {
    self.init(id: 0)
  }

  public init(id: Int) {
    self.id = id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public var next: MinervaObserverToken {
    return MinervaObserverToken(id: id &+ 1)
  }

  public static func == (lhs: MinervaObserverToken, rhs: MinervaObserverToken) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}

public final class MinervaObservable<T>: MinervaDisposable {
  private typealias Observer = (T) -> Void
  private var observers = [MinervaObserverToken: Observer]()
  private var internalValue: T
  public var value: T {
    get {
      return lock {
        internalValue
      }
    }
    set {
      var actualObservers: [Observer]?
      lock {
        internalValue = newValue
        actualObservers = Array(observers.values)
      }
      actualObservers?.forEach { $0(newValue) }
    }
  }

  private var spinlock = os_unfair_lock()
  private var nextToken = MinervaObserverToken()

  public init(_ value: T) {
    self.internalValue = value
  }

  private func lock<T>(_ closure: () -> T) -> T {
    os_unfair_lock_lock(&spinlock)
    defer {
      os_unfair_lock_unlock(&spinlock)
    }
    return closure()
  }

  @discardableResult
  public func subscribe(in disposeBag: MinervaDisposeBag, _ observer: @escaping (T) -> Void) -> MinervaObserverToken {
    var value = internalValue
    let token: MinervaObserverToken = lock {
      let token = nextToken
      nextToken = token.next
      observers[token] = observer
      value = internalValue
      return token
    }
    disposeBag.add(self, with: token)
    observer(value)
    return token
  }

  public func unsubscribe(_ token: MinervaObserverToken) {
    lock {
      observers[token] = nil
    }
  }
}
