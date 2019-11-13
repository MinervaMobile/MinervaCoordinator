//
//  Presenter.swift
//  Minerva
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

public protocol Presenter {
	var sections: Observable<[ListSection]> { get }
}
