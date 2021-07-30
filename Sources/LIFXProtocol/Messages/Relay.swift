///
///  Relay.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import ByteBuffer
import Foundation

public struct Relay {
    // MARK: - Types

    // MARK: - Payloads
    public struct GetPower: MessagePayload {
        public typealias Message = GetPowerMessage

        public let relayIndex: UInt8

        public static var size: Int { return 1 }

        public init(relayIndex: UInt8) { self.relayIndex = relayIndex }

        public static func from(data: Data) throws -> GetPower {
            guard data.count == GetPower.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let relayIndex = try buffer.readByte()
            return GetPower(relayIndex: relayIndex)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: GetPower.size)
            buffer.write(byte: relayIndex)
            return buffer.data
        }
    }
    public struct SetPower: MessagePayload {
        public typealias Message = SetPowerMessage

        public let relayIndex: UInt8
        /// Zero implies off and 0xFFFF is fully on. Everything between is currently
        /// undefined, but reserved for possible dimmer support.
        public let level: UInt16

        public static var size: Int { return 3 }

        public init(relayIndex: UInt8, level: UInt16) {
            self.relayIndex = relayIndex
            self.level = level
        }

        public static func from(data: Data) throws -> SetPower {
            guard data.count == SetPower.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let relayIndex = try buffer.readByte()
            let level = try buffer.readShort()
            return SetPower(relayIndex: relayIndex, level: level)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetPower.size)
            buffer.write(byte: relayIndex)
            buffer.write(short: level)
            return buffer.data
        }
    }
    public struct StatePower: MessagePayload {
        public typealias Message = StatePowerMessage

        public let relayIndex: UInt8
        /// Zero implies off and 0xFFFF is fully on. Everything between is currently
        /// undefined, but reserved for possible dimmer support.
        public let level: UInt16

        public static var size: Int { return 3 }

        public init(relayIndex: UInt8, level: UInt16) {
            self.relayIndex = relayIndex
            self.level = level
        }

        public static func from(data: Data) throws -> StatePower {
            guard data.count == StatePower.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let relayIndex = try buffer.readByte()
            let level = try buffer.readShort()
            return StatePower(relayIndex: relayIndex, level: level)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StatePower.size)
            buffer.write(byte: relayIndex)
            buffer.write(short: level)
            return buffer.data
        }
    }
    // MARK: - Messages

    /// RelayGetPower gets the power state for the relay
    public struct GetPowerMessage: PayloadMessageType {
        public typealias Payload = GetPower

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = StatePowerMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool {
            guard let msg = message as? GetPowerMessage, msg.payload.relayIndex == payload.relayIndex else {
                return false
            }
            return true
        }

        public static var messageType: MessageType { return .relayGetPower }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// RelaySetPower sets the power level of a relay
    public struct SetPowerMessage: PayloadMessageType {
        public typealias Payload = SetPower

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool {
            guard let msg = message as? SetPowerMessage, msg.payload.relayIndex == payload.relayIndex else {
                return false
            }
            return true
        }

        public static var messageType: MessageType { return .relaySetPower }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// RelayStatePower represents the power level of a relay
    public struct StatePowerMessage: PayloadMessageType {
        public typealias Payload = StatePower

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StatePowerMessage }

        public static var messageType: MessageType { return .relayStatePower }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
}
