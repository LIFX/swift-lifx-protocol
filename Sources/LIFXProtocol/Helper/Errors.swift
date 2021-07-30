///
///  Errors.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

public enum DeserializationErrors: Error {
    /// Invalid UTF-8 string
    case invalidString
    /// Insufficient bytes to deserialize content
    case insufficientBytes
    /// Invalid or unknown enum value
    case invalidEnumValue
    /// Invalid message size (i.e. not enough bytes)
    case invalidSize
    /// Unknown message type, likely a new message
    /// of which the implementation is unaware.
    case invalidMessageType
    /// Invalid message implementation, likely a logic error
    case unsupportedMessageType
    /// Protocol version doesn't match expected value, PROTOCOL_VERSION.
    /// This is likely a newer version of the protocol, that is unsupported.
    case unsupportedProtocolVersion
    /// Array value exceeds the maximum size
    case contentTooLarge
}
