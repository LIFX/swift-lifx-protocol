///
///  MultiZone.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import ByteBuffer
import Foundation

public struct MultiZone {
    // MARK: - Enums

    public enum ApplicationRequest: UInt8 {
        case noApply = 0
        case apply = 1
        case applyOnly = 2
    }

    public enum EffectType: UInt8 {
        case off = 0
        case move = 1
    }

    public enum ExtendedApplicationRequest: UInt8 {
        case noApply = 0
        case apply = 1
        case applyOnly = 2
    }

    // MARK: - Types

    public struct EffectParameter: DataCodable {

        public let parameter0: UInt32

        public let parameter1: UInt32

        public let parameter2: UInt32

        public let parameter3: UInt32

        public let parameter4: UInt32

        public let parameter5: UInt32

        public let parameter6: UInt32

        public let parameter7: UInt32

        public static var size: Int { return 32 }
        public init(
            parameter0: UInt32,
            parameter1: UInt32,
            parameter2: UInt32,
            parameter3: UInt32,
            parameter4: UInt32,
            parameter5: UInt32,
            parameter6: UInt32,
            parameter7: UInt32
        ) {
            self.parameter0 = parameter0
            self.parameter1 = parameter1
            self.parameter2 = parameter2
            self.parameter3 = parameter3
            self.parameter4 = parameter4
            self.parameter5 = parameter5
            self.parameter6 = parameter6
            self.parameter7 = parameter7
        }

