///
///  GenericMessageType.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

public protocol GenericMessageType: AbstractMessageType, DataDecodable {
    associatedtype ResponseType: AbstractMessageType
}

extension GenericMessageType {
    public func isResponse(_ message: AbstractMessageType) -> Bool {
        guard let msgTarget = message.header.targetType, let selfTarget = header.targetType,
            message.header.sequence == header.sequence && header.sequence != 0 && msgTarget == selfTarget
        else { return false }
        return message is ResponseType || message is Device.AcknowledgementMessage
    }
}
