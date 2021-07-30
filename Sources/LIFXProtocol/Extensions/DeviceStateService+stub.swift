///
///  DeviceStateService+stub.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 27/7/21

import Foundation

extension Device.StateServiceMessage {
    static func stub(for mac: MACAddress) -> Device.StateServiceMessage {
        Device.StateService(service: .udp, port: 56700).toMessage(target: TargetType.macAddress(mac))
    }
}
