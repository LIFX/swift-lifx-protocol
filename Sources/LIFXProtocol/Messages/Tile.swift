///
///  Tile.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import ByteBuffer
import Foundation

public struct Tile {
    // MARK: - Enums

    public enum EffectType: UInt8 {
        case off = 0
        case morph = 2
        case flame = 3
    }

    // MARK: - Types

    public struct AccelMeas: DataCodable {

        public let x: Int16

        public let y: Int16

        public let z: Int16

        public static var size: Int { return 6 }
        public init(x: Int16, y: Int16, z: Int16) {
            self.x = x
            self.y = y
            self.z = z
        }

        public static func from(data: Data) throws -> AccelMeas {
            guard data.count == AccelMeas.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let x = Int16(bitPattern: try buffer.readShort())
            let y = Int16(bitPattern: try buffer.readShort())
            let z = Int16(bitPattern: try buffer.readShort())
            return AccelMeas(x: x, y: y, z: z)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: AccelMeas.size)
            buffer.write(short: UInt16(bitPattern: x))
            buffer.write(short: UInt16(bitPattern: y))
            buffer.write(short: UInt16(bitPattern: z))
            return buffer.data
        }
    }

    public struct StateDevice: DataCodable {

        public let accelMeas: LIFXProtocol.Tile.AccelMeas

        public let reserved1: Data
        public static let reserved1Size = 2
        /// Position relative to other tiles in chain on a cartesian plane. Each unit
        /// is the width of one 8x8 tile.
        public let userX: Float
        /// Position relative to other tiles in chain on a cartesian plane. Each unit
        /// is the width of one 8x8 tile.
        public let userY: Float
        /// Pixel width of this tile.
        public let width: UInt8
        /// Pixel height of this tile.
        public let height: UInt8

        public let reserved2: Data
        public static let reserved2Size = 1
        /// VendorID, ProductID and hardware version.
        public let deviceVersion: LIFXProtocol.Device.StateVersion
        /// Build/Install timestamps and version number.
        public let firmware: LIFXProtocol.Device.StateHostFirmware

        public let reserved3: Data
        public static let reserved3Size = 4

        public static var size: Int { return 55 }
        public init(
            accelMeas: LIFXProtocol.Tile.AccelMeas,
            reserved1: Data = Data(count: 2),
            userX: Float,
            userY: Float,
            width: UInt8,
            height: UInt8,
            reserved2: Data = Data(count: 1),
            deviceVersion: LIFXProtocol.Device.StateVersion,
            firmware: LIFXProtocol.Device.StateHostFirmware,
            reserved3: Data = Data(count: 4)
        ) throws {
            self.accelMeas = accelMeas
            guard reserved1.count <= StateDevice.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            self.userX = userX
            self.userY = userY
            self.width = width
            self.height = height
            guard reserved2.count <= StateDevice.reserved2Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved2 = reserved2
            self.deviceVersion = deviceVersion
            self.firmware = firmware
            guard reserved3.count <= StateDevice.reserved3Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved3 = reserved3
        }

        public static func from(data: Data) throws -> StateDevice {
            guard data.count == StateDevice.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let accelMeasBytes = Data(try buffer.readBytes(LIFXProtocol.Tile.AccelMeas.size))
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let userX = Float(bitPattern: try buffer.readUInt32())
            let userY = Float(bitPattern: try buffer.readUInt32())
            let width = try buffer.readByte()
            let height = try buffer.readByte()
            let reserved2 = Data(try (0..<reserved2Size).map { _ in try buffer.readByte() })
            let deviceVersionBytes = Data(try buffer.readBytes(LIFXProtocol.Device.StateVersion.size))
            let firmwareBytes = Data(try buffer.readBytes(LIFXProtocol.Device.StateHostFirmware.size))
            let reserved3 = Data(try (0..<reserved3Size).map { _ in try buffer.readByte() })
            let accelMeas = try LIFXProtocol.Tile.AccelMeas.from(data: accelMeasBytes)
            let deviceVersion = try LIFXProtocol.Device.StateVersion.from(data: deviceVersionBytes)
            let firmware = try LIFXProtocol.Device.StateHostFirmware.from(data: firmwareBytes)
            return try StateDevice(
                accelMeas: accelMeas,
                reserved1: reserved1,
                userX: userX,
                userY: userY,
                width: width,
                height: height,
                reserved2: reserved2,
                deviceVersion: deviceVersion,
                firmware: firmware,
                reserved3: reserved3
            )
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateDevice.size)
            buffer.write(data: accelMeas.toData())
            (0..<2).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            ByteBuffer.toByteArray(userX).forEach { buffer.write(byte: $0) }
            ByteBuffer.toByteArray(userY).forEach { buffer.write(byte: $0) }
            buffer.write(byte: width)
            buffer.write(byte: height)
            (0..<1).forEach { buffer.write(byte: $0 < reserved2.count ? reserved2[$0] : 0x00) }
            buffer.write(data: deviceVersion.toData())
            buffer.write(data: firmware.toData())
            (0..<4).forEach { buffer.write(byte: $0 < reserved3.count ? reserved3[$0] : 0x00) }
            return buffer.data
        }
    }

    public struct BufferRect: DataCodable {

        public let reserved1: Data
        public static let reserved1Size = 1

        public let x: UInt8

        public let y: UInt8

        public let width: UInt8

        public static var size: Int { return 4 }
        public init(reserved1: Data = Data(count: 1), x: UInt8, y: UInt8, width: UInt8) throws {
            guard reserved1.count <= BufferRect.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            self.x = x
            self.y = y
            self.width = width
        }

        public static func from(data: Data) throws -> BufferRect {
            guard data.count == BufferRect.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let x = try buffer.readByte()
            let y = try buffer.readByte()
            let width = try buffer.readByte()
            return try BufferRect(reserved1: reserved1, x: x, y: y, width: width)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: BufferRect.size)
            (0..<1).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            buffer.write(byte: x)
            buffer.write(byte: y)
            buffer.write(byte: width)
            return buffer.data
        }
    }

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
        /// Identifies effects type. Consult the TileEffectType enum list for more
        /// details.
        public let type: LIFXProtocol.Tile.EffectType
        /// Refers to speed of animation effect. If effect is cyclic then this value
        /// refers to milisecond period for a complete animation cycle to occur. Else
        /// if acyclic, then is the general milliseconds until the next frame
        /// transition.
        public let speed: UInt32
        /// This field refers to how long the effects will go for before reverting
        /// back to the primary framebuffer colors. In SetTileEffect, this would set
        /// a new duration limit. A StateTileEffect would return the duration left.
        /// Duration is in nanoseconds.
        public let duration: UInt64

        public let reserved1: Data
        public static let reserved1Size = 4

        public let reserved2: Data
        public static let reserved2Size = 4
        /// This is a general purpose parameter field for effects. Meaning and
        /// structure depends on the effect type.
        public let parameter: LIFXProtocol.Tile.EffectParameter
        /// Count of Hsbk values in the palette array.
        public let paletteCount: UInt8
        /// Color palette to used (optionally) by effect.
        public let palette: [LIFXProtocol.Light.HSBK]
        public static let paletteSize = 16

        public static var size: Int { return 186 }
        public init(
            instanceid: UInt32,
            type: LIFXProtocol.Tile.EffectType,
            speed: UInt32,
            duration: UInt64,
            reserved1: Data = Data(count: 4),
            reserved2: Data = Data(count: 4),
            parameter: LIFXProtocol.Tile.EffectParameter,
            palette: [LIFXProtocol.Light.HSBK]
        ) throws {
            self.instanceid = instanceid
            self.type = type
            self.speed = speed
            self.duration = duration
            guard reserved1.count <= EffectSettings.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            guard reserved2.count <= EffectSettings.reserved2Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved2 = reserved2
            self.parameter = parameter
            guard palette.count <= EffectSettings.paletteSize else { throw DeserializationErrors.contentTooLarge }
            self.palette = palette
            self.paletteCount = UInt8(palette.count)
        }

        public static func from(data: Data) throws -> EffectSettings {
            guard data.count == EffectSettings.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let instanceid = try buffer.readUInt32()
            guard let type = LIFXProtocol.Tile.EffectType(rawValue: try buffer.readByte()) else {
                throw DeserializationErrors.invalidEnumValue
            }
            let speed = try buffer.readUInt32()
            let duration = try buffer.readUInt64()
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let reserved2 = Data(try (0..<reserved2Size).map { _ in try buffer.readByte() })
            let parameterBytes = Data(try buffer.readBytes(LIFXProtocol.Tile.EffectParameter.size))
            // Ignored count field
            _ = try buffer.readByte()
            let paletteBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size * paletteSize))
            let parameter = try LIFXProtocol.Tile.EffectParameter.from(data: parameterBytes)
            let palette = (0..<16)
                .compactMap { i -> LIFXProtocol.Light.HSBK? in
                    do {
                        let dataOffset = LIFXProtocol.Light.HSBK.size * Int(i)
                        let bytes = paletteBytes.subdata(in: dataOffset..<(dataOffset + LIFXProtocol.Light.HSBK.size))
                        return try LIFXProtocol.Light.HSBK.from(data: bytes)
                    } catch { return nil }
                }
            return try EffectSettings(
                instanceid: instanceid,
                type: type,
                speed: speed,
                duration: duration,
                reserved1: reserved1,
                reserved2: reserved2,
                parameter: parameter,
                palette: palette
            )
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: EffectSettings.size)
            buffer.write(uint32: instanceid)
            buffer.write(byte: type.rawValue)
            buffer.write(uint32: speed)
            buffer.write(uint64: duration)
            (0..<4).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            (0..<4).forEach { buffer.write(byte: $0 < reserved2.count ? reserved2[$0] : 0x00) }
            buffer.write(data: parameter.toData())
            buffer.write(byte: paletteCount)
            (0..<16)
                .forEach {
                    if $0 < palette.count {
                        buffer.write(data: palette[$0].toData())
                    } else {
                        (0..<LIFXProtocol.Light.HSBK.size).forEach { _ in buffer.write(byte: 0x00) }
                    }
                }
            return buffer.data
        }
    }

    // MARK: - Payloads

    public struct StateDeviceChain: MessagePayload {
        public typealias Message = StateDeviceChainMessage

        public let startIndex: UInt8

        public let tileDevices: [LIFXProtocol.Tile.StateDevice]
        public static let tileDevicesSize = 16

        public let tileDevicesCount: UInt8

        public static var size: Int { return 882 }

        public init(startIndex: UInt8, tileDevices: [LIFXProtocol.Tile.StateDevice]) throws {
            self.startIndex = startIndex
            guard tileDevices.count <= StateDeviceChain.tileDevicesSize else {
                throw DeserializationErrors.contentTooLarge
            }
            self.tileDevices = tileDevices
            self.tileDevicesCount = UInt8(tileDevices.count)
        }

        public static func from(data: Data) throws -> StateDeviceChain {
            guard data.count == StateDeviceChain.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let startIndex = try buffer.readByte()
            let tileDevicesBytes = Data(try buffer.readBytes(LIFXProtocol.Tile.StateDevice.size * tileDevicesSize))
            let tileDevicesCount = try buffer.readByte()
            let tileDevices = try (0..<tileDevicesCount)
                .map { i -> LIFXProtocol.Tile.StateDevice in
                    let dataOffset = LIFXProtocol.Tile.StateDevice.size * Int(i)
                    let bytes = tileDevicesBytes.subdata(
                        in: dataOffset..<(dataOffset + LIFXProtocol.Tile.StateDevice.size)
                    )
                    return try LIFXProtocol.Tile.StateDevice.from(data: bytes)
                }
            return try StateDeviceChain(startIndex: startIndex, tileDevices: tileDevices)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateDeviceChain.size)
            buffer.write(byte: startIndex)
            (0..<16)
                .forEach {
                    if $0 < tileDevices.count {
                        buffer.write(data: tileDevices[$0].toData())
                    } else {
                        (0..<LIFXProtocol.Tile.StateDevice.size).forEach { _ in buffer.write(byte: 0x00) }
                    }
                }
            buffer.write(byte: tileDevicesCount)
            return buffer.data
        }
    }
    public struct SetUserPosition: MessagePayload {
        public typealias Message = SetUserPositionMessage

        public let tileIndex: UInt8

        public let reserved1: Data
        public static let reserved1Size = 2

        public let userX: Float

        public let userY: Float

        public static var size: Int { return 11 }

        public init(tileIndex: UInt8, reserved1: Data = Data(count: 2), userX: Float, userY: Float) throws {
            self.tileIndex = tileIndex
            guard reserved1.count <= SetUserPosition.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            self.userX = userX
            self.userY = userY
        }

        public static func from(data: Data) throws -> SetUserPosition {
            guard data.count == SetUserPosition.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let tileIndex = try buffer.readByte()
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let userX = Float(bitPattern: try buffer.readUInt32())
            let userY = Float(bitPattern: try buffer.readUInt32())
            return try SetUserPosition(tileIndex: tileIndex, reserved1: reserved1, userX: userX, userY: userY)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetUserPosition.size)
            buffer.write(byte: tileIndex)
            (0..<2).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            ByteBuffer.toByteArray(userX).forEach { buffer.write(byte: $0) }
            ByteBuffer.toByteArray(userY).forEach { buffer.write(byte: $0) }
            return buffer.data
        }
    }
    public struct Get64: MessagePayload {
        public typealias Message = Get64Message

        public let tileIndex: UInt8

        public let length: UInt8

        public let rect: LIFXProtocol.Tile.BufferRect

        public static var size: Int { return 6 }

        public init(tileIndex: UInt8, length: UInt8, rect: LIFXProtocol.Tile.BufferRect) {
            self.tileIndex = tileIndex
            self.length = length
            self.rect = rect
        }

        public static func from(data: Data) throws -> Get64 {
            guard data.count == Get64.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let tileIndex = try buffer.readByte()
            let length = try buffer.readByte()
            let rectBytes = Data(try buffer.readBytes(LIFXProtocol.Tile.BufferRect.size))
            let rect = try LIFXProtocol.Tile.BufferRect.from(data: rectBytes)
            return Get64(tileIndex: tileIndex, length: length, rect: rect)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: Get64.size)
            buffer.write(byte: tileIndex)
            buffer.write(byte: length)
            buffer.write(data: rect.toData())
            return buffer.data
        }
    }
    public struct State64: MessagePayload {
        public typealias Message = State64Message

        public let tileIndex: UInt8

        public let rect: LIFXProtocol.Tile.BufferRect

        public let colors: [LIFXProtocol.Light.HSBK]
        public static let colorsSize = 64

        public static var size: Int { return 517 }

        public init(tileIndex: UInt8, rect: LIFXProtocol.Tile.BufferRect, colors: [LIFXProtocol.Light.HSBK]) throws {
            self.tileIndex = tileIndex
            self.rect = rect
            guard colors.count <= State64.colorsSize else { throw DeserializationErrors.contentTooLarge }
            self.colors = colors
        }

        public static func from(data: Data) throws -> State64 {
            guard data.count == State64.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let tileIndex = try buffer.readByte()
            let rectBytes = Data(try buffer.readBytes(LIFXProtocol.Tile.BufferRect.size))
            let colorsBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size * colorsSize))
            let rect = try LIFXProtocol.Tile.BufferRect.from(data: rectBytes)
            let colors = (0..<64)
                .compactMap { i -> LIFXProtocol.Light.HSBK? in
                    do {
                        let dataOffset = LIFXProtocol.Light.HSBK.size * Int(i)
                        let bytes = colorsBytes.subdata(in: dataOffset..<(dataOffset + LIFXProtocol.Light.HSBK.size))
                        return try LIFXProtocol.Light.HSBK.from(data: bytes)
                    } catch { return nil }
                }
            return try State64(tileIndex: tileIndex, rect: rect, colors: colors)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: State64.size)
            buffer.write(byte: tileIndex)
            buffer.write(data: rect.toData())
            (0..<64)
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
    public struct Set64: MessagePayload {
        public typealias Message = Set64Message

        public let tileIndex: UInt8

        public let length: UInt8

        public let rect: LIFXProtocol.Tile.BufferRect

        public let duration: UInt32

        public let colors: [LIFXProtocol.Light.HSBK]
        public static let colorsSize = 64

        public static var size: Int { return 522 }

        public init(
            tileIndex: UInt8,
            length: UInt8,
            rect: LIFXProtocol.Tile.BufferRect,
            duration: UInt32,
            colors: [LIFXProtocol.Light.HSBK]
        ) throws {
            self.tileIndex = tileIndex
            self.length = length
            self.rect = rect
            self.duration = duration
            guard colors.count <= Set64.colorsSize else { throw DeserializationErrors.contentTooLarge }
            self.colors = colors
        }

        public static func from(data: Data) throws -> Set64 {
            guard data.count == Set64.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let tileIndex = try buffer.readByte()
            let length = try buffer.readByte()
            let rectBytes = Data(try buffer.readBytes(LIFXProtocol.Tile.BufferRect.size))
            let duration = try buffer.readUInt32()
            let colorsBytes = Data(try buffer.readBytes(LIFXProtocol.Light.HSBK.size * colorsSize))
            let rect = try LIFXProtocol.Tile.BufferRect.from(data: rectBytes)
            let colors = (0..<64)
                .compactMap { i -> LIFXProtocol.Light.HSBK? in
                    do {
                        let dataOffset = LIFXProtocol.Light.HSBK.size * Int(i)
                        let bytes = colorsBytes.subdata(in: dataOffset..<(dataOffset + LIFXProtocol.Light.HSBK.size))
                        return try LIFXProtocol.Light.HSBK.from(data: bytes)
                    } catch { return nil }
                }
            return try Set64(tileIndex: tileIndex, length: length, rect: rect, duration: duration, colors: colors)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: Set64.size)
            buffer.write(byte: tileIndex)
            buffer.write(byte: length)
            buffer.write(data: rect.toData())
            buffer.write(uint32: duration)
            (0..<64)
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
    public struct GetEffect: MessagePayload {
        public typealias Message = GetEffectMessage

        public let reserved1: Data
        public static let reserved1Size = 1

        public let reserved2: Data
        public static let reserved2Size = 1

        public static var size: Int { return 2 }

        public init(reserved1: Data = Data(count: 1), reserved2: Data = Data(count: 1)) throws {
            guard reserved1.count <= GetEffect.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            guard reserved2.count <= GetEffect.reserved2Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved2 = reserved2
        }

        public static func from(data: Data) throws -> GetEffect {
            guard data.count == GetEffect.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let reserved2 = Data(try (0..<reserved2Size).map { _ in try buffer.readByte() })
            return try GetEffect(reserved1: reserved1, reserved2: reserved2)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: GetEffect.size)
            (0..<1).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            (0..<1).forEach { buffer.write(byte: $0 < reserved2.count ? reserved2[$0] : 0x00) }
            return buffer.data
        }
    }
    public struct SetEffect: MessagePayload {
        public typealias Message = SetEffectMessage

        public let reserved1: Data
        public static let reserved1Size = 1

        public let reserved2: Data
        public static let reserved2Size = 1

        public let settings: LIFXProtocol.Tile.EffectSettings

        public static var size: Int { return 188 }

        public init(
            reserved1: Data = Data(count: 1),
            reserved2: Data = Data(count: 1),
            settings: LIFXProtocol.Tile.EffectSettings
        ) throws {
            guard reserved1.count <= SetEffect.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            guard reserved2.count <= SetEffect.reserved2Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved2 = reserved2
            self.settings = settings
        }

        public static func from(data: Data) throws -> SetEffect {
            guard data.count == SetEffect.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let reserved2 = Data(try (0..<reserved2Size).map { _ in try buffer.readByte() })
            let settingsBytes = Data(try buffer.readBytes(LIFXProtocol.Tile.EffectSettings.size))
            let settings = try LIFXProtocol.Tile.EffectSettings.from(data: settingsBytes)
            return try SetEffect(reserved1: reserved1, reserved2: reserved2, settings: settings)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: SetEffect.size)
            (0..<1).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            (0..<1).forEach { buffer.write(byte: $0 < reserved2.count ? reserved2[$0] : 0x00) }
            buffer.write(data: settings.toData())
            return buffer.data
        }
    }
    public struct StateEffect: MessagePayload {
        public typealias Message = StateEffectMessage

        public let reserved1: Data
        public static let reserved1Size = 1

        public let settings: LIFXProtocol.Tile.EffectSettings

        public static var size: Int { return 187 }

        public init(reserved1: Data = Data(count: 1), settings: LIFXProtocol.Tile.EffectSettings) throws {
            guard reserved1.count <= StateEffect.reserved1Size else { throw DeserializationErrors.contentTooLarge }
            self.reserved1 = reserved1
            self.settings = settings
        }

        public static func from(data: Data) throws -> StateEffect {
            guard data.count == StateEffect.size else { throw DeserializationErrors.insufficientBytes }

            var buffer = ByteBuffer(data: data)
            let reserved1 = Data(try (0..<reserved1Size).map { _ in try buffer.readByte() })
            let settingsBytes = Data(try buffer.readBytes(LIFXProtocol.Tile.EffectSettings.size))
            let settings = try LIFXProtocol.Tile.EffectSettings.from(data: settingsBytes)
            return try StateEffect(reserved1: reserved1, settings: settings)
        }

        public func toData() -> Data {
            var buffer = ByteBuffer(capacity: StateEffect.size)
            (0..<1).forEach { buffer.write(byte: $0 < reserved1.count ? reserved1[$0] : 0x00) }
            buffer.write(data: settings.toData())
            return buffer.data
        }
    }
    // MARK: - Messages

    public struct GetDeviceChainMessage: AcknowledgementMessageType {
        public let header: Header
        public typealias ResponseType = StateDeviceChainMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetDeviceChainMessage }

        public static var messageType: MessageType { return .tileGetDeviceChain }

        public init(header: Header) { self.header = header }
    }
    /// TileStateDeviceChain contains for the next 16 valid tiles from start_index in
    /// this chain, as well as the total number of tiles.
    public struct StateDeviceChainMessage: PayloadMessageType {
        public typealias Payload = StateDeviceChain

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateDeviceChainMessage }

        public static var messageType: MessageType { return .tileStateDeviceChain }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// TileSetUserPosition sets the user x/y position and gravity vector for given
    /// tile index.
    public struct SetUserPositionMessage: PayloadMessageType {
        public typealias Payload = SetUserPosition

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetUserPositionMessage }

        public static var messageType: MessageType { return .tileSetUserPosition }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// TileGet64 requests 64 HSBK values for the given rectangle on n (length)
    /// tiles starting at tile_index. Response will be TileState64.
    public struct Get64Message: PayloadMessageType {
        public typealias Payload = Get64

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = State64Message

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool {
            guard let msg = message as? Get64Message,
                msg.payload.tileIndex == payload.tileIndex && msg.payload.length == payload.length
            else { return false }
            return true
        }

        public static var messageType: MessageType { return .tileGet64 }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// TileState64 responds to TileGet64.
    public struct State64Message: PayloadMessageType {
        public typealias Payload = State64

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is State64Message }

        public static var messageType: MessageType { return .tileState64 }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// TileSet64 sets 64 HSBK values for the given rectangle on n (length)
    /// tiles starting at tile_index. Duration is only applicable when applying to
    /// the primary framebuffer (index zero).
    public struct Set64Message: PayloadMessageType {
        public typealias Payload = Set64

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool {
            guard let msg = message as? Set64Message,
                msg.payload.tileIndex == payload.tileIndex && msg.payload.length == payload.length
            else { return false }
            return true
        }

        public static var messageType: MessageType { return .tileSet64 }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// TileGetEffect requests a TileStateEffect response from the target device. The
    /// device will then reply with its current state. Reserve two 8-bit fields for
    /// tile index and length.
    public struct GetEffectMessage: PayloadMessageType {
        public typealias Payload = GetEffect

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = StateEffectMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is GetEffectMessage }

        public static var messageType: MessageType { return .tileGetEffect }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// TileSetEffect allows for configuring and setting a new effect.
    /// If a response is requested, a TileStateEffect message will be sent to the
    /// requester with a copy of the last effect state. This would allow the app to
    /// reload the previous effect if the user wants to revert to a previous effect.
    /// (Kind of like an undo button). Reserve two 8-bit fields for tile index and
    /// length.
    public struct SetEffectMessage: PayloadMessageType {
        public typealias Payload = SetEffect

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = true
        public let isDeviceMessage = false

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is SetEffectMessage }

        public static var messageType: MessageType { return .tileSetEffect }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
    /// TileStateEffect reports back to the requester the current effect status.
    /// Reserve one 8-bit field for tile index.
    public struct StateEffectMessage: PayloadMessageType {
        public typealias Payload = StateEffect

        public let header: Header
        public let payload: Payload
        public typealias ResponseType = Device.AcknowledgementMessage

        public let isClientMessage = false
        public let isDeviceMessage = true

        public func isMatch(_ message: AbstractMessageType) -> Bool { return message is StateEffectMessage }

        public static var messageType: MessageType { return .tileStateEffect }

        public init(header: Header, payload: Payload) {
            self.header = header
            self.payload = payload
        }
    }
}
