//
//  CloudKitValue.swift
//  
//
//  Created by Maurice Parker on 3/20/23.
//

import Foundation
import CloudKit

//public extension String: CloudKitSingleValue {}
// TODO: The rest here...
//public protocol Collection: CloudKitCollectionValue {}

public protocol CloudKitSingleValue<T> where T: CKRecordValueProtocol, T: Equatable, T: Codable {
	associatedtype T
}
//public protocol CloudKitCollection: Collection<Element> where Element: CKRecordValueProtocol, Element: Equatable, Element: Codable {}
public protocol CloudKitCollectionValue<T> { //} where T: CloudKitCollection {
	associatedtype T
}

public protocol CloudKitSingleValueHolder<Value>: CloudKitValueHolder<CloudKitSingleValue> {
	associatedtype Value
}
//public protocol CLoudKitCollectionValueHolder: CloudKitValueHolder<Value> where Value: CloudKitCollectionValue {}

public protocol CloudKitValueHolder<Value> {
	associatedtype Value
	var clientValue: Value? { get }
	var ancestorValue: Value? { get }
}

@propertyWrapper
public struct CloudKitValue<Value>: CloudKitValueHolder where Value: Equatable, Value: Codable {
	
	public private(set) var clientValue: Value?

	public var ancestorValue: Value? {
		return _ancestorValue ?? clientValue
	}
	
	public var wrappedValue: Value? {
		get { return clientValue }
		set {
			if _ancestorValue == nil && clientValue != newValue {
				_ancestorValue = clientValue
			}
			clientValue = newValue
		}
	}
	
	private enum CodingKeys: String, CodingKey {
		case clientValue
		case ancestorValue
	}

	private var _ancestorValue: Value?
	
	public init() {}
	
	public mutating func clearAncestorData() {
		_ancestorValue = nil
	}
}

extension CloudKitValue: Codable {

	public init(from decoder: Decoder) throws {
		if let value = try? Value.init(from: decoder) {
			self.clientValue = value
			return
		}
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.clientValue = try? container.decode(Value.self, forKey: .clientValue)
		self._ancestorValue = try? container.decode(Value.self, forKey: .ancestorValue)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(clientValue, forKey: .clientValue)
		try container.encode(_ancestorValue, forKey: .ancestorValue)
	}

}
