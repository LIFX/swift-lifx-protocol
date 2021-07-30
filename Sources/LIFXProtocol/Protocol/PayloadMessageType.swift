///
///  PayloadMessageType.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

/// Generic protocol for representing a message that has a payload. To access the payload, you
/// must first cast to the concrete implementation.
public protocol AbstractPayloadMessageType: AbstractMessageType { init(header: Header, payload: Data) throws }

/// Payload message also contains associated data stored in an implementation-specific payload.
public protocol PayloadMessageType: AbstractPayloadMessageType, GenericMessageType {
    associatedtype Payload: MessagePayload
    var payload: Payload { get }
    init(header: Header, payload: Payload)
}

extension PayloadMessageType {
    public static var size: Int { return Header.size + Payload.size }
    public init(header: Header, payload data: Data) throws {
        let payload = try Payload.from(data: data)
        self.init(header: header, payload: payload)
    }
    public static func from(data: Data) throws -> Self {
        guard data.count == Self.size else { throw DeserializationErrors.insufficientBytes }
        let header = try Header.from(data: data.subdata(in: 0..<Header.size))
        let payload = try Payload.from(data: data.subdata(in: Header.size..<Header.size + Payload.size))
        return Self.init(header: header, payload: payload)
    }
    public func toData() -> Data {
        var data = header.toData()
        data.append(payload.toData())
        return data
    }
}

// MARK: - MessagePayload

/// Generic representation of message contents.
public protocol MessagePayload: DataCodable, FixedSizeElement { associatedtype Message: PayloadMessageType }
