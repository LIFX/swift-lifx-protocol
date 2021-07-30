///
///  TileHelpers.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

@testable import LIFXProtocol

func randomTileAccelMeas() -> Tile.AccelMeas {
    let x: Int16 = -9_000
    let y: Int16 = -9_000
    let z: Int16 = -9_000
    return Tile.AccelMeas(x: x, y: y, z: z)
}

func randomTileStateDevice() -> Tile.StateDevice {
    let accel_meas = randomTileAccelMeas()
    let reserved1 = Data(Array((0..<2)))
    let user_x: Float = 0.5
    let user_y: Float = 0.5
    let width: UInt8 = 0x1f
    let height: UInt8 = 0x1f
    let reserved2 = Data(Array((0..<1)))
    let device_version = randomDeviceStateVersion()
    let firmware = randomDeviceStateHostFirmware()
    let reserved3 = Data(Array((0..<4)))
    return try! Tile.StateDevice(
        accelMeas: accel_meas,
        reserved1: reserved1,
        userX: user_x,
        userY: user_y,
        width: width,
        height: height,
        reserved2: reserved2,
        deviceVersion: device_version,
        firmware: firmware,
        reserved3: reserved3
    )
}

func randomTileStateDeviceChain() -> Tile.StateDeviceChain {
    let start_index: UInt8 = 0x1f
    let tile_devices_count: UInt8 = 16 / 2
    let tile_devices: [Tile.StateDevice] = (0..<tile_devices_count).map { _ in randomTileStateDevice() }
    return try! Tile.StateDeviceChain(startIndex: start_index, tileDevices: tile_devices)
}

func randomTileSetUserPosition() -> Tile.SetUserPosition {
    let tile_index: UInt8 = 0x1f
    let reserved1 = Data(Array((0..<2)))
    let user_x: Float = 0.5
    let user_y: Float = 0.5
    return try! Tile.SetUserPosition(tileIndex: tile_index, reserved1: reserved1, userX: user_x, userY: user_y)
}

func randomTileBufferRect() -> Tile.BufferRect {
    let reserved1 = Data(Array((0..<1)))
    let x: UInt8 = 0x1f
    let y: UInt8 = 0x1f
    let width: UInt8 = 0x1f
    return try! Tile.BufferRect(reserved1: reserved1, x: x, y: y, width: width)
}

func randomTileState64() -> Tile.State64 {
    let tile_index: UInt8 = 0x1f
    let rect = randomTileBufferRect()
    let colors_count: UInt8 = 64 / 2
    let colors: [Light.HSBK] = (0..<colors_count).map { _ in defaultColor }
    return try! Tile.State64(tileIndex: tile_index, rect: rect, colors: colors)
}

func randomTileSet64() -> Tile.Set64 {
    let tile_index: UInt8 = 0x1f
    let length: UInt8 = 0x1f
    let rect = randomTileBufferRect()
    let duration: UInt32 = 0x04_01_00_ff
    let colors_count: UInt8 = 64 / 2
    let colors: [Light.HSBK] = (0..<colors_count).map { _ in defaultColor }
    return try! Tile.Set64(tileIndex: tile_index, length: length, rect: rect, duration: duration, colors: colors)
}

func randomTileEffectParameter() -> Tile.EffectParameter {
    let parameter0: UInt32 = 0x04_01_00_ff
    let parameter1: UInt32 = 0x04_01_00_ff
    let parameter2: UInt32 = 0x04_01_00_ff
    let parameter3: UInt32 = 0x04_01_00_ff
    let parameter4: UInt32 = 0x04_01_00_ff
    let parameter5: UInt32 = 0x04_01_00_ff
    let parameter6: UInt32 = 0x04_01_00_ff
    let parameter7: UInt32 = 0x04_01_00_ff
    return Tile.EffectParameter(
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

func randomTileEffectSettings() -> Tile.EffectSettings {
    let instanceid: UInt32 = 0x04_01_00_ff
    let type = Tile.EffectType(rawValue: 0) ?? Tile.EffectType(rawValue: 1)!
    let speed: UInt32 = 0x04_01_00_ff
    let duration: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    let reserved1 = Data(Array((0..<4)))
    let reserved2 = Data(Array((0..<4)))
    let parameter = randomTileEffectParameter()
    let palette_count: UInt8 = 16 / 2
    let palette: [Light.HSBK] = (0..<palette_count).map { _ in defaultColor }
    return try! Tile.EffectSettings(
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

func randomTileSetEffect() -> Tile.SetEffect {
    let reserved1 = Data(Array((0..<1)))
    let reserved2 = Data(Array((0..<1)))
    let settings = randomTileEffectSettings()
    return try! Tile.SetEffect(reserved1: reserved1, reserved2: reserved2, settings: settings)
}

func randomTileStateEffect() -> Tile.StateEffect {
    let reserved1 = Data(Array((0..<1)))
    let settings = randomTileEffectSettings()
    return try! Tile.StateEffect(reserved1: reserved1, settings: settings)
}
