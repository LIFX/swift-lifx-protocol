///
///  Protocols.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

public let protocolVersion: UInt16 = 1024
public let defaultColor = try! Light.HSBK(kelvin: 3500)

public protocol FixedSizeElement { static var size: Int { get } }

public protocol DataEncodable { func toData() -> Data }

public protocol DataDecodable: Equatable { static func from(data: Data) throws -> Self }

/// Type which can be instantiated from data and serialized back to data. This type also has a canonical fixed size.
public typealias DataCodable = DataDecodable & DataEncodable
