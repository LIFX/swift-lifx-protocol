///
///  RelayHelpers.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

@testable import LIFXProtocol

func randomRelaySetPower() -> Relay.SetPower {
    let relay_index: UInt8 = 0x1f
    let level: UInt16 = 0x04_00
    return Relay.SetPower(relayIndex: relay_index, level: level)
}

func randomRelayStatePower() -> Relay.StatePower {
    let relay_index: UInt8 = 0x1f
    let level: UInt16 = 0x04_00
    return Relay.StatePower(relayIndex: relay_index, level: level)
}
