//
//  CloudKitModel.swift
//  
//
//  Created by Maurice Parker on 3/18/23.
//

import Foundation
import CloudKit

@propertyWrapper
public struct CloudKitValue<Value> where Value: Equatable, Value: Codable {
	
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

public protocol CloudKitModel {
	
	typealias CloudKitKeyPath = PartialKeyPath<Self>

	var recordType: String { get }
	var recordID: CKRecord.ID { get }

	var clientRecord: CKRecord { get }
	var ancestorRecord: CKRecord { get }

	func clearAncestorData()
}

public extension CloudKitModel {
	
	var clientRecord: CKRecord {
		return CKRecord(recordType: recordType, recordID: recordID)
	}
	
	var ancestorRecord: CKRecord {
		return CKRecord(recordType: recordType, recordID: recordID)
	}
	
	func clearAncestorData() {
		
	}
}
