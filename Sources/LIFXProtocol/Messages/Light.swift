///
///  Light.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import ByteBuffer
import Foundation

public struct Light {
    // MARK: - Enums

    public enum Waveform: UInt8 {
        case saw = 0
        case sine = 1
        case halfSine = 2
        case triangle = 3
        case pulse = 4
    }

    public enum LastHEVCycleResult: UInt8 {
        case lightLastHevCycleResultSuccess = 0
        case lightLastHevCycleResultBusy = 1
        case lightLastHevCycleResultInterruptedByReset = 2
        case lightLastHevCycleResultInterruptedByHomekit = 3
        case lightLastHevCycleResultInterruptedByLan = 4
        case lightLastHevCycleResultInterruptedByCloud = 5
        case lightLastHevCycleResultNone = 255
    }

    // MARK: - Types

    public struct HSBK: DataCodable {
        /// Hue values between 0 and 65535 scaled to 0° to 360°.
        public let hue: UInt16
        /// Saturation values between 0 and 65535 scaled to 0% to 100%.
        public let saturation: UInt16
        /// Brightness values between 0 and 65535 scaled to 0% to 100%.
        public let brightness: UInt16
        /// Kelvin values between 2500 to 9000.
        public let kelvin: UInt16

        public static var size: Int { return 8 }
        public enum Errors: Error { case invalidColor }

