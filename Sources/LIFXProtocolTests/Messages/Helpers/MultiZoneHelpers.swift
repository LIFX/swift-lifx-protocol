///
///  MultiZoneHelpers.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

@testable import LIFXProtocol

func randomMultiZoneSetColorZones() -> MultiZone.SetColorZones {
    let start_index: UInt8 = 0x1f
    let end_index: UInt8 = 0x1f
    let color = defaultColor
    let duration: UInt32 = 0x04_01_00_ff
    let apply = MultiZone.ApplicationRequest(rawValue: 0) ?? MultiZone.ApplicationRequest(rawValue: 1)!
    return MultiZone.SetColorZones(
        startIndex: start_index,
        endIndex: end_index,
        color: color,
        duration: duration,
        apply: apply
    )
}

func randomMultiZoneStateZone() -> MultiZone.StateZone {
    let count: UInt8 = 0x10
    let index: UInt8 = 0x1f
    let color = defaultColor
    return MultiZone.StateZone(count: count, index: index, color: color)
}

func randomMultiZoneStateMultiZone() -> MultiZone.StateMultiZone {
    let count: UInt8 = 0x10
    let index: UInt8 = 0x1f
    let colors_count: UInt8 = 8 / 2
    let colors: [Light.HSBK] = (0..<colors_count).map { _ in defaultColor }
    return try! MultiZone.StateMultiZone(count: count, index: index, colors: colors)
}

func randomMultiZoneEffectParameter() -> MultiZone.EffectParameter {
    let parameter0: UInt32 = 0x04_01_00_ff
    let parameter1: UInt32 = 0x04_01_00_ff
    let parameter2: UInt32 = 0x04_01_00_ff
    let parameter3: UInt32 = 0x04_01_00_ff
    let parameter4: UInt32 = 0x04_01_00_ff
    let parameter5: UInt32 = 0x04_01_00_ff
    let parameter6: UInt32 = 0x04_01_00_ff
    let parameter7: UInt32 = 0x04_01_00_ff
    return MultiZone.EffectParameter(
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

func randomMultiZoneEffectSettings() -> MultiZone.EffectSettings {
    let instanceid: UInt32 = 0x04_01_00_ff
    let type = MultiZone.EffectType(rawValue: 0) ?? MultiZone.EffectType(rawValue: 1)!
    let reserved1 = Data(Array((0..<2)))
    let speed: UInt32 = 0x04_01_00_ff
    let duration: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    let reserved2 = Data(Array((0..<4)))
    let reserved3 = Data(Array((0..<4)))
    let parameter = randomMultiZoneEffectParameter()
    return try! MultiZone.EffectSettings(
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

func randomMultiZoneSetEffect() -> MultiZone.SetEffect {
    let settings = randomMultiZoneEffectSettings()
    return MultiZone.SetEffect(settings: settings)
}

func randomMultiZoneStateEffect() -> MultiZone.StateEffect {
    let settings = randomMultiZoneEffectSettings()
    return MultiZone.StateEffect(settings: settings)
}

func randomMultiZoneExtendedSetColorZones() -> MultiZone.ExtendedSetColorZones {
    let duration: UInt32 = 0x04_01_00_ff
    let apply = MultiZone.ExtendedApplicationRequest(rawValue: 0) ?? MultiZone.ExtendedApplicationRequest(rawValue: 1)!
    let index: UInt16 = 0x04_00
    let colors_count: UInt8 = 82 / 2
    let colors: [Light.HSBK] = (0..<colors_count).map { _ in defaultColor }
    return try! MultiZone.ExtendedSetColorZones(duration: duration, apply: apply, index: index, colors: colors)
}

func randomMultiZoneExtendedStateMultiZone() -> MultiZone.ExtendedStateMultiZone {
    let count: UInt16 = 0x04_00
    let index: UInt16 = 0x04_00
    let colors_count: UInt8 = 82 / 2
    let colors: [Light.HSBK] = (0..<colors_count).map { _ in defaultColor }
    return try! MultiZone.ExtendedStateMultiZone(count: count, index: index, colors: colors)
}
