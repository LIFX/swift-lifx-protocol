///
///  AcknowledgementMessagetype+Init.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 27/7/21

import Foundation

extension AcknowledgementMessageType {
    public init(
        source: UInt32 = 2,
        target: TargetType,
        resRequired: Bool = false,
        ackRequired: Bool = false,
        sequence: UInt8 = 0
    ) {
        let targetBytes: Data
        let tagged: Bool
        switch target {
        case .broadcast:
            tagged = true
            targetBytes = Header.broadcastTarget
        case .macAddress(let mac):
            tagged = false
            targetBytes = mac.bytes
        }
        do {
            let header = try Header(
                size: UInt16(Self.size),
                tagged: tagged,
                source: source,
                target: targetBytes,
                resRequired: resRequired,
                ackRequired: ackRequired,
                sequence: sequence,
                type: Self.messageType.rawValue
            )
            self.init(header: header)
        } catch let e { fatalError("Unexpected error handling target, TargetType should always be valid! \(e)") }
    }
}
