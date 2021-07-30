///
///  Messages+deviceMessage.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

extension Messages {
    /// Returns a DeviceMessage enum value if the given message came from a device
    public static func deviceMessage(for message: AbstractMessageType) -> DeviceMessage? {
        if let msg = message as? LIFXProtocol.Device.StateServiceMessage { return .deviceStateService(msg) }
        if let msg = message as? LIFXProtocol.Device.StateHostFirmwareMessage { return .deviceStateHostFirmware(msg) }
        if let msg = message as? LIFXProtocol.Device.StateWifiInfoMessage { return .deviceStateWifiInfo(msg) }
        if let msg = message as? LIFXProtocol.Device.StateWifiFirmwareMessage { return .deviceStateWifiFirmware(msg) }
        if let msg = message as? LIFXProtocol.Device.StatePowerMessage { return .deviceStatePower(msg) }
        if let msg = message as? LIFXProtocol.Device.StateLabelMessage { return .deviceStateLabel(msg) }
        if let msg = message as? LIFXProtocol.Device.StateVersionMessage { return .deviceStateVersion(msg) }
        if let msg = message as? LIFXProtocol.Device.StateInfoMessage { return .deviceStateInfo(msg) }
        if let msg = message as? LIFXProtocol.Device.StateLocationMessage { return .deviceStateLocation(msg) }
        if let msg = message as? LIFXProtocol.Device.StateGroupMessage { return .deviceStateGroup(msg) }
        if let msg = message as? LIFXProtocol.Device.StateUnhandledMessage { return .deviceStateUnhandled(msg) }
        if let msg = message as? LIFXProtocol.Light.StatePowerMessage { return .lightStatePower(msg) }
        if let msg = message as? LIFXProtocol.Light.StateMessage { return .lightState(msg) }
        if let msg = message as? LIFXProtocol.Light.StateInfraredMessage { return .lightStateInfrared(msg) }
        if let msg = message as? LIFXProtocol.Light.StateHEVCycleMessage { return .lightStateHevCycle(msg) }
        if let msg = message as? LIFXProtocol.Light.StateHEVCycleConfigurationMessage {
            return .lightStateHevCycleConfiguration(msg)
        }
        if let msg = message as? LIFXProtocol.Light.StateLastHEVCycleResultMessage {
            return .lightStateLastHevCycleResult(msg)
        }
        if let msg = message as? LIFXProtocol.MultiZone.StateZoneMessage { return .multiZoneStateZone(msg) }
        if let msg = message as? LIFXProtocol.MultiZone.StateMultiZoneMessage { return .multiZoneStateMultiZone(msg) }
        if let msg = message as? LIFXProtocol.MultiZone.StateEffectMessage { return .multiZoneStateEffect(msg) }
        if let msg = message as? LIFXProtocol.MultiZone.ExtendedStateMultiZoneMessage {
            return .multiZoneExtendedStateMultiZone(msg)
        }
        if let msg = message as? LIFXProtocol.Relay.StatePowerMessage { return .relayStatePower(msg) }
        if let msg = message as? LIFXProtocol.Tile.StateDeviceChainMessage { return .tileStateDeviceChain(msg) }
        if let msg = message as? LIFXProtocol.Tile.State64Message { return .tileState64(msg) }
        if let msg = message as? LIFXProtocol.Tile.StateEffectMessage { return .tileStateEffect(msg) }
        return nil
    }
}
