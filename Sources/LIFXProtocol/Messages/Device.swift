///
///  Device.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import ByteBuffer
import Foundation

public struct Device {
    // MARK: - Enums

    public enum Service: UInt8 { case udp = 1 }

    // MARK: - Types

    // MARK: - Payloads

    public struct StateService: MessagePayload {
        public typealias Message = StateServiceMessage

        public let service: LIFXProtocol.Device.Service
        /// A value of 0 indicates that the service is unavailable on this port.
        public let port: UInt32

        public static var size: Int { return 5 }

        public init(service: LIFXProtocol.Device.Service, port: UInt32) {
            self.service = service
            self.port = port
        }

        public static func from(data: Data) throws -> StateService {
            guard data.count == StateService.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            guard let service = LIFXProtocol.Device.Service(rawValue: try buffer.readByte()) else {
                throw DeserializationErrors.invalidEnumValue
            }
            let port = try buffer.readUInt32()
            return StateService(service: service, port: port)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateService.size)
            buffer.write(byte: service.rawValue)
            buffer.write(uint32: port)
            return buffer.data
        }
    }
    public struct StateHostFirmware: MessagePayload {
        public typealias Message = StateHostFirmwareMessage
        /// Encoded build time.
        public let build: UInt64

        public let reserved1: Data
        public static let reserved1Size = 8
        /// Firmware revision, minor component.
        public let versionMinor: UInt16
        /// Firmware revision, major component.
        public let versionMajor: UInt16

        public static var size: Int { return 20 }

        public init(build: UInt64, reserved1: Data = Data(count: 8), versionMinor: UInt16, versionMajor: UInt16) throws
        {
            self.build = build
            guard reserved1.count <= StateHostFirmware.reserved1Size else {
                throw DeserializationErrors.contentTooLarge
            }
            self.reserved1 = reserved1
            self.versionMinor = versionMinor
            self.versionMajor = versionMajor
        }

        public static func from(data: Data) throws -> StateHostFirmware {
            guard data.count == StateHostFirmware.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let build = try buffer.readUInt64()
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let versionMinor = try buffer.readShort()
            let versionMajor = try buffer.readShort()
            return try StateHostFirmware(
                build: build,
                reserved1: reserved1,
                versionMinor: versionMinor,
                versionMajor: versionMajor
            )
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateHostFirmware.size)
            buffer.write(uint64: build)
            (0..<8).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            buffer.write(short: versionMinor)
            buffer.write(short: versionMajor)
            return buffer.data
        }
    }
    public struct StateWifiInfo: MessagePayload {
        public typealias Message = StateWifiInfoMessage
        /// Depending on firmware either RSSI or SNR
        public let signal: Float

        public let reserved1: Data
        public static let reserved1Size = 4

        public let reserved2: Data
        public static let reserved2Size = 4

        public let reserved3: Data
        public static let reserved3Size = 2

        public static var size: Int { return 14 }

        public init(
            signal: Float,
            reserved1: Data = Data(count: 4),
            reserved2: Data = Data(count: 4),
            reserved3: Data = Data(count: 2)
        ) throws {
            self.signal = signal
            guard reserved1.count <= StateWifiInfo.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            guard reserved2.count <= StateWifiInfo.reserved2Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved2 = reserved2
            guard reserved3.count <= StateWifiInfo.reserved3Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved3 = reserved3
        }

        public static func from(data: Data) throws -> StateWifiInfo {
            guard data.count == StateWifiInfo.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let signal = Float(bitPattern: try buffer.readUInt32())
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let reserved2 = Data(try (0..<reserved2Size).map { _ in try buffer.readByte() })
            let reserved3 = Data(try (0..<reserved3Size).map { _ in try buffer.readByte() })
            return try StateWifiInfo(signal: signal, reserved1: reserved1, reserved2: reserved2, reserved3: reserved3)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateWifiInfo.size)
            ByteBuffer.toByteArray(signal).forEach { buffer.write(byte: $0) }
            (0..<4).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            (0..<4).forEach { buffer.write(byte: $0 < reserved2.count ? reserved2[$0] : 0x00) }
            (0..<2).forEach { buffer.write(byte: $0 < reserved3.count ? reserved3[$0] : 0x00) }
            return buffer.data
        }
    }
    public struct StateWifiFirmware: MessagePayload {
        public typealias Message = StateWifiFirmwareMessage

        public let build: UInt64

        public let reserved1: Data
        public static let reserved1Size = 8
        /// Firmware revision, minor component.
        public let versionMinor: UInt16
        /// Firmware revision, major component.
        public let versionMajor: UInt16

        public static var size: Int { return 20 }

        public init(build: UInt64, reserved1: Data = Data(count: 8), versionMinor: UInt16, versionMajor: UInt16) throws
        {
            self.build = build
            guard reserved1.count <= StateWifiFirmware.reserved1Size else {
                throw DeserializationErrors.contentTooLarge
            }
            self.reserved1 = reserved1
            self.versionMinor = versionMinor
            self.versionMajor = versionMajor
        }

        public static func from(data: Data) throws -> StateWifiFirmware {
            guard data.count == StateWifiFirmware.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let build = try buffer.readUInt64()
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let versionMinor = try buffer.readShort()
            let versionMajor = try buffer.readShort()
            return try StateWifiFirmware(
                build: build,
                reserved1: reserved1,
                versionMinor: versionMinor,
                versionMajor: versionMajor
            )
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateWifiFirmware.size)
            buffer.write(uint64: build)
            (0..<8).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            buffer.write(short: versionMinor)
            buffer.write(short: versionMajor)
            return buffer.data
        }
    }
    public struct SetPower: MessagePayload {
        public typealias Message = SetPowerMessage
        /// Zero implies standby and non-zero sets a corresponding power draw level on
        /// device. Currently only 0 and 0xFFFF are supported.
        public let level: UInt16

        public static var size: Int { return 2 }

        public init(level: UInt16) { self.level = level }

        public static func from(data: Data) throws -> SetPower {
            guard data.count == SetPower.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let level = try buffer.readShort()
            return SetPower(level: level)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetPower.size)
            buffer.write(short: level)
            return buffer.data
        }
    }
    public struct StatePower: MessagePayload {
        public typealias Message = StatePowerMessage

        public let level: UInt16

        public static var size: Int { return 2 }

        public init(level: UInt16) { self.level = level }

        public static func from(data: Data) throws -> StatePower {
            guard data.count == StatePower.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let level = try buffer.readShort()
            return StatePower(level: level)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StatePower.size)
            buffer.write(short: level)
            return buffer.data
        }
    }
    public struct SetLabel: MessagePayload {
        public typealias Message = SetLabelMessage
        /// Zero padded byte string.
        public let label: String
        public static let labelSize = 32

        public static var size: Int { return 32 }

        public init(label: String) throws {
            guard label.utf8.count <= SetLabel.labelSize else { throw DeserializationErrors.contentTooLarge }
            self.label = label
        }

        public static func from(data: Data) throws -> SetLabel {
            guard data.count == SetLabel.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            var bufferLabelNullReached = false
            let bufferLabel = try (0..<labelSize)
                .compactMap({ _ -> UInt8? in let byte = try buffer.readByte()
                    guard byte != 0x00 && !bufferLabelNullReached else {
                        bufferLabelNullReached = true
                        return nil
                    }
                    return byte
                })
            guard let label = String(bytes: bufferLabel, encoding: .utf8) else {
                throw DeserializationErrors.invalidString
            }
            return try SetLabel(label: label)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetLabel.size)
            let labelBytes: [UInt8] = Array(label.utf8)
            (0..<32).forEach { buffer.write(byte: $0 < labelBytes.count ? labelBytes[$0] : 0x00) }
            return buffer.data
        }
    }
    public struct StateLabel: MessagePayload {
        public typealias Message = StateLabelMessage

        public let label: String
        public static let labelSize = 32

        public static var size: Int { return 32 }

        public init(label: String) throws {
            guard label.utf8.count <= StateLabel.labelSize else { throw DeserializationErrors.contentTooLarge }
            self.label = label
        }

        public static func from(data: Data) throws -> StateLabel {
            guard data.count == StateLabel.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            var bufferLabelNullReached = false
            let bufferLabel = try (0..<labelSize)
                .compactMap({ _ -> UInt8? in let byte = try buffer.readByte()
                    guard byte != 0x00 && !bufferLabelNullReached else {
                        bufferLabelNullReached = true
                        return nil
                    }
                    return byte
                })
            guard let label = String(bytes: bufferLabel, encoding: .utf8) else {
                throw DeserializationErrors.invalidString
            }
            return try StateLabel(label: label)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateLabel.size)
            let labelBytes: [UInt8] = Array(label.utf8)
            (0..<32).forEach { buffer.write(byte: $0 < labelBytes.count ? labelBytes[$0] : 0x00) }
            return buffer.data
        }
    }
    public struct StateVersion: MessagePayload {
        public typealias Message = StateVersionMessage
        /// Vendor ID.
        public let vendor: UInt32
        /// Product ID.
        public let product: UInt32

        public let reserved1: Data
        public static let reserved1Size = 4

        public static var size: Int { return 12 }

        public init(vendor: UInt32, product: UInt32, reserved1: Data = Data(count: 4)) throws {
            self.vendor = vendor
            self.product = product
            guard reserved1.count <= StateVersion.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
        }

        public static func from(data: Data) throws -> StateVersion {
            guard data.count == StateVersion.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let vendor = try buffer.readUInt32()
            let product = try buffer.readUInt32()
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            return try StateVersion(vendor: vendor, product: product, reserved1: reserved1)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateVersion.size)
            buffer.write(uint32: vendor)
            buffer.write(uint32: product)
            (0..<4).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            return buffer.data
        }
    }
    public struct StateInfo: MessagePayload {
        public typealias Message = StateInfoMessage
        /// Time on device.
        public let time: UInt64
        /// Device uptime in nanoseconds since power on.
        public let uptime: UInt64
        /// Device poweroff time, accurate to 5s.
        public let downtime: UInt64

        public static var size: Int { return 24 }

        public init(time: UInt64, uptime: UInt64, downtime: UInt64) {
            self.time = time
            self.uptime = uptime
            self.downtime = downtime
        }

        public static func from(data: Data) throws -> StateInfo {
            guard data.count == StateInfo.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let time = try buffer.readUInt64()
            let uptime = try buffer.readUInt64()
            let downtime = try buffer.readUInt64()
            return StateInfo(time: time, uptime: uptime, downtime: downtime)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateInfo.size)
            buffer.write(uint64: time)
            buffer.write(uint64: uptime)
            buffer.write(uint64: downtime)
            return buffer.data
        }
    }
    public struct SetLocation: MessagePayload {
        public typealias Message = SetLocationMessage
        /// Opaque location identifier byte string.
        public let location: Data
        public static let locationSize = 16
        /// Zero padded byte string.
        public let label: String
        public static let labelSize = 32
        /// Nanoseconds since epoch.
        public let updatedAt: UInt64

        public static var size: Int { return 56 }

        public init(location: Data, label: String, updatedAt: UInt64) throws {
            guard location.count <= SetLocation.locationSize else { throw DeserializationErrors.contentTooLarge }
            self.location = location
            guard label.utf8.count <= SetLocation.labelSize else { throw DeserializationErrors.contentTooLarge }
            self.label = label
            self.updatedAt = updatedAt
        }

        public static func from(data: Data) throws -> SetLocation {
            guard data.count == SetLocation.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let location = Data(try (0..<locationSize).map { _ in try buffer.readByte() })
            var bufferLabelNullReached = false
            let bufferLabel = try (0..<labelSize)
                .compactMap({ _ -> UInt8? in let byte = try buffer.readByte()
                    guard byte != 0x00 && !bufferLabelNullReached else {
                        bufferLabelNullReached = true
                        return nil
                    }
                    return byte
                })
            guard let label = String(bytes: bufferLabel, encoding: .utf8) else {
                throw DeserializationErrors.invalidString
            }
            let updatedAt = try buffer.readUInt64()
            return try SetLocation(location: location, label: label, updatedAt: updatedAt)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetLocation.size)
            (0..<16).forEach { buffer.write(byte: $0 < location.count ? location[$0] : 0x00) }
            let labelBytes: [UInt8] = Array(label.utf8)
            (0..<32).forEach { buffer.write(byte: $0 < labelBytes.count ? labelBytes[$0] : 0x00) }
            buffer.write(uint64: updatedAt)
            return buffer.data
        }
    }
    public struct StateLocation: MessagePayload {
        public typealias Message = StateLocationMessage

        public let location: Data
        public static let locationSize = 16

        public let label: String
        public static let labelSize = 32
        /// Nanoseconds since epoch.
        public let updatedAt: UInt64

        public static var size: Int { return 56 }

        public init(location: Data, label: String, updatedAt: UInt64) throws {
            guard location.count <= StateLocation.locationSize else { throw DeserializationErrors.contentTooLarge }
            self.location = location
            guard label.utf8.count <= StateLocation.labelSize else { throw DeserializationErrors.contentTooLarge }
            self.label = label
            self.updatedAt = updatedAt
        }

        public static func from(data: Data) throws -> StateLocation {
            guard data.count == StateLocation.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let location = Data(try (0..<locationSize).map { _ in try buffer.readByte() })
            var bufferLabelNullReached = false
            let bufferLabel = try (0..<labelSize)
                .compactMap({ _ -> UInt8? in let byte = try buffer.readByte()
                    guard byte != 0x00 && !bufferLabelNullReached else {
                        bufferLabelNullReached = true
                        return nil
                    }
                    return byte
                })
            guard let label = String(bytes: bufferLabel, encoding: .utf8) else {
                throw DeserializationErrors.invalidString
            }
            let updatedAt = try buffer.readUInt64()
            return try StateLocation(location: location, label: label, updatedAt: updatedAt)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateLocation.size)
            (0..<16).forEach { buffer.write(byte: $0 < location.count ? location[$0] : 0x00) }
            let labelBytes: [UInt8] = Array(label.utf8)
            (0..<32).forEach { buffer.write(byte: $0 < labelBytes.count ? labelBytes[$0] : 0x00) }
            buffer.write(uint64: updatedAt)
            return buffer.data
        }
    }
    public struct SetGroup: MessagePayload {
        public typealias Message = SetGroupMessage
        /// Opaque group identifier byte string.
        public let group: Data
        public static let groupSize = 16
        /// Zero padded byte string.
        public let label: String
        public static let labelSize = 32
        /// Nanoseconds since epoch.
        public let updatedAt: UInt64

        public static var size: Int { return 56 }

        public init(group: Data, label: String, updatedAt: UInt64) throws {
            guard group.count <= SetGroup.groupSize else { throw DeserializationErrors.contentTooLarge }
            self.group = group
            guard label.utf8.count <= SetGroup.labelSize else { throw DeserializationErrors.contentTooLarge }
            self.label = label
            self.updatedAt = updatedAt
        }

        public static func from(data: Data) throws -> SetGroup {
            guard data.count == SetGroup.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let group = Data(try (0..<groupSize).map { _ in try buffer.readByte() })
            var bufferLabelNullReached = false
            let bufferLabel = try (0..<labelSize)
                .compactMap({ _ -> UInt8? in let byte = try buffer.readByte()
                    guard byte != 0x00 && !bufferLabelNullReached else {
                        bufferLabelNullReached = true
                        return nil
                    }
                    return byte
                })
            guard let label = String(bytes: bufferLabel, encoding: .utf8) else {
                throw DeserializationErrors.invalidString
            }
            let updatedAt = try buffer.readUInt64()
            return try SetGroup(group: group, label: label, updatedAt: updatedAt)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetGroup.size)
            (0..<16).forEach { buffer.write(byte: $0 < group.count ? group[$0] : 0x00) }
            let labelBytes: [UInt8] = Array(label.utf8)
            (0..<32).forEach { buffer.write(byte: $0 < labelBytes.count ? labelBytes[$0] : 0x00) }
            buffer.write(uint64: updatedAt)
            return buffer.data
        }
    }
    public struct StateGroup: MessagePayload {
        public typealias Message = StateGroupMessage

        public let group: Data
        public static let groupSize = 16

        public let label: String
        public static let labelSize = 32
        /// Nanoseconds since epoch.
        public let updatedAt: UInt64

        public static var size: Int { return 56 }

        public init(group: Data, label: String, updatedAt: UInt64) throws {
            guard group.count <= StateGroup.groupSize else { throw DeserializationErrors.contentTooLarge }
            self.group = group
            guard label.utf8.count <= StateGroup.labelSize else { throw DeserializationErrors.contentTooLarge }
            self.label = label
            self.updatedAt = updatedAt
        }

        public static func from(data: Data) throws -> StateGroup {
            guard data.count == StateGroup.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let group = Data(try (0..<groupSize).map { _ in try buffer.readByte() })
            var bufferLabelNullReached = false
            let bufferLabel = try (0..<labelSize)
                .compactMap({ _ -> UInt8? in let byte = try buffer.readByte()
                    guard byte != 0x00 && !bufferLabelNullReached else {
                        bufferLabelNullReached = true
                        return nil
                    }
                    return byte
                })
            guard let label = String(bytes: bufferLabel, encoding: .utf8) else {
                throw DeserializationErrors.invalidString
            }
            let updatedAt = try buffer.readUInt64()
            return try StateGroup(group: group, label: label, updatedAt: updatedAt)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateGroup.size)
            (0..<16).forEach { buffer.write(byte: $0 < group.count ? group[$0] : 0x00) }
            let labelBytes: [UInt8] = Array(label.utf8)
            (0..<32).forEach { buffer.write(byte: $0 < labelBytes.count ? labelBytes[$0] : 0x00) }
            buffer.write(uint64: updatedAt)
            return buffer.data
        }
    }
    public struct EchoRequest: MessagePayload {
        public typealias Message = EchoRequestMessage
        /// Opaque payload byte string to echo.
        public let payload: Data
        public static let payloadSize = 64

        public static var size: Int { return 64 }

        public init(payload: Data) throws {
            guard payload.count <= EchoRequest.payloadSize else { throw DeserializationErrors.contentTooLarge }
            self.payload = payload
        }

        public static func from(data: Data) throws -> EchoRequest {
            guard data.count == EchoRequest.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let payload = Data(try (0..<payloadSize).map { _ in try buffer.readByte() })
            return try EchoRequest(payload: payload)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: EchoRequest.size)
            (0..<64).forEach { buffer.write(byte: $0 < payload.count ? payload[$0] : 0x00) }
            return buffer.data
        }
    }
    public struct EchoResponse: MessagePayload {
        public typealias Message = EchoResponseMessage
        /// Opaque payload byte string being echoed.
        public let payload: Data
        public static let payloadSize = 64

        public static var size: Int { return 64 }

        public init(payload: Data) throws {
            guard payload.count <= EchoResponse.payloadSize else { throw DeserializationErrors.contentTooLarge }
            self.payload = payload
        }

        public static func from(data: Data) throws -> EchoResponse {
            guard data.count == EchoResponse.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let payload = Data(try (0..<payloadSize).map { _ in try buffer.readByte() })
            return try EchoResponse(payload: payload)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: EchoResponse.size)
            (0..<64).forEach { buffer.write(byte: $0 < payload.count ? payload[$0] : 0x00) }
            return buffer.data
        }
    }
    public struct StateUnhandled: MessagePayload {
        public typealias Message = StateUnhandledMessage
        /// The packet type that was un-handled
        /// This corresponds to the values in the Type enum
        /// but we're not representing it as that enum here in case we're responding to
        /// a message that doesn't exist
        public let unhandledType: UInt16

        public static var size: Int { return 2 }

        public init(unhandledType: UInt16) { self.unhandledType = unhandledType }

        public static func from(data: Data) throws -> StateUnhandled {
            guard data.count == StateUnhandled.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let unhandledType = try buffer.readShort()
            return StateUnhandled(unhandledType: unhandledType)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateUnhandled.size)
            buffer.write(short: unhandledType)
            return buffer.data
        }
    }
    // MARK: - Messages

    public struct GetServiceMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateServiceMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetServiceMessage }

        public static var messageType: MessageType { return .deviceGetService }

        public init(header: Header) { self.header = header }
    }
    /// DeviceStateService is the response from the gateway device for a site to
    /// advertise transports available. Since the gateway devices are resource
    /// constrained, they only support a small number of TCP connections. A response
    /// with port 0 indicates that the resources for establishing new TCP connections
    /// has been exhausted.
    public struct StateServiceMessage: PayloadMessageType {
        public typealias Payload = StateService

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateServiceMessage }

        public static var messageType: MessageType { return .deviceStateService }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetHostFirmwareMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateHostFirmwareMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetHostFirmwareMessage }

        public static var messageType: MessageType { return .deviceGetHostFirmware }

        public init(header: Header) { self.header = header }
    }
    /// DeviceStateHostFirmware describes the firmware information on Host MCU.
    public struct StateHostFirmwareMessage: PayloadMessageType {
        public typealias Payload = StateHostFirmware

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateHostFirmwareMessage }

        public static var messageType: MessageType { return .deviceStateHostFirmware }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetWifiInfoMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateWifiInfoMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetWifiInfoMessage }

        public static var messageType: MessageType { return .deviceGetWifiInfo }

        public init(header: Header) { self.header = header }
    }
    /// DeviceStateWifiInfo describes the WiFi MCU state.
    public struct StateWifiInfoMessage: PayloadMessageType {
        public typealias Payload = StateWifiInfo

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateWifiInfoMessage }

        public static var messageType: MessageType { return .deviceStateWifiInfo }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetWifiFirmwareMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateWifiFirmwareMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetWifiFirmwareMessage }

        public static var messageType: MessageType { return .deviceGetWifiFirmware }

        public init(header: Header) { self.header = header }
    }
    /// DeviceStateWifiFirmware describes the firmware information on WiFi MCU.
    public struct StateWifiFirmwareMessage: PayloadMessageType {
        public typealias Payload = StateWifiFirmware

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateWifiFirmwareMessage }

        public static var messageType: MessageType { return .deviceStateWifiFirmware }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetPowerMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StatePowerMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetPowerMessage }

        public static var messageType: MessageType { return .deviceGetPower }

        public init(header: Header) { self.header = header }
    }
    /// DeviceSetPower sets the power level of a device. This may put a device into
    /// standby mode.
    public struct SetPowerMessage: PayloadMessageType {
        public typealias Payload = SetPower

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetPowerMessage }

        public static var messageType: MessageType { return .deviceSetPower }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// DeviceStatePower describes power level on device.
    public struct StatePowerMessage: PayloadMessageType {
        public typealias Payload = StatePower

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StatePowerMessage }

        public static var messageType: MessageType { return .deviceStatePower }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetLabelMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateLabelMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetLabelMessage }

        public static var messageType: MessageType { return .deviceGetLabel }

        public init(header: Header) { self.header = header }
    }
    /// DeviceSetLabel sets the device label.
    public struct SetLabelMessage: PayloadMessageType {
        public typealias Payload = SetLabel

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetLabelMessage }

        public static var messageType: MessageType { return .deviceSetLabel }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// DeviceStateLabel contains the device label.
    public struct StateLabelMessage: PayloadMessageType {
        public typealias Payload = StateLabel

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateLabelMessage }

        public static var messageType: MessageType { return .deviceStateLabel }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetVersionMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateVersionMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetVersionMessage }

        public static var messageType: MessageType { return .deviceGetVersion }

        public init(header: Header) { self.header = header }
    }
    /// DeviceStateVersion constains the hardware version of the device.
    ///
    /// Note early versions of the firmware used the last 4 bytes of the this message
    /// inconsistently, but has since been changed to have specific meaning.
    public struct StateVersionMessage: PayloadMessageType {
        public typealias Payload = StateVersion

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateVersionMessage }

        public static var messageType: MessageType { return .deviceStateVersion }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetInfoMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateInfoMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetInfoMessage }

        public static var messageType: MessageType { return .deviceGetInfo }

        public init(header: Header) { self.header = header }
    }
    /// DeviceStateInfo contains runtime information of device. All values are in
    /// nanoseconds since epoch.
    public struct StateInfoMessage: PayloadMessageType {
        public typealias Payload = StateInfo

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateInfoMessage }

        public static var messageType: MessageType { return .deviceStateInfo }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct SetRebootMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetRebootMessage }

        public static var messageType: MessageType { return .deviceSetReboot }

        public init(header: Header) { self.header = header }
    }
    public struct AcknowledgementMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is AcknowledgementMessage }

        public static var messageType: MessageType { return .deviceAcknowledgement }

        public init(header: Header) { self.header = header }
    }
    public struct GetLocationMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateLocationMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetLocationMessage }

        public static var messageType: MessageType { return .deviceGetLocation }

        public init(header: Header) { self.header = header }
    }
    /// DeviceSetLocation sets the device location.
    public struct SetLocationMessage: PayloadMessageType {
        public typealias Payload = SetLocation

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetLocationMessage }

        public static var messageType: MessageType { return .deviceSetLocation }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// DeviceStateLocation contains device location information.
    public struct StateLocationMessage: PayloadMessageType {
        public typealias Payload = StateLocation

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateLocationMessage }

        public static var messageType: MessageType { return .deviceStateLocation }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetGroupMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateGroupMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetGroupMessage }

        public static var messageType: MessageType { return .deviceGetGroup }

        public init(header: Header) { self.header = header }
    }
    /// DeviceSetGroup sets the device group.
    public struct SetGroupMessage: PayloadMessageType {
        public typealias Payload = SetGroup

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetGroupMessage }

        public static var messageType: MessageType { return .deviceSetGroup }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// DeviceStateGroup contains device group information.
    public struct StateGroupMessage: PayloadMessageType {
        public typealias Payload = StateGroup

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateGroupMessage }

        public static var messageType: MessageType { return .deviceStateGroup }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// DeviceEchoRequest requests that a given arbitrary opaque payload be echoed
    /// back to the sender.
    public struct EchoRequestMessage: PayloadMessageType {
        public typealias Payload = EchoRequest

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is EchoRequestMessage }

        public static var messageType: MessageType { return .deviceEchoRequest }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// DeviceEchoResponse contains the arbitrary opaque payload that is echoed back
    /// to a sender that issued it via an DeviceEchoRequest message.
    public struct EchoResponseMessage: PayloadMessageType {
        public typealias Payload = EchoResponse

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is EchoResponseMessage }

        public static var messageType: MessageType { return .deviceEchoResponse }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// DeviceStateUnhandled is returned when the device doesn't know how to handle
    /// the message it received
    public struct StateUnhandledMessage: PayloadMessageType {
        public typealias Payload = StateUnhandled

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateUnhandledMessage }

        public static var messageType: MessageType { return .deviceStateUnhandled }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
}
