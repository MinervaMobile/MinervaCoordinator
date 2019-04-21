//
//  Observable.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Darwin
import Foundation

public protocol Disposable {
  func unsubscribe(_ token: ObserverToken)
}

fileprivate class DisposableItem {
  private let disposable: Disposable
  private let token: ObserverToken

  fileprivate init(disposable: Disposable, token: ObserverToken) {
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

public final class DisposeBag {
  private var disposables = [DisposableItem]()

  public init() {
  }

  deinit {
    clear()
  }

  fileprivate func add<T>(_ observable: Observable<T>, with token: ObserverToken) {
    disposables.append(DisposableItem(disposable: observable, token: token))
  }

  public func clear() {
    disposables.forEach { $0.cancel() }
    disposables = []
  }
}

public struct ObserverToken: Hashable {
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

  public var next: ObserverToken {
    return ObserverToken(id: id &+ 1)
  }

  public static func == (lhs: ObserverToken, rhs: ObserverToken) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}

public final class Observable<T>: Disposable {
  private typealias Observer = (T) -> Void
  private var observers = [ObserverToken: Observer]()
  private var internalValue: T
  public var value: T {
    get {
      return lock {
        return internalValue
      }
    }
    set {
      var actualObservers: [Observer]? = nil
      lock {
        internalValue = newValue
        actualObservers = Array(observers.values)
      }
      actualObservers?.forEach { $0(newValue) }
    }
  }

  private var spinlock = os_unfair_lock()
  private var nextToken = ObserverToken()

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
  public func subscribe(in disposeBag: DisposeBag, _ observer: @escaping (T) -> Void) -> ObserverToken {
    var value = internalValue
    let token: ObserverToken = lock {
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

  public func unsubscribe(_ token: ObserverToken) {
    lock {
      observers[token] = nil
    }
  }
}
