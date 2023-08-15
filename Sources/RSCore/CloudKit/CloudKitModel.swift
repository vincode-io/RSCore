//
//  CloudKitModel.swift
//  
//
//  Created by Maurice Parker on 3/18/23.
//

import Foundation
import CloudKit

public protocol CloudKitModel {
	
	typealias CloudKitKeyPath = PartialKeyPath<Self>

	var recordType: String { get }
	var recordID: CKRecord.ID { get }
	var recordFields: [String: CloudKitKeyPath] { get }
	var syncMetaData: Data? { get }
	
	var clientRecord: CKRecord { get }
	var ancestorRecord: CKRecord { get }

	func clearAncestorData()
	
}

public extension CloudKitModel {
	
	var clientRecord: CKRecord {
		var record: CKRecord = {
			if let syncMetaData = syncMetaData, let record = CKRecord(syncMetaData) {
				return record
			} else {
				return CKRecord(recordType: recordType, recordID: recordID)
			}
		}()
		
		for recordField in recordFields {
			guard let cloudKitValue = self[keyPath: recordField.value] as? any CloudKitValueHolder else { continue }
			assign(&record, key: recordField.key, value: cloudKitValue.clientValue)
		}
		
		return record
	}
	
	var ancestorRecord: CKRecord {
		var record: CKRecord = {
			if let syncMetaData = syncMetaData, let record = CKRecord(syncMetaData) {
				return record
			} else {
				return CKRecord(recordType: recordType, recordID: recordID)
			}
		}()
		
		for recordField in recordFields {
			guard let cloudKitValue = self[keyPath: recordField.value] as? any CloudKitValueHolder else { continue }
			assign(&record, key: recordField.key, value: cloudKitValue.ancestorValue)
		}
		
		return record
	}
	
	func clearAncestorData() {
		
	}

}

private extension CloudKitModel {

//	func assign(_ record: inout CKRecord, key: String, value: Any) {
//		if let value = value as? CKRecordValueProtocol {
//			record[key] = value
//		} else if let value = value as? any Collection<CKRecordValueProtocol> {
//			record[key] = Array(value)
//		}
//	}
	
	func assign(_ record: inout CKRecord, key: String, value: some CloudKitValueHolder<CKRecordValueProtocol>, valueKeyPath: CloudKitKeyPath) {
		guard let recordValue = value as? CKRecordValueProtocol else { assertionFailure() }
		record[key] = recordValue
	}
		
	func assign<T>(_ record: inout CKRecord, key: String, value: any Collection<T>) where T: CKRecordValueProtocol, T: Codable, T:Equatable, T:Hashable {
		record[key] = Array(value)
	}
		
//	func assign<T>(_ record: inout CKRecord, key: String, value: T) where T: Codable, T:Equatable {
//		assertionFailure()
//	}
	
}
