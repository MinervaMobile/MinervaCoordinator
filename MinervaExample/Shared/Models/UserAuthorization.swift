//
//  UserAuthorization.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

public protocol UserAuthorization: CustomStringConvertible {
	var userID: String { get }
	var accessToken: String { get }
	var role: UserRole { get }
}

extension UserAuthorization {
	public var description: String {
		return proto.debugDescription
	}

	public var proto: UserAuthorizationProto {
		if let proto = self as? UserAuthorizationProto {
			return proto
		} else {
			return UserAuthorizationProto(
				userID: userID,
				accessToken: accessToken,
				role: role
			)
		}
	}
}

extension UserAuthorizationProto: UserAuthorization {

	public init(
		userID: String,
		accessToken: String,
		role: UserRole
	) {
		self.userID = userID
		self.accessToken = accessToken
		self.role = role
	}
}
