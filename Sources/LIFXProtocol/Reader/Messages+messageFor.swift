///
///  Messages+messageFor.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

extension Messages {
    /// Mapping of message type enum to the appropriate message implementation.
    public static func message(for type: MessageType) -> AbstractMessageType.Type {
        switch type {
        case .deviceGetService: return LIFXProtocol.Device.GetServiceMessage.self
        case .deviceStateService: return LIFXProtocol.Device.StateServiceMessage.self
        case .deviceGetHostFirmware: return LIFXProtocol.Device.GetHostFirmwareMessage.self
        case .deviceStateHostFirmware: return LIFXProtocol.Device.StateHostFirmwareMessage.self
        case .deviceGetWifiInfo: return LIFXProtocol.Device.GetWifiInfoMessage.self
        case .deviceStateWifiInfo: return LIFXProtocol.Device.StateWifiInfoMessage.self
        case .deviceGetWifiFirmware: return LIFXProtocol.Device.GetWifiFirmwareMessage.self
        case .deviceStateWifiFirmware: return LIFXProtocol.Device.StateWifiFirmwareMessage.self
        case .deviceGetPower: return LIFXProtocol.Device.GetPowerMessage.self
        case .deviceSetPower: return LIFXProtocol.Device.SetPowerMessage.self
        case .deviceStatePower: return LIFXProtocol.Device.StatePowerMessage.self
        case .deviceGetLabel: return LIFXProtocol.Device.GetLabelMessage.self
        case .deviceSetLabel: return LIFXProtocol.Device.SetLabelMessage.self
        case .deviceStateLabel: return LIFXProtocol.Device.StateLabelMessage.self
        case .deviceGetVersion: return LIFXProtocol.Device.GetVersionMessage.self
        case .deviceStateVersion: return LIFXProtocol.Device.StateVersionMessage.self
        case .deviceGetInfo: return LIFXProtocol.Device.GetInfoMessage.self
        case .deviceStateInfo: return LIFXProtocol.Device.StateInfoMessage.self
        case .deviceSetReboot: return LIFXProtocol.Device.SetRebootMessage.self
        case .deviceAcknowledgement: return LIFXProtocol.Device.AcknowledgementMessage.self
        case .deviceGetLocation: return LIFXProtocol.Device.GetLocationMessage.self
        case .deviceSetLocation: return LIFXProtocol.Device.SetLocationMessage.self
        case .deviceStateLocation: return LIFXProtocol.Device.StateLocationMessage.self
        case .deviceGetGroup: return LIFXProtocol.Device.GetGroupMessage.self
        case .deviceSetGroup: return LIFXProtocol.Device.SetGroupMessage.self
        case .deviceStateGroup: return LIFXProtocol.Device.StateGroupMessage.self
        case .deviceEchoRequest: return LIFXProtocol.Device.EchoRequestMessage.self
        case .deviceEchoResponse: return LIFXProtocol.Device.EchoResponseMessage.self
        case .deviceStateUnhandled: return LIFXProtocol.Device.StateUnhandledMessage.self
        case .lightGet: return LIFXProtocol.Light.GetMessage.self
        case .lightSetColor: return LIFXProtocol.Light.SetColorMessage.self
        case .lightSetWaveformOptional: return LIFXProtocol.Light.SetWaveformOptionalMessage.self
        case .lightSetWaveform: return LIFXProtocol.Light.SetWaveformMessage.self
        case .lightGetPower: return LIFXProtocol.Light.GetPowerMessage.self
        case .lightSetPower: return LIFXProtocol.Light.SetPowerMessage.self
        case .lightStatePower: return LIFXProtocol.Light.StatePowerMessage.self
        case .lightState: return LIFXProtocol.Light.StateMessage.self
        case .lightGetInfrared: return LIFXProtocol.Light.GetInfraredMessage.self
        case .lightStateInfrared: return LIFXProtocol.Light.StateInfraredMessage.self
        case .lightSetInfrared: return LIFXProtocol.Light.SetInfraredMessage.self
        case .lightGetHevCycle: return LIFXProtocol.Light.GetHEVCycleMessage.self
        case .lightSetHevCycle: return LIFXProtocol.Light.SetHEVCycleMessage.self
        case .lightStateHevCycle: return LIFXProtocol.Light.StateHEVCycleMessage.self
        case .lightGetHevCycleConfiguration: return LIFXProtocol.Light.GetHEVCycleConfigurationMessage.self
        case .lightSetHevCycleConfiguration: return LIFXProtocol.Light.SetHEVCycleConfigurationMessage.self
        case .lightStateHevCycleConfiguration: return LIFXProtocol.Light.StateHEVCycleConfigurationMessage.self
        case .lightGetLastHevCycleResult: return LIFXProtocol.Light.GetLastHEVCycleResultMessage.self
        case .lightStateLastHevCycleResult: return LIFXProtocol.Light.StateLastHEVCycleResultMessage.self
        case .multiZoneSetColorZones: return LIFXProtocol.MultiZone.SetColorZonesMessage.self
        case .multiZoneGetColorZones: return LIFXProtocol.MultiZone.GetColorZonesMessage.self
        case .multiZoneStateZone: return LIFXProtocol.MultiZone.StateZoneMessage.self
        case .multiZoneStateMultiZone: return LIFXProtocol.MultiZone.StateMultiZoneMessage.self
        case .multiZoneGetEffect: return LIFXProtocol.MultiZone.GetEffectMessage.self
        case .multiZoneSetEffect: return LIFXProtocol.MultiZone.SetEffectMessage.self
        case .multiZoneStateEffect: return LIFXProtocol.MultiZone.StateEffectMessage.self
        case .multiZoneExtendedSetColorZones: return LIFXProtocol.MultiZone.ExtendedSetColorZonesMessage.self
        case .multiZoneExtendedGetColorZones: return LIFXProtocol.MultiZone.ExtendedGetColorZonesMessage.self
        case .multiZoneExtendedStateMultiZone: return LIFXProtocol.MultiZone.ExtendedStateMultiZoneMessage.self
        case .relayGetPower: return LIFXProtocol.Relay.GetPowerMessage.self
        case .relaySetPower: return LIFXProtocol.Relay.SetPowerMessage.self
        case .relayStatePower: return LIFXProtocol.Relay.StatePowerMessage.self
        case .tileGetDeviceChain: return LIFXProtocol.Tile.GetDeviceChainMessage.self
        case .tileStateDeviceChain: return LIFXProtocol.Tile.StateDeviceChainMessage.self
        case .tileSetUserPosition: return LIFXProtocol.Tile.SetUserPositionMessage.self
        case .tileGet64: return LIFXProtocol.Tile.Get64Message.self
        case .tileState64: return LIFXProtocol.Tile.State64Message.self
        case .tileSet64: return LIFXProtocol.Tile.Set64Message.self
        case .tileGetEffect: return LIFXProtocol.Tile.GetEffectMessage.self
        case .tileSetEffect: return LIFXProtocol.Tile.SetEffectMessage.self
        case .tileStateEffect: return LIFXProtocol.Tile.StateEffectMessage.self
        }
    }
}
