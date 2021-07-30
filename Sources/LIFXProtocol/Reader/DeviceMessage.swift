///
///  DeviceMessage.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

/// Enum that wraps all device message types. Handling all cases in this
/// enum would allow a client to handle all possible messages that can
/// be returned from a device.
public enum DeviceMessage {
    case deviceStateService(LIFXProtocol.Device.StateServiceMessage)
    case deviceStateHostFirmware(LIFXProtocol.Device.StateHostFirmwareMessage)
    case deviceStateWifiInfo(LIFXProtocol.Device.StateWifiInfoMessage)
    case deviceStateWifiFirmware(LIFXProtocol.Device.StateWifiFirmwareMessage)
    case deviceStatePower(LIFXProtocol.Device.StatePowerMessage)
    case deviceStateLabel(LIFXProtocol.Device.StateLabelMessage)
    case deviceStateVersion(LIFXProtocol.Device.StateVersionMessage)
    case deviceStateInfo(LIFXProtocol.Device.StateInfoMessage)
    case deviceStateLocation(LIFXProtocol.Device.StateLocationMessage)
    case deviceStateGroup(LIFXProtocol.Device.StateGroupMessage)
    case deviceStateUnhandled(LIFXProtocol.Device.StateUnhandledMessage)
    case lightStatePower(LIFXProtocol.Light.StatePowerMessage)
    case lightState(LIFXProtocol.Light.StateMessage)
    case lightStateInfrared(LIFXProtocol.Light.StateInfraredMessage)
    case lightStateHevCycle(LIFXProtocol.Light.StateHEVCycleMessage)
    case lightStateHevCycleConfiguration(LIFXProtocol.Light.StateHEVCycleConfigurationMessage)
    case lightStateLastHevCycleResult(LIFXProtocol.Light.StateLastHEVCycleResultMessage)
    case multiZoneStateZone(LIFXProtocol.MultiZone.StateZoneMessage)
    case multiZoneStateMultiZone(LIFXProtocol.MultiZone.StateMultiZoneMessage)
    case multiZoneStateEffect(LIFXProtocol.MultiZone.StateEffectMessage)
    case multiZoneExtendedStateMultiZone(LIFXProtocol.MultiZone.ExtendedStateMultiZoneMessage)
    case relayStatePower(LIFXProtocol.Relay.StatePowerMessage)
    case tileStateDeviceChain(LIFXProtocol.Tile.StateDeviceChainMessage)
    case tileState64(LIFXProtocol.Tile.State64Message)
    case tileStateEffect(LIFXProtocol.Tile.StateEffectMessage)
}
