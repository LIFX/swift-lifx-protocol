///
///  AbstractMessageType.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

/// Common protocol for all message types. Simplest form of a message simply contains a header.
public protocol AbstractMessageType: FixedSizeElement, DataEncodable {
    var header: Header { get }
    static var messageType: MessageType { get }
    /// Message originated from a client (set or get)
    var isClientMessage: Bool { get }
    /// Message originated from a device (state message)
    var isDeviceMessage: Bool { get }
    /// Checks whether the given message is a response to this message. A response
    /// indicates that the response type matches and the sequence number is the same.
    /// If the message is a Device.AcknowledgementMessage, then only the sequence will
    /// be checked.
    ///
    /// return: Bool indicating whether the message is a response
    func isResponse(_ message: AbstractMessageType) -> Bool
    /// Checks whether the given message has the same effect as this message. i.e. if
    /// the client is about to send this message, the other message will no longer be
    /// relevant. For example, if you send a Light.SetColor message, sending a subsequent
    /// message of the same type overrides the previous value, and as such isMatch would
    /// return true.
    ///
    /// return: Bool indicating whether this message overrides the other
    func isMatch(_ message: AbstractMessageType) -> Bool
}
