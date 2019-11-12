//
//  ProtoExtensions.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation

import SwiftProtobuf

public enum ProtoError: Error {
	case parseError
}
extension Message {
	public init?(dictionary: [String: Any]) {
		do {
			guard JSONSerialization.isValidJSONObject(dictionary) else {
				assertionFailure("PROTO FAILURE: Invalid dictionary: \(dictionary)")
				return nil
			}
			let data = try JSONSerialization.data(withJSONObject: dictionary)
			var options = JSONDecodingOptions()
			options.ignoreUnknownFields = true
			try self.init(jsonUTF8Data: data, options: options)
		} catch {
			assertionFailure("PROTO FAILURE: Failed to convert the proto to json due to \(error) \(dictionary))")
			return nil
		}
	}

	public var dictionary: [String: Any] {
		do {
			var options = JSONEncodingOptions()
			options.alwaysPrintEnumsAsInts = true
			let data = try self.jsonUTF8Data(options: options)
			let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
			guard let dictionary = json as? [String: Any] else {
				assertionFailure("PROTO FAILURE: Failed to convert the json to a dictionary \(json)")
				return [:]
			}
			return dictionary
		} catch {
			assertionFailure("PROTO FAILURE: Failed to convert the proto to json due to \(error) \(self)")
			return [:]
		}
	}

	public func asDictionary() throws -> [String: Any] {
		var options = JSONEncodingOptions()
		options.alwaysPrintEnumsAsInts = true
		let data = try self.jsonUTF8Data(options: options)
		let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
		guard let dictionary = json as? [String: Any] else {
			throw ProtoError.parseError
		}
		return dictionary
	}

	public func asJSONString() throws -> String {
		var options = JSONEncodingOptions()
		options.alwaysPrintEnumsAsInts = true
		return try self.jsonString(options: options)
	}
}
