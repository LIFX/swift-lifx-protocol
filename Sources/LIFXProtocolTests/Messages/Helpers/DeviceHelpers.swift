///
///  DeviceHelpers.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

@testable import LIFXProtocol

func randomDeviceStateService() -> Device.StateService {
    let service = Device.Service(rawValue: 0) ?? Device.Service(rawValue: 1)!
    let port: UInt32 = 0x04_01_00_ff
    return Device.StateService(service: service, port: port)
}

func randomDeviceStateHostFirmware() -> Device.StateHostFirmware {
    let build: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    let reserved1 = Data(Array((0..<8)))
    let version_minor: UInt16 = 0x04_00
    let version_major: UInt16 = 0x04_00
    return try! Device.StateHostFirmware(
        build: build,
        reserved1: reserved1,
        versionMinor: version_minor,
        versionMajor: version_major
    )
}

func randomDeviceStateWifiInfo() -> Device.StateWifiInfo {
    let signal: Float = 0.5
    let reserved1 = Data(Array((0..<4)))
    let reserved2 = Data(Array((0..<4)))
    let reserved3 = Data(Array((0..<2)))
    return try! Device.StateWifiInfo(signal: signal, reserved1: reserved1, reserved2: reserved2, reserved3: reserved3)
}

func randomDeviceStateWifiFirmware() -> Device.StateWifiFirmware {
    let build: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    let reserved1 = Data(Array((0..<8)))
    let version_minor: UInt16 = 0x04_00
    let version_major: UInt16 = 0x04_00
    return try! Device.StateWifiFirmware(
        build: build,
        reserved1: reserved1,
        versionMinor: version_minor,
        versionMajor: version_major
    )
}

func randomDeviceSetPower() -> Device.SetPower {
    let level: UInt16 = 0x04_00
    return Device.SetPower(level: level)
}

func randomDeviceStatePower() -> Device.StatePower {
    let level: UInt16 = 0x04_00
    return Device.StatePower(level: level)
}

func randomDeviceSetLabel() -> Device.SetLabel {
    let label: String = "Hello World, 你好,世界"
    return try! Device.SetLabel(label: label)
}

func randomDeviceStateLabel() -> Device.StateLabel {
    let label: String = "Hello World, 你好,世界"
    return try! Device.StateLabel(label: label)
}

func randomDeviceStateVersion() -> Device.StateVersion {
    let vendor: UInt32 = 0x04_01_00_ff
    let product: UInt32 = 0x04_01_00_ff
    let reserved1 = Data(Array((0..<4)))
    return try! Device.StateVersion(vendor: vendor, product: product, reserved1: reserved1)
}

func randomDeviceStateInfo() -> Device.StateInfo {
    let time: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    let uptime: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    let downtime: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    return Device.StateInfo(time: time, uptime: uptime, downtime: downtime)
}

func randomDeviceSetLocation() -> Device.SetLocation {
    let location = Data(Array((0..<16)))
    let label: String = "Hello World, 你好,世界"
    let updated_at: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    return try! Device.SetLocation(location: location, label: label, updatedAt: updated_at)
}

func randomDeviceStateLocation() -> Device.StateLocation {
    let location = Data(Array((0..<16)))
    let label: String = "Hello World, 你好,世界"
    let updated_at: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    return try! Device.StateLocation(location: location, label: label, updatedAt: updated_at)
}

func randomDeviceSetGroup() -> Device.SetGroup {
    let group = Data(Array((0..<16)))
    let label: String = "Hello World, 你好,世界"
    let updated_at: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    return try! Device.SetGroup(group: group, label: label, updatedAt: updated_at)
}

func randomDeviceStateGroup() -> Device.StateGroup {
    let group = Data(Array((0..<16)))
    let label: String = "Hello World, 你好,世界"
    let updated_at: UInt64 = 0x01_00_ff_10_aa_00_01_0a
    return try! Device.StateGroup(group: group, label: label, updatedAt: updated_at)
}

func randomDeviceEchoRequest() -> Device.EchoRequest {
    let payload = Data(Array((0..<64)))
    return try! Device.EchoRequest(payload: payload)
}

func randomDeviceEchoResponse() -> Device.EchoResponse {
    let payload = Data(Array((0..<64)))
    return try! Device.EchoResponse(payload: payload)
}

func randomDeviceStateUnhandled() -> Device.StateUnhandled {
    let unhandled_type: UInt16 = 0x04_00
    return Device.StateUnhandled(unhandledType: unhandled_type)
}
