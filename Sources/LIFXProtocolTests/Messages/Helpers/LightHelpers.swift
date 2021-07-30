///
///  LightHelpers.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

@testable import LIFXProtocol

func randomLightSetColor() -> Light.SetColor {
    let reserved1 = Data(Array((0..<1)))
    let color = defaultColor
    let duration: UInt32 = 0x04_01_00_ff
    return try! Light.SetColor(reserved1: reserved1, color: color, duration: duration)
}

func randomLightSetWaveformOptional() -> Light.SetWaveformOptional {
    let reserved1 = Data(Array((0..<1)))
    let transient = true
    let color = defaultColor
    let period: UInt32 = 0x04_01_00_ff
    let cycles: Float = 0.5
    let skew_ratio: Int16 = -9_000
    let waveform = Light.Waveform(rawValue: 0) ?? Light.Waveform(rawValue: 1)!
    let set_hue = true
    let set_saturation = true
    let set_brightness = true
    let set_kelvin = true
    return try! Light.SetWaveformOptional(
        reserved1: reserved1,
        transient: transient,
        color: color,
        period: period,
        cycles: cycles,
        skewRatio: skew_ratio,
        waveform: waveform,
        setHue: set_hue,
        setSaturation: set_saturation,
        setBrightness: set_brightness,
        setKelvin: set_kelvin
    )
}

func randomLightSetWaveform() -> Light.SetWaveform {
    let reserved1 = Data(Array((0..<1)))
    let transient = true
    let color = defaultColor
    let period: UInt32 = 0x04_01_00_ff
    let cycles: Float = 0.5
    let skew_ratio: Int16 = -9_000
    let waveform = Light.Waveform(rawValue: 0) ?? Light.Waveform(rawValue: 1)!
    return try! Light.SetWaveform(
        reserved1: reserved1,
        transient: transient,
        color: color,
        period: period,
        cycles: cycles,
        skewRatio: skew_ratio,
        waveform: waveform
    )
}

func randomLightSetPower() -> Light.SetPower {
    let level: UInt16 = 0x04_00
    let duration: UInt32 = 0x04_01_00_ff
    return Light.SetPower(level: level, duration: duration)
}

func randomLightStatePower() -> Light.StatePower {
    let level: UInt16 = 0x04_00
    return Light.StatePower(level: level)
}

func randomLightState() -> Light.State {
    let color = defaultColor
    let reserved1 = Data(Array((0..<2)))
    let power: UInt16 = 0x04_00
    let label: String = "Hello World, 你好,世界"
    let reserved2 = Data(Array((0..<8)))
    return try! Light.State(color: color, reserved1: reserved1, power: power, label: label, reserved2: reserved2)
}

func randomLightStateInfrared() -> Light.StateInfrared {
    let brightness: UInt16 = 0x04_00
    return Light.StateInfrared(brightness: brightness)
}

func randomLightSetInfrared() -> Light.SetInfrared {
    let brightness: UInt16 = 0x04_00
    return Light.SetInfrared(brightness: brightness)
}

func randomLightSetHEVCycle() -> Light.SetHEVCycle {
    let enable = true
    let duration_s: UInt32 = 0x04_01_00_ff
    return Light.SetHEVCycle(enable: enable, durationS: duration_s)
}

func randomLightStateHEVCycle() -> Light.StateHEVCycle {
    let duration_s: UInt32 = 0x04_01_00_ff
    let remaining_s: UInt32 = 0x04_01_00_ff
    let last_power = true
    return Light.StateHEVCycle(durationS: duration_s, remainingS: remaining_s, lastPower: last_power)
}

func randomLightSetHEVCycleConfiguration() -> Light.SetHEVCycleConfiguration {
    let indication = true
    let duration_s: UInt32 = 0x04_01_00_ff
    return Light.SetHEVCycleConfiguration(indication: indication, durationS: duration_s)
}

func randomLightStateHEVCycleConfiguration() -> Light.StateHEVCycleConfiguration {
    let indication = true
    let duration_s: UInt32 = 0x04_01_00_ff
    return Light.StateHEVCycleConfiguration(indication: indication, durationS: duration_s)
}

func randomLightStateLastHEVCycleResult() -> Light.StateLastHEVCycleResult {
    let result = Light.LastHEVCycleResult(rawValue: 0) ?? Light.LastHEVCycleResult(rawValue: 1)!
    return Light.StateLastHEVCycleResult(result: result)
}
