//
//  CloudKitModel.swift
//  
//
//  Created by Maurice Parker on 3/18/23.
//

import Foundation
import CloudKit

// https://www.swiftbysundell.com/articles/accessing-a-swift-property-wrappers-enclosing-instance/#proxy-properties
//@propertyWrapper
//public struct CloudKitValue<EnclosingType, Value: Equatable> where Value: Codable {
//	public typealias ValueKeyPath = ReferenceWritableKeyPath<EnclosingType, Value?>
//	public typealias SelfKeyPath = ReferenceWritableKeyPath<EnclosingType, Self>
//
//	private let keyPath: ValueKeyPath
//	private let value: Value?
//
//	public static subscript(_enclosingInstance instance: EnclosingType,
//					 wrapped wrappedKeyPath: ValueKeyPath,
//					 storage storageKeyPath: SelfKeyPath) -> Value? {
//		get {
//			return instance[keyPath: wrappedKeyPath]
//		}
//		set {
//			let keyPath = instance[keyPath: storageKeyPath].keyPath
//			let ancestorValue = instance[keyPath: keyPath]
//			if ancestorValue == nil {
//				let wrappedValue = instance[keyPath: wrappedKeyPath]
//				if ancestorValue != wrappedValue {
//					instance[keyPath: keyPath] = wrappedValue
//				}
//			}
//			instance[keyPath: wrappedKeyPath] = newValue
//		}
//	}
//
//	@available(*, unavailable, message: "@CloudKitValue can only be applied to classes")
//	public var wrappedValue: Value? {
//		get { fatalError() }
//		set { fatalError() }
//	}
//
//	public init(_ keyPath: ValueKeyPath) {
//		self.keyPath = keyPath
//		self.value = nil
//	}
//
//}

@propertyWrapper
public struct CloudKitValue<Value> where Value: Equatable, Value: Codable {
	private enum CodingKeys: String, CodingKey {
		case value
		case ancestorValue
	}

	private var value: Value?
	private var ancestorValue: Value?

	public var wrappedValue: Value? {
		get { return value }
		set {
			if ancestorValue == nil && value != newValue {
				ancestorValue = value
			}
			value = newValue
		}
	}
	
	public init() {}
}

extension CloudKitValue: Codable {

	public init(from decoder: Decoder) throws {
		if let value = try? Value.init(from: decoder) {
			self.value = value
			return
		}
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.value = try container.decode(Value.self, forKey: .value)
		self.ancestorValue = try container.decode(Value.self, forKey: .ancestorValue)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(value, forKey: .value)
		try container.encode(ancestorValue, forKey: .ancestorValue)
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