        public static func from(data: Data) throws -> EffectParameter {
            guard data.count == EffectParameter.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let parameter0 = try buffer.readUInt32()
            let parameter1 = try buffer.readUInt32()
            let parameter2 = try buffer.readUInt32()
            let parameter3 = try buffer.readUInt32()
            let parameter4 = try buffer.readUInt32()
            let parameter5 = try buffer.readUInt32()
            let parameter6 = try buffer.readUInt32()
            let parameter7 = try buffer.readUInt32()
            return EffectParameter(
                parameter0: parameter0,
                parameter1: parameter1,
                parameter2: parameter2,
                parameter3: parameter3,
                parameter4: parameter4,
                parameter5: parameter5,
                parameter6: parameter6,
                parameter7: parameter7
            )
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: EffectParameter.size)
            buffer.write(uint32: parameter0)
            buffer.write(uint32: parameter1)
            buffer.write(uint32: parameter2)
            buffer.write(uint32: parameter3)
            buffer.write(uint32: parameter4)
            buffer.write(uint32: parameter5)
            buffer.write(uint32: parameter6)
            buffer.write(uint32: parameter7)
            return buffer.data
        }
    }

    public struct EffectSettings: DataCodable {
        /// Allows the remote controller or app to identify if the event is theirs.
        /// Usually via a random number generator.
        public let instanceid: UInt32
        /// Identifies effects type. Consult EffectType enum list for more details.
        public let type: LIFXProtocol.MultiZone.EffectType

        public let reserved1: Data
        public static let reserved1Size = 2
        /// Refers to speed of animation effect. If effect is cyclic then this value
        /// refers to milisecond period for a complete animation cycle to occour. Else
        /// if acyclic, then is the general miliseconds til next frame transition.
        public let speed: UInt32
        /// This field refers to how long the effects will go for before reverting back
        /// to user's default zone colours. In MultiZoneSetEffect, this would set a new
        /// duration limit. A MultiZoneStateEffect, would return the duration left.
        /// Duration is in nanoseconds.
        public let duration: UInt64

        public let reserved2: Data
        public static let reserved2Size = 4

        public let reserved3: Data
        public static let reserved3Size = 4
        /// Effect dependent meaning depends on the effect type.
        public let parameter: LIFXProtocol.MultiZone.EffectParameter

        public static var size: Int { return 59 }
        public init(
            instanceid: UInt32,
            type: LIFXProtocol.MultiZone.EffectType,
            reserved1: Data = Data(count: 2),
            speed: UInt32,
            duration: UInt64,
            reserved2: Data = Data(count: 4),
            reserved3: Data = Data(count: 4),
            parameter: LIFXProtocol.MultiZone.EffectParameter
        ) throws {
            self.instanceid = instanceid
            self.type = type
            guard reserved1.count <= EffectSettings.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            self.speed = speed
            self.duration = duration
            guard reserved2.count <= EffectSettings.reserved2Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved2 = reserved2
            guard reserved3.count <= EffectSettings.reserved3Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved3 = reserved3
            self.parameter = parameter
        }

        public static func from(data: Data) throws -> EffectSettings {
            guard data.count == EffectSettings.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let instanceid = try buffer.readUInt32()
            guard let type = LIFXProtocol.MultiZone.EffectType(rawValue: try buffer.readByte()) else {
                throw DeserializationErrors.invalidEnumValue
            }
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let speed = try buffer.readUInt32()
            let duration = try buffer.readUInt64()
            let reserved2 = Data(try (0..<reserved2Size).map { _ in try buffer.readByte() })
            let reserved3 = Data(try (0..<reserved3Size).map { _ in try buffer.readByte() })
            let parameterBytes = Data(try buffer.readBytes(LIFXProtocol.MultiZone.EffectParameter.size))
            let parameter = try LIFXProtocol.MultiZone.EffectParameter.from(data: parameterBytes)
            return try EffectSettings(
                instanceid: instanceid,
                type: type,
                reserved1: reserved1,
                speed: speed,
                duration: duration,
                reserved2: reserved2,
                reserved3: reserved3,
                parameter: parameter
            )
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: EffectSettings.size)
            buffer.write(uint32: instanceid)
            buffer.write(byte: type.rawValue)
            (0..<2).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            buffer.write(uint32: speed)
            buffer.write(uint64: duration)
            (0..<4).forEach { buffer.write(byte: $0 < reserved2.count ? reserved2[$0] : 0x00) }
            (0..<4).forEach { buffer.write(byte: $0 < reserved3.count ? reserved3[$0] : 0x00) }
            buffer.write(data: parameter.toData())
            return buffer.data
        }
    }

    // MARK: - Payloads
    public struct SetColorZones: MessagePayload {
        public typealias Message = SetColorZonesMessage

        public let startIndex: UInt8

        public let endIndex: UInt8

        public let color: LIFXProtocol.Light.HSBK
        /// Transition duration in milliseconds.
        public let duration: UInt32

        public let apply: LIFXProtocol.MultiZone.ApplicationRequest

        public static var size: Int { return 15 }

        public init(
            startIndex: UInt8,
            endIndex: UInt8,
            color: LIFXProtocol.Light.HSBK,
            duration: UInt32,
            apply: LIFXProtocol.MultiZone.ApplicationRequest
        ) {
            self.startIndex = startIndex
            self.endIndex = endIndex
            self.color = color
            self.duration = duration
            self.apply = apply
        }

        public static func from(data: Data) throws -> SetColorZones {
            guard data.count == SetColorZones.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let startIndex = try buffer.readByte()
            let endIndex = try buffer.readByte()
            let colorBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size))
            let duration = try buffer.readUInt32()
            guard let apply = LIFXProtocol.MultiZone.ApplicationRequest(rawValue: try buffer.readByte()) else {
                throw DeserializationErrors.invalidEnumValue
            }
            let color = try LIFXProtocol.Light.HSBK.from(data: colorBytes)
            return SetColorZones(
                startIndex: startIndex,
                endIndex: endIndex,
                color: color,
                duration: duration,
                apply: apply
            )
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetColorZones.size)
            buffer.write(byte: startIndex)
            buffer.write(byte: endIndex)
            buffer.write(data: color.toData())
            buffer.write(uint32: duration)
            buffer.write(byte: apply.rawValue)
            return buffer.data
        }
    }
    public struct GetColorZones: MessagePayload {
        public typealias Message = GetColorZonesMessage

        public let startIndex: UInt8

        public let endIndex: UInt8

        public static var size: Int { return 2 }

        public init(startIndex: UInt8, endIndex: UInt8) {
            self.startIndex = startIndex
            self.endIndex = endIndex
        }

        public static func from(data: Data) throws -> GetColorZones {
            guard data.count == GetColorZones.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let startIndex = try buffer.readByte()
            let endIndex = try buffer.readByte()
            return GetColorZones(startIndex: startIndex, endIndex: endIndex)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: GetColorZones.size)
            buffer.write(byte: startIndex)
            buffer.write(byte: endIndex)
            return buffer.data
        }
    }
    public struct StateZone: MessagePayload {
        public typealias Message = StateZoneMessage
        /// Total zone count.
        public let count: UInt8
        /// Index of the given zone.
        public let index: UInt8

        public let color: LIFXProtocol.Light.HSBK

        public static var size: Int { return 10 }

        public init(count: UInt8, index: UInt8, color: LIFXProtocol.Light.HSBK) {
            self.count = count
            self.index = index
            self.color = color
        }

        public static func from(data: Data) throws -> StateZone {
            guard data.count == StateZone.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let count = try buffer.readByte()
            let index = try buffer.readByte()
            let colorBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size))
            let color = try LIFXProtocol.Light.HSBK.from(data: colorBytes)
            return StateZone(count: count, index: index, color: color)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateZone.size)
            buffer.write(byte: count)
            buffer.write(byte: index)
            buffer.write(data: color.toData())
            return buffer.data
        }
    }
    public struct StateMultiZone: MessagePayload {
        public typealias Message = StateMultiZoneMessage
        /// Total zone count
        public let count: UInt8

        public let index: UInt8

        public let colors: [LIFXProtocol.Light.HSBK]
        public static let colorsSize = 8

        public static var size: Int { return 66 }

        public init(count: UInt8, index: UInt8, colors: [LIFXProtocol.Light.HSBK]) throws {
            self.count = count
            self.index = index
            guard colors.count <= StateMultiZone.colorsSize else { throw DeserializationErrors.contentTooLarge }
            self.colors = colors
        }

        public static func from(data: Data) throws -> StateMultiZone {
            guard data.count == StateMultiZone.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let count = try buffer.readByte()
            let index = try buffer.readByte()
            let colorsBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size * colorsSize))
            let colors = (0..<8)
                .compactMap { i -> LIFXProtocol.Light.HSBK? in
                    do {
                        let dataOffset = LIFXProtocol.Light.HSBK.size * Int(i)
                        let bytes = colorsBytes.subdata(in: dataOffset..<(dataOffset + LIFXProtocol.Light.HSBK.size))
                        return try LIFXProtocol.Light.HSBK.from(data: bytes)
                    } catch { return nil }
                }
            return try StateMultiZone(count: count, index: index, colors: colors)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateMultiZone.size)
            buffer.write(byte: count)
            buffer.write(byte: index)
            (0..<8)
                .forEach {
                    if $0 < colors.count {
                        buffer.write(data: colors[$0].toData())
                    } else {
                        (0..<LIFXProtocol.Light.HSBK.size).forEach { _ in buffer.write(byte: 0x00) }
                    }
                }
            return buffer.data
        }
    }
    public struct SetEffect: MessagePayload {
        public typealias Message = SetEffectMessage

        public let settings: LIFXProtocol.MultiZone.EffectSettings

        public static var size: Int { return 59 }

        public init(settings: LIFXProtocol.MultiZone.EffectSettings) { self.settings = settings }

        public static func from(data: Data) throws -> SetEffect {
            guard data.count == SetEffect.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let settingsBytes = Data(try buffer.readBytes(LIFXProtocol.MultiZone.EffectSettings.size))
            let settings = try LIFXProtocol.MultiZone.EffectSettings.from(data: settingsBytes)
            return SetEffect(settings: settings)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetEffect.size)
            buffer.write(data: settings.toData())
            return buffer.data
        }
    }
    public struct StateEffect: MessagePayload {
        public typealias Message = StateEffectMessage

        public let settings: LIFXProtocol.MultiZone.EffectSettings

        public static var size: Int { return 59 }

        public init(settings: LIFXProtocol.MultiZone.EffectSettings) { self.settings = settings }

        public static func from(data: Data) throws -> StateEffect {
            guard data.count == StateEffect.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let settingsBytes = Data(try buffer.readBytes(LIFXProtocol.MultiZone.EffectSettings.size))
            let settings = try LIFXProtocol.MultiZone.EffectSettings.from(data: settingsBytes)
            return StateEffect(settings: settings)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateEffect.size)
            buffer.write(data: settings.toData())
            return buffer.data
        }
    }
    public struct ExtendedSetColorZones: MessagePayload {
        public typealias Message = ExtendedSetColorZonesMessage
        /// Duration in milliseconds.
        public let duration: UInt32
        /// Indicate whether apply changes immediately
        public let apply: LIFXProtocol.MultiZone.ExtendedApplicationRequest
        /// Indicates the first zone that the changes in this message must be applied
        /// to.  The zone index starts at 0 and ends at number of zones - 1. The Colors
        /// array entry 0, is applied to zones from index onwards.
        public let index: UInt16
        /// The total number of zone changes from index to the last entry in the
        /// message that contains a HSBK change.
        public let colorsCount: UInt8
        /// HSBK color value for each zone, HSBK values of (0,0,0,0) will be ignored.
        public let colors: [LIFXProtocol.Light.HSBK]
        public static let colorsSize = 82

        public static var size: Int { return 664 }

        public init(
            duration: UInt32,
            apply: LIFXProtocol.MultiZone.ExtendedApplicationRequest,
            index: UInt16,
            colors: [LIFXProtocol.Light.HSBK]
        ) throws {
            self.duration = duration
            self.apply = apply
            self.index = index
            guard colors.count <= ExtendedSetColorZones.colorsSize else { throw DeserializationErrors.contentTooLarge }
            self.colors = colors
            self.colorsCount = UInt8(colors.count)
        }

        public static func from(data: Data) throws -> ExtendedSetColorZones {
            guard data.count == ExtendedSetColorZones.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let duration = try buffer.readUInt32()
            guard let apply = LIFXProtocol.MultiZone.ExtendedApplicationRequest(rawValue: try buffer.readByte()) else {
                throw DeserializationErrors.invalidEnumValue
            }
            let index = try buffer.readShort()
            // Ignored count field
            _ = try buffer.readByte()
            let colorsBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size * colorsSize))
            let colors = (0..<82)
                .compactMap { i -> LIFXProtocol.Light.HSBK? in
                    do {
                        let dataOffset = LIFXProtocol.Light.HSBK.size * Int(i)
                        let bytes = colorsBytes.subdata(in: dataOffset..<(dataOffset + LIFXProtocol.Light.HSBK.size))
                        return try LIFXProtocol.Light.HSBK.from(data: bytes)
                    } catch { return nil }
                }
            return try ExtendedSetColorZones(duration: duration, apply: apply, index: index, colors: colors)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: ExtendedSetColorZones.size)
            buffer.write(uint32: duration)
            buffer.write(byte: apply.rawValue)
            buffer.write(short: index)
            buffer.write(byte: colorsCount)
            (0..<82)
                .forEach {
                    if $0 < colors.count {
                        buffer.write(data: colors[$0].toData())
                    } else {
                        (0..<LIFXProtocol.Light.HSBK.size).forEach { _ in buffer.write(byte: 0x00) }
                    }
                }
            return buffer.data
        }
    }
    public struct ExtendedStateMultiZone: MessagePayload {
        public typealias Message = ExtendedStateMultiZoneMessage
        /// Total count of connected zones the device has.
        public let count: UInt16
        /// The index of the zone that the data in this message starts from.
        public let index: UInt16
        /// The total number of entries in the Colors array that have changed,
        /// (non-zero) HSBK values.
        public let colorsCount: UInt8
        /// HSBK color value for each zone, unused zones will be set to zero, HSBK
        /// (0,0,0,0).
        public let colors: [LIFXProtocol.Light.HSBK]
        public static let colorsSize = 82

        public static var size: Int { return 661 }

        public init(count: UInt16, index: UInt16, colors: [LIFXProtocol.Light.HSBK]) throws {
            self.count = count
            self.index = index
            guard colors.count <= ExtendedStateMultiZone.colorsSize else { throw DeserializationErrors.contentTooLarge }
            self.colors = colors
            self.colorsCount = UInt8(colors.count)
        }

        public static func from(data: Data) throws -> ExtendedStateMultiZone {
            guard data.count == ExtendedStateMultiZone.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let count = try buffer.readShort()
            let index = try buffer.readShort()
            // Ignored count field
            _ = try buffer.readByte()
            let colorsBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size * colorsSize))
            let colors = (0..<82)
                .compactMap { i -> LIFXProtocol.Light.HSBK? in
                    do {
                        let dataOffset = LIFXProtocol.Light.HSBK.size * Int(i)
                        let bytes = colorsBytes.subdata(in: dataOffset..<(dataOffset + LIFXProtocol.Light.HSBK.size))
                        return try LIFXProtocol.Light.HSBK.from(data: bytes)
                    } catch { return nil }
                }
            return try ExtendedStateMultiZone(count: count, index: index, colors: colors)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: ExtendedStateMultiZone.size)
            buffer.write(short: count)
            buffer.write(short: index)
            buffer.write(byte: colorsCount)
            (0..<82)
                .forEach {
                    if $0 < colors.count {
                        buffer.write(data: colors[$0].toData())
                    } else {
                        (0..<LIFXProtocol.Light.HSBK.size).forEach { _ in buffer.write(byte: 0x00) }
                    }
                }
            return buffer.data
        }
    }
    // MARK: - Messages

    /// MultiZoneSetColorZones allows you to set the color of a particular zone
    /// range. Changes are stored but not applied until a message with the flag set
    /// to APPLY arrives. When it does all pending changes are applied at once. The
    /// APPLY_ONLY flag tells the bulb to ignore the index, HSBK and duration flags
    /// of this message and to instead just apply all pending changes immediately.
    /// This allows the developer to perform ad-hoc single changes to single zones by
    /// setting APPLY on every message or update the entire sections of the strip in
    /// one atomic operation by sending all the colors required, and sending the
    /// final message with the APPLY flag set.
    public struct SetColorZonesMessage: PayloadMessageType {
        public typealias Payload = SetColorZones

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool {
            guard let msg = message as? SetColorZonesMessage,
                msg.payload.startIndex == payload.startIndex && msg.payload.endIndex == payload.endIndex
            else { return false }
            return true
        }

        public static var messageType: MessageType { return .multiZoneSetColorZones }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// MultiZoneGetColorZones is used to get the color of a zone range. The colors
    /// of each zone can be fetched on a per-zone basis by setting a GET_SINGLE,
    /// which will result in a single StateZone message from the Zone Index specified
    /// in index. Alternatively a developer can fetch the entire zone state setting
    /// flags to GET_ALL, which will result in a single response for each available
    /// zone, in this mode the index field is ignored.
    public struct GetColorZonesMessage: PayloadMessageType {
        public typealias Payload = GetColorZones

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = StateMultiZoneMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool {
            guard let msg = message as? GetColorZonesMessage,
                msg.payload.startIndex == payload.startIndex && msg.payload.endIndex == payload.endIndex
            else { return false }
            return true
        }

        public static var messageType: MessageType { return .multiZoneGetColorZones }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// MultiZoneStateZone contains the state of a particular Zone.
    public struct StateZoneMessage: PayloadMessageType {
        public typealias Payload = StateZone

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateZoneMessage }

        public static var messageType: MessageType { return .multiZoneStateZone }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// MultiZoneStateMultiZone represents the state of a particular 8 zone range.
    public struct StateMultiZoneMessage: PayloadMessageType {
        public typealias Payload = StateMultiZone

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateMultiZoneMessage }

        public static var messageType: MessageType { return .multiZoneStateMultiZone }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetEffectMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateEffectMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetEffectMessage }

        public static var messageType: MessageType { return .multiZoneGetEffect }

        public init(header: Header) { self.header = header }
    }
    /// MultiZoneSetEffect allows for configuring and setting a new effect.
    /// If a StateEffect response is requested, a StateEffect message will be sent to
    /// the requester with a copy of the last effect state. This would allow the app
    /// to reload the previous effect if the user wants to revert to a previous
    /// effect.
    public struct SetEffectMessage: PayloadMessageType {
        public typealias Payload = SetEffect

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetEffectMessage }

        public static var messageType: MessageType { return .multiZoneSetEffect }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// MultiZoneStateEffect reports back to the requester the current effect status
    /// to the user.
    public struct StateEffectMessage: PayloadMessageType {
        public typealias Payload = StateEffect

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateEffectMessage }

        public static var messageType: MessageType { return .multiZoneStateEffect }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// MultiZoneExtendedSetColorZones allows you to set the color of 82 zones for a
    /// device (Silver/Beam) at a time, (i.e. in one message) Changes are stored but
    /// not applied until a message with the flag set to APPLY arrives. When it does
    /// all pending changes are applied at once. The APPLY_ONLY flag tells the device
    /// to ignore the index, HSBK and duration flags of this message and to instead
    /// just apply all pending changes immediately.  This allows the developer to
    /// perform ad-hoc single changes to single zones by setting APPLY on every
    /// message or update the entire sections of the strip in one atomic operation by
    /// sending all the colors required, and sending the final message with the APPLY
    /// flag set.
    public struct ExtendedSetColorZonesMessage: PayloadMessageType {
        public typealias Payload = ExtendedSetColorZones

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool {
            guard let msg = message as? ExtendedSetColorZonesMessage,
                msg.payload.index == payload.index && msg.payload.colorsCount == payload.colorsCount
            else { return false }
            return true
        }

        public static var messageType: MessageType { return .multiZoneExtendedSetColorZones }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct ExtendedGetColorZonesMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = ExtendedStateMultiZoneMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is ExtendedGetColorZonesMessage }

        public static var messageType: MessageType { return .multiZoneExtendedGetColorZones }

        public init(header: Header) { self.header = header }
    }
    /// MultiZoneExtendedStateMultiZone represents the state of device zones and is
    /// sent in response to the ExtendedSetColorZones message and
    /// ExtendedGetColorZones message.  The device will reply with enough
    /// ExtendedStateMultiZone messages to report the state of all its zones where it
    /// has more than 82 zones.
    public struct ExtendedStateMultiZoneMessage: PayloadMessageType {
        public typealias Payload = ExtendedStateMultiZone

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is ExtendedStateMultiZoneMessage }

        public static var messageType: MessageType { return .multiZoneExtendedStateMultiZone }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
}
