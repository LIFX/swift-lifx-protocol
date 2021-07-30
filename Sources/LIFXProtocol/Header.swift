///
///  Header.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import ByteBuffer
import Foundation

public struct Header: DataCodable {
    enum Errors: Error { case invalidTarget }

    public let size: UInt16

    public let `protocol`: UInt16

    public let addressable: Bool

    public let tagged: Bool

    public let origin: UInt8

    public let reserved1: Data
    public static let reserved1Size = 2

    public let reserved2: Data
    public static let reserved2Size = 2

    public let target: Data
    public static let targetSize = 8

    public let reserved3: Data
    public static let reserved3Size = 6

    public let resRequired: Bool

    public let ackRequired: Bool

    public let reserved4: Data
    public static let reserved4Size = 1

    public let reserved5: Data
    public static let reserved5Size = 1

    public let sequence: UInt8

    public let reserved6: Data
    public static let reserved6Size = 8

    public let type: UInt16

    public let reserved7: Data
    public static let reserved7Size = 1

    public let reserved8: Data
    public static let reserved8Size = 1

    public init(
        size: UInt16,
        protocol: UInt16,
        addressable: Bool,
        tagged: Bool,
        origin: UInt8,
        reserved1: Data = Data(count: 2),
        reserved2: Data = Data(count: 2),
        target: Data,
        reserved3: Data = Data(count: 6),
        resRequired: Bool,
        ackRequired: Bool,
        reserved4: Data = Data(count: 1),
        reserved5: Data = Data(count: 1),
        sequence: UInt8,
        reserved6: Data = Data(count: 8),
        type: UInt16,
        reserved7: Data = Data(count: 1),
        reserved8: Data = Data(count: 1)
    ) throws {
        self.size = size
        self.`protocol` = `protocol`
        self.addressable = addressable
        self.tagged = tagged
        self.origin = origin
        guard reserved1.count <= Header.reserved1Size else { throw DeserializationErrors.contentTooLarge }
        self.reserved1 = reserved1
        guard reserved2.count <= Header.reserved2Size else { throw DeserializationErrors.contentTooLarge }
        self.reserved2 = reserved2
        guard target.count <= Header.targetSize else { throw DeserializationErrors.contentTooLarge }
        self.target = target
        guard reserved3.count <= Header.reserved3Size else { throw DeserializationErrors.contentTooLarge }
        self.reserved3 = reserved3
        self.resRequired = resRequired
        self.ackRequired = ackRequired
        guard reserved4.count <= Header.reserved4Size else { throw DeserializationErrors.contentTooLarge }
        self.reserved4 = reserved4
        guard reserved5.count <= Header.reserved5Size else { throw DeserializationErrors.contentTooLarge }
        self.reserved5 = reserved5
        self.sequence = sequence
        guard reserved6.count <= Header.reserved6Size else { throw DeserializationErrors.contentTooLarge }
        self.reserved6 = reserved6
        self.type = type
        guard reserved7.count <= Header.reserved7Size else { throw DeserializationErrors.contentTooLarge }
        self.reserved7 = reserved7
        guard reserved8.count <= Header.reserved8Size else { throw DeserializationErrors.contentTooLarge }
        self.reserved8 = reserved8
    }

    public static var size: Int { return 36 }

    public static func from(data: Data) throws -> Header {
        guard data.count == Header.size else { throw DeserializationErrors.insufficientBytes }

        var buffer = ByteBuffer(data: data)
        let size = try buffer.readShort()
        let `protocol` = try buffer.readShort(bits: 12)
        let addressable = try buffer.readBool(bits: 1)
        let tagged = try buffer.readBool(bits: 1)
        let origin = try buffer.readByte(bits: 2)
        let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
        let reserved2 = Data(try (0..<reserved2Size).map { _ in try buffer.readByte() })
        let target = Data(try (0..<targetSize).map { _ in try buffer.readByte() })
        let reserved3 = Data(try (0..<reserved3Size).map { _ in try buffer.readByte() })
        let resRequired = try buffer.readBool(bits: 1)
        let ackRequired = try buffer.readBool(bits: 1)
        let reserved4 = Data([try buffer.readByte(bits: 1)])
        let reserved5 = Data([try buffer.readByte(bits: 5)])
        let sequence = try buffer.readByte()
        let reserved6 = Data(try (0..<reserved6Size).map { _ in try buffer.readByte() })
        let type = try buffer.readShort()
        let reserved7 = Data(try (0..<reserved7Size).map { _ in try buffer.readByte() })
        let reserved8 = Data(try (0..<reserved8Size).map { _ in try buffer.readByte() })
        return try Header(
            size: size,
            protocol: `protocol`,
            addressable: addressable,
            tagged: tagged,
            origin: origin,
            reserved1: reserved1,
            reserved2: reserved2,
            target: target,
            reserved3: reserved3,
            resRequired: resRequired,
            ackRequired: ackRequired,
            reserved4: reserved4,
            reserved5: reserved5,
            sequence: sequence,
            reserved6: reserved6,
            type: type,
            reserved7: reserved7,
            reserved8: reserved8
        )
    }
    public func toData() -> Data {
        var buffer = ByteBuffer(capacity: Header.size)
        buffer.write(short: size)
        buffer.write(short: `protocol`, bits: 12)
        buffer.write(bool: addressable, bits: 1)
        buffer.write(bool: tagged, bits: 1)
        buffer.write(byte: origin, bits: 2)
        (0..<2).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
        (0..<2).forEach { buffer.write(byte: $0 < reserved2.count ? reserved2[$0] : 0x00) }
        (0..<8).forEach { buffer.write(byte: $0 < target.count ? target[$0] : 0x00) }
        (0..<6).forEach { buffer.write(byte: $0 < reserved3.count ? reserved3[$0] : 0x00) }
        buffer.write(bool: resRequired, bits: 1)
        buffer.write(bool: ackRequired, bits: 1)
        buffer.write(byte: reserved4[0], bits: 1)
        buffer.write(byte: reserved5[0], bits: 5)
        buffer.write(byte: sequence)
        (0..<8).forEach { buffer.write(byte: $0 < reserved6.count ? reserved6[$0] : 0x00) }
        buffer.write(short: type)
        (0..<1).forEach { buffer.write(byte: $0 < reserved7.count ? reserved7[$0] : 0x00) }
        (0..<1).forEach { buffer.write(byte: $0 < reserved8.count ? reserved8[$0] : 0x00) }
        return buffer.data
    }

}