        public init(hue: UInt16 = 0, saturation: UInt16 = 0, brightness: UInt16 = 0, kelvin: UInt16 = 0) throws {
            guard kelvin <= 9000 && kelvin >= 1500 else { throw Errors.invalidColor }
            self.hue = hue
            self.saturation = saturation
            self.brightness = brightness
            self.kelvin = kelvin
        }
        public static func from(data: Data) throws -> HSBK {
            guard data.count == HSBK.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let hue = try buffer.readShort()
            let saturation = try buffer.readShort()
            let brightness = try buffer.readShort()
            let kelvin = try buffer.readShort()
            return try HSBK(hue: hue, saturation: saturation, brightness: brightness, kelvin: kelvin)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: HSBK.size)
            buffer.write(short: hue)
            buffer.write(short: saturation)
            buffer.write(short: brightness)
            buffer.write(short: kelvin)
            return buffer.data
        }
    }

    // MARK: - Payloads

    public struct SetColor: MessagePayload {
        public typealias Message = SetColorMessage

        public let reserved1: Data
        public static let reserved1Size = 1

        public let color: LIFXProtocol.Light.HSBK
        /// Transition time in milliseconds.
        public let duration: UInt32

        public static var size: Int { return 13 }

        public init(reserved1: Data = Data(count: 1), color: LIFXProtocol.Light.HSBK, duration: UInt32) throws {
            guard reserved1.count <= SetColor.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            self.color = color
            self.duration = duration
        }

        public static func from(data: Data) throws -> SetColor {
            guard data.count == SetColor.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let colorBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size))
            let duration = try buffer.readUInt32()
            let color = try LIFXProtocol.Light.HSBK.from(data: colorBytes)
            return try SetColor(reserved1: reserved1, color: color, duration: duration)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetColor.size)
            (0..<1).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            buffer.write(data: color.toData())
            buffer.write(uint32: duration)
            return buffer.data
        }
    }
    public struct SetWaveformOptional: MessagePayload {
        public typealias Message = SetWaveformOptionalMessage

        public let reserved1: Data
        public static let reserved1Size = 1
        /// True when the color does not persist.
        public let transient: Bool
        /// Light final color.
        public let color: LIFXProtocol.Light.HSBK
        /// Duration of a cycle in milliseconds.
        public let period: UInt32
        /// Number of cycles.
        public let cycles: Float
        /// Waveform skew in [-32768, 32767] scaled to [0, 1].
        public let skewRatio: Int16
        /// Waveform to use for transition.
        public let waveform: LIFXProtocol.Light.Waveform
        /// Whether to set the hue, 0 or 1.
        public let setHue: Bool
        /// Whether to set the saturation, 0 or 1.
        public let setSaturation: Bool
        /// Whether to set the brightness, 0 or 1.
        public let setBrightness: Bool
        /// Whether to set the kelvin, 0 or 1.
        public let setKelvin: Bool

        public static var size: Int { return 25 }

        public init(
            reserved1: Data = Data(count: 1),
            transient: Bool,
            color: LIFXProtocol.Light.HSBK,
            period: UInt32,
            cycles: Float,
            skewRatio: Int16,
            waveform: LIFXProtocol.Light.Waveform,
            setHue: Bool,
            setSaturation: Bool,
            setBrightness: Bool,
            setKelvin: Bool
        ) throws {
            guard reserved1.count <= SetWaveformOptional.reserved1Size else {
                throw DeserializationErrors.contentTooLarge
            }
            self.reserved1 = reserved1
            self.transient = transient
            self.color = color
            self.period = period
            self.cycles = cycles
            self.skewRatio = skewRatio
            self.waveform = waveform
            self.setHue = setHue
            self.setSaturation = setSaturation
            self.setBrightness = setBrightness
            self.setKelvin = setKelvin
        }

        public static func from(data: Data) throws -> SetWaveformOptional {
            guard data.count == SetWaveformOptional.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let transient = try buffer.readBool()
            let colorBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size))
            let period = try buffer.readUInt32()
            let cycles = Float(bitPattern: try buffer.readUInt32())
            let skewRatio = Int16(bitPattern: try buffer.readShort())
            guard let waveform = LIFXProtocol.Light.Waveform(rawValue: try buffer.readByte()) else {
                throw DeserializationErrors.invalidEnumValue
            }
            let setHue = try buffer.readBool()
            let setSaturation = try buffer.readBool()
            let setBrightness = try buffer.readBool()
            let setKelvin = try buffer.readBool()
            let color = try LIFXProtocol.Light.HSBK.from(data: colorBytes)
            return try SetWaveformOptional(
                reserved1: reserved1,
                transient: transient,
                color: color,
                period: period,
                cycles: cycles,
                skewRatio: skewRatio,
                waveform: waveform,
                setHue: setHue,
                setSaturation: setSaturation,
                setBrightness: setBrightness,
                setKelvin: setKelvin
            )
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetWaveformOptional.size)
            (0..<1).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            buffer.write(bool: transient)
            buffer.write(data: color.toData())
            buffer.write(uint32: period)
            ByteBuffer.toByteArray(cycles).forEach { buffer.write(byte: $0) }
            buffer.write(short: UInt16(bitPattern: skewRatio))
            buffer.write(byte: waveform.rawValue)
            buffer.write(bool: setHue)
            buffer.write(bool: setSaturation)
            buffer.write(bool: setBrightness)
            buffer.write(bool: setKelvin)
            return buffer.data
        }
    }
    public struct SetWaveform: MessagePayload {
        public typealias Message = SetWaveformMessage

        public let reserved1: Data
        public static let reserved1Size = 1
        /// True when the color does not persist.
        public let transient: Bool
        /// Light final color.
        public let color: LIFXProtocol.Light.HSBK
        /// Duration of a cycle in milliseconds.
        public let period: UInt32
        /// Number of cycles.
        public let cycles: Float
        /// Waveform skew in [-32768, 32767] scaled to [0, 1].
        public let skewRatio: Int16
        /// Waveform to use for transition.
        public let waveform: LIFXProtocol.Light.Waveform

        public static var size: Int { return 21 }

        public init(
            reserved1: Data = Data(count: 1),
            transient: Bool,
            color: LIFXProtocol.Light.HSBK,
            period: UInt32,
            cycles: Float,
            skewRatio: Int16,
            waveform: LIFXProtocol.Light.Waveform
        ) throws {
            guard reserved1.count <= SetWaveform.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            self.transient = transient
            self.color = color
            self.period = period
            self.cycles = cycles
            self.skewRatio = skewRatio
            self.waveform = waveform
        }

        public static func from(data: Data) throws -> SetWaveform {
            guard data.count == SetWaveform.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let transient = try buffer.readBool()
            let colorBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size))
            let period = try buffer.readUInt32()
            let cycles = Float(bitPattern: try buffer.readUInt32())
            let skewRatio = Int16(bitPattern: try buffer.readShort())
            guard let waveform = LIFXProtocol.Light.Waveform(rawValue: try buffer.readByte()) else {
                throw DeserializationErrors.invalidEnumValue
            }
            let color = try LIFXProtocol.Light.HSBK.from(data: colorBytes)
            return try SetWaveform(
                reserved1: reserved1,
                transient: transient,
                color: color,
                period: period,
                cycles: cycles,
                skewRatio: skewRatio,
                waveform: waveform
            )
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetWaveform.size)
            (0..<1).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            buffer.write(bool: transient)
            buffer.write(data: color.toData())
            buffer.write(uint32: period)
            ByteBuffer.toByteArray(cycles).forEach { buffer.write(byte: $0) }
            buffer.write(short: UInt16(bitPattern: skewRatio))
            buffer.write(byte: waveform.rawValue)
            return buffer.data
        }
    }
    public struct SetPower: MessagePayload {
        public typealias Message = SetPowerMessage
        /// Power level, either 0 (standby) or 65535 (on).
        public let level: UInt16
        /// Duration in milliseconds for the transition.
        public let duration: UInt32

        public static var size: Int { return 6 }

        public init(level: UInt16, duration: UInt32) {
            self.level = level
            self.duration = duration
        }

        public static func from(data: Data) throws -> SetPower {
            guard data.count == SetPower.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let level = try buffer.readShort()
            let duration = try buffer.readUInt32()
            return SetPower(level: level, duration: duration)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetPower.size)
            buffer.write(short: level)
            buffer.write(uint32: duration)
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
    public struct State: MessagePayload {
        public typealias Message = StateMessage

        public let color: LIFXProtocol.Light.HSBK

        public let reserved1: Data
        public static let reserved1Size = 2

        public let power: UInt16

        public let label: String
        public static let labelSize = 32

        public let reserved2: Data
        public static let reserved2Size = 8

        public static var size: Int { return 52 }

        public init(
            color: LIFXProtocol.Light.HSBK,
            reserved1: Data = Data(count: 2),
            power: UInt16,
            label: String,
            reserved2: Data = Data(count: 8)
        ) throws {
            self.color = color
            guard reserved1.count <= State.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            self.power = power
            guard label.utf8.count <= State.labelSize else { throw DeserializationErrors.contentTooLarge }
            self.label = label
            guard reserved2.count <= State.reserved2Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved2 = reserved2
        }

        public static func from(data: Data) throws -> State {
            guard data.count == State.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let colorBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size))
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let power = try buffer.readShort()
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
            let reserved2 = Data(try (0..<reserved2Size).map { _ in try buffer.readByte() })
            let color = try LIFXProtocol.Light.HSBK.from(data: colorBytes)
            return try State(color: color, reserved1: reserved1, power: power, label: label, reserved2: reserved2)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: State.size)
            buffer.write(data: color.toData())
            (0..<2).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            buffer.write(short: power)
            let labelBytes: [UInt8] = Array(label.utf8)
            (0..<32).forEach { buffer.write(byte: $0 < labelBytes.count ? labelBytes[$0] : 0x00) }
            (0..<8).forEach { buffer.write(byte: $0 < reserved2.count ? reserved2[$0] : 0x00) }
            return buffer.data
        }
    }
    public struct StateInfrared: MessagePayload {
        public typealias Message = StateInfraredMessage
        /// Brightness values between 0 and 65535 scaled to 0% to 100%.
        public let brightness: UInt16

        public static var size: Int { return 2 }

        public init(brightness: UInt16) { self.brightness = brightness }

        public static func from(data: Data) throws -> StateInfrared {
            guard data.count == StateInfrared.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let brightness = try buffer.readShort()
            return StateInfrared(brightness: brightness)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateInfrared.size)
            buffer.write(short: brightness)
            return buffer.data
        }
    }
    public struct SetInfrared: MessagePayload {
        public typealias Message = SetInfraredMessage
        /// Brightness values between 0 and 65535 scaled to 0% to 100%.
        public let brightness: UInt16

        public static var size: Int { return 2 }

        public init(brightness: UInt16) { self.brightness = brightness }

        public static func from(data: Data) throws -> SetInfrared {
            guard data.count == SetInfrared.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let brightness = try buffer.readShort()
            return SetInfrared(brightness: brightness)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetInfrared.size)
            buffer.write(short: brightness)
            return buffer.data
        }
    }
    public struct SetHEVCycle: MessagePayload {
        public typealias Message = SetHEVCycleMessage
        /// Whether to start new a HEV cycle or stop a HEV cycle in progress, 0 or 1.
        public let enable: Bool
        /// Duration of the HEV cycle in seconds.
        /// If duration is zero, the bulb will use a default HEV cycle duration.
        public let durationS: UInt32

        public static var size: Int { return 5 }

        public init(enable: Bool, durationS: UInt32) {
            self.enable = enable
            self.durationS = durationS
        }

        public static func from(data: Data) throws -> SetHEVCycle {
            guard data.count == SetHEVCycle.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let enable = try buffer.readBool()
            let durationS = try buffer.readUInt32()
            return SetHEVCycle(enable: enable, durationS: durationS)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetHEVCycle.size)
            buffer.write(bool: enable)
            buffer.write(uint32: durationS)
            return buffer.data
        }
    }
    public struct StateHEVCycle: MessagePayload {
        public typealias Message = StateHEVCycleMessage
        /// Duration in seconds of the HEV cycle in progress or a default HEV cycle
        /// duration.
        public let durationS: UInt32
        /// Remaining time in seconds of the HEV cycle in progress or 0 if a HEV cycle
        /// is not in progress.
        public let remainingS: UInt32
        /// Power state before HEV cycle started, which will be the power state once
        /// the cycle completes. This is only relevant if remaining_s is larger than 0.
        public let lastPower: Bool

        public static var size: Int { return 9 }

        public init(durationS: UInt32, remainingS: UInt32, lastPower: Bool) {
            self.durationS = durationS
            self.remainingS = remainingS
            self.lastPower = lastPower
        }

        public static func from(data: Data) throws -> StateHEVCycle {
            guard data.count == StateHEVCycle.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let durationS = try buffer.readUInt32()
            let remainingS = try buffer.readUInt32()
            let lastPower = try buffer.readBool()
            return StateHEVCycle(durationS: durationS, remainingS: remainingS, lastPower: lastPower)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateHEVCycle.size)
            buffer.write(uint32: durationS)
            buffer.write(uint32: remainingS)
            buffer.write(bool: lastPower)
            return buffer.data
        }
    }
    public struct SetHEVCycleConfiguration: MessagePayload {
        public typealias Message = SetHEVCycleConfigurationMessage
        /// Whether to run a short flashing indication at the end of a HEV cycle, 0
        /// or 1. Default: false.
        public let indication: Bool
        /// Duration in seconds of the default HEV cycle. The command will be ignored
        /// if duration is 0. Default: 7200 seconds (2 Hours).
        public let durationS: UInt32

        public static var size: Int { return 5 }

        public init(indication: Bool, durationS: UInt32) {
            self.indication = indication
            self.durationS = durationS
        }

        public static func from(data: Data) throws -> SetHEVCycleConfiguration {
            guard data.count == SetHEVCycleConfiguration.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let indication = try buffer.readBool()
            let durationS = try buffer.readUInt32()
            return SetHEVCycleConfiguration(indication: indication, durationS: durationS)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetHEVCycleConfiguration.size)
            buffer.write(bool: indication)
            buffer.write(uint32: durationS)
            return buffer.data
        }
    }
    public struct StateHEVCycleConfiguration: MessagePayload {
        public typealias Message = StateHEVCycleConfigurationMessage
        /// Whether to run a short flashing indication at the end of a HEV cycle, 0
        /// or 1. Default: false.
        public let indication: Bool
        /// Duration in seconds of the default HEV cycle. The command will be ignored
        /// if duration is 0. Default: 7200 seconds (2 Hours).
        public let durationS: UInt32

        public static var size: Int { return 5 }

        public init(indication: Bool, durationS: UInt32) {
            self.indication = indication
            self.durationS = durationS
        }

        public static func from(data: Data) throws -> StateHEVCycleConfiguration {
            guard data.count == StateHEVCycleConfiguration.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let indication = try buffer.readBool()
            let durationS = try buffer.readUInt32()
            return StateHEVCycleConfiguration(indication: indication, durationS: durationS)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateHEVCycleConfiguration.size)
            buffer.write(bool: indication)
            buffer.write(uint32: durationS)
            return buffer.data
        }
    }
    public struct StateLastHEVCycleResult: MessagePayload {
        public typealias Message = StateLastHEVCycleResultMessage

        public let result: LIFXProtocol.Light.LastHEVCycleResult

        public static var size: Int { return 1 }

        public init(result: LIFXProtocol.Light.LastHEVCycleResult) { self.result = result }

        public static func from(data: Data) throws -> StateLastHEVCycleResult {
            guard data.count == StateLastHEVCycleResult.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            guard let result = LIFXProtocol.Light.LastHEVCycleResult(rawValue: try buffer.readByte()) else {
                throw DeserializationErrors.invalidEnumValue
            }
            return StateLastHEVCycleResult(result: result)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateLastHEVCycleResult.size)
            buffer.write(byte: result.rawValue)
            return buffer.data
        }
    }
    // MARK: - Messages

    public struct GetMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetMessage }

        public static var messageType: MessageType { return .lightGet }

        public init(header: Header) { self.header = header }
    }
    /// LightSetColor sets color on the light.
    public struct SetColorMessage: PayloadMessageType {
        public typealias Payload = SetColor

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetColorMessage }

        public static var messageType: MessageType { return .lightSetColor }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// LightSetWaveformOptional provides light optional color and power control.
    public struct SetWaveformOptionalMessage: PayloadMessageType {
        public typealias Payload = SetWaveformOptional

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetWaveformOptionalMessage }

        public static var messageType: MessageType { return .lightSetWaveformOptional }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// LightSetWaveform provides light color and power control.
    public struct SetWaveformMessage: PayloadMessageType {
        public typealias Payload = SetWaveform

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetWaveformMessage }

        public static var messageType: MessageType { return .lightSetWaveform }

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

        public static var messageType: MessageType { return .lightGetPower }

        public init(header: Header) { self.header = header }
    }
    /// LightSetPower sets the power level of a light.
    public struct SetPowerMessage: PayloadMessageType {
        public typealias Payload = SetPower

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetPowerMessage }

        public static var messageType: MessageType { return .lightSetPower }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// LightStatePower describes the power level on light.
    public struct StatePowerMessage: PayloadMessageType {
        public typealias Payload = StatePower

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StatePowerMessage }

        public static var messageType: MessageType { return .lightStatePower }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// LightState contains the current state of the light.
    public struct StateMessage: PayloadMessageType {
        public typealias Payload = State

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateMessage }

        public static var messageType: MessageType { return .lightState }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetInfraredMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateInfraredMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetInfraredMessage }

        public static var messageType: MessageType { return .lightGetInfrared }

        public init(header: Header) { self.header = header }
    }
    /// LightStateInfrared contains the current state of the infrared channel.
    public struct StateInfraredMessage: PayloadMessageType {
        public typealias Payload = StateInfrared

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateInfraredMessage }

        public static var messageType: MessageType { return .lightStateInfrared }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// LightSetInfrared sets the infrared channel to a particular brightness.
    public struct SetInfraredMessage: PayloadMessageType {
        public typealias Payload = SetInfrared

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetInfraredMessage }

        public static var messageType: MessageType { return .lightSetInfrared }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetHEVCycleMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateHEVCycleMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetHEVCycleMessage }

        public static var messageType: MessageType { return .lightGetHevCycle }

        public init(header: Header) { self.header = header }
    }
    /// LightSetHEVCycle asks the light to start/stop HEV cycle
    public struct SetHEVCycleMessage: PayloadMessageType {
        public typealias Payload = SetHEVCycle

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetHEVCycleMessage }

        public static var messageType: MessageType { return .lightSetHevCycle }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// LightStateHEVCycle represents the HEV cycle state
    public struct StateHEVCycleMessage: PayloadMessageType {
        public typealias Payload = StateHEVCycle

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateHEVCycleMessage }

        public static var messageType: MessageType { return .lightStateHevCycle }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetHEVCycleConfigurationMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateHEVCycleConfigurationMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool {
            return message is GetHEVCycleConfigurationMessage
        }

        public static var messageType: MessageType { return .lightGetHevCycleConfiguration }

        public init(header: Header) { self.header = header }
    }
    /// LightSetHEVCycleConfiguration allows you to change the default
    /// HEV cycle configuration
    public struct SetHEVCycleConfigurationMessage: PayloadMessageType {
        public typealias Payload = SetHEVCycleConfiguration

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool {
            return message is SetHEVCycleConfigurationMessage
        }

        public static var messageType: MessageType { return .lightSetHevCycleConfiguration }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// LightStateHEVCycleConfiguration represents the HEV cycle configuration
    public struct StateHEVCycleConfigurationMessage: PayloadMessageType {
        public typealias Payload = StateHEVCycleConfiguration

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool {
            return message is StateHEVCycleConfigurationMessage
        }

        public static var messageType: MessageType { return .lightStateHevCycleConfiguration }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    public struct GetLastHEVCycleResultMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateLastHEVCycleResultMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetLastHEVCycleResultMessage }

        public static var messageType: MessageType { return .lightGetLastHevCycleResult }

        public init(header: Header) { self.header = header }
    }
    /// LightStateLastHEVCycleResult represents the result of the last HEV cycle
    public struct StateLastHEVCycleResultMessage: PayloadMessageType {
        public typealias Payload = StateLastHEVCycleResult

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateLastHEVCycleResultMessage }

        public static var messageType: MessageType { return .lightStateLastHevCycleResult }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
}
