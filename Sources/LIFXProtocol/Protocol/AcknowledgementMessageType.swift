///
///  AcknowledgementMessageType.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

/// Generic protocol for representing a message type that has no payload.
public protocol AbstractAcknowledgementMessageType: AbstractMessageType { init(header: Header) }

/// Get message is a type of message that only contains a header and has no payload.
public protocol AcknowledgementMessageType: AbstractAcknowledgementMessageType, GenericMessageType {}

extension AcknowledgementMessageType {
    public static var size: Int { return Header.size }
    public static func from(data: Data) throws -> Self {
        guard data.count == Self.size else { throw DeserializationErrors.insufficientBytes }
        let header = try Header.from(data: data.subdata(in: 0..<Header.size))
        return Self.init(header: header)
    }
    public func toData() -> Data { return header.toData() }
}
