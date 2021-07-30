///
///  Header+Init.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 27/7/21

import ByteBuffer
import Foundation

extension Header {
    var source: UInt32 {
        do {
            var buffer = ByteBuffer(data: reserved1 + reserved2)
            return try buffer.readUInt32()
        } catch { return 0 }
    }
    public init(
        size: UInt16,
        addressable: Bool = true,
        tagged: Bool,
        source: UInt32 = 2,
        target: Data,
        resRequired: Bool,
        ackRequired: Bool,
        sequence: UInt8 = 0,
        type: UInt16
    ) throws {
        var buffer = ByteBuffer(capacity: 4)
        buffer.write(uint32: source)
        try self.init(
            size: size,
            protocol: protocolVersion,
            addressable: addressable,
            tagged: tagged,
            origin: 0,
            reserved1: Data(buffer.data[0...1]),
            reserved2: Data(buffer.data[2...3]),
            target: target,
            reserved3: Data(count: 6),
            resRequired: resRequired,
            ackRequired: ackRequired,
            reserved4: Data(count: 1),
            reserved5: Data(count: 1),
            sequence: sequence,
            reserved6: Data(count: 8),
            type: type,
            reserved7: Data(count: 1),
            reserved8: Data(count: 1)
        )
    }
}
