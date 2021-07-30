///
///  MessageType.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

public enum MessageType: UInt16 {
    case deviceGetService = 2
    case deviceStateService = 3
    case deviceGetHostFirmware = 14
    case deviceStateHostFirmware = 15
    case deviceGetWifiInfo = 16
    case deviceStateWifiInfo = 17
    case deviceGetWifiFirmware = 18
    case deviceStateWifiFirmware = 19
    case deviceGetPower = 20
    case deviceSetPower = 21
    case deviceStatePower = 22
    case deviceGetLabel = 23
    case deviceSetLabel = 24
    case deviceStateLabel = 25
    case deviceGetVersion = 32
    case deviceStateVersion = 33
    case deviceGetInfo = 34
    case deviceStateInfo = 35
    case deviceSetReboot = 38
    case deviceAcknowledgement = 45
    case deviceGetLocation = 48
    case deviceSetLocation = 49
    case deviceStateLocation = 50
    case deviceGetGroup = 51
    case deviceSetGroup = 52
    case deviceStateGroup = 53
    case deviceEchoRequest = 58
    case deviceEchoResponse = 59
    case lightGet = 101
    case lightSetColor = 102
    case lightSetWaveform = 103
    case lightState = 107
    case lightGetPower = 116
    case lightSetPower = 117
    case lightStatePower = 118
    case lightSetWaveformOptional = 119
    case lightGetInfrared = 120
    case lightStateInfrared = 121
    case lightSetInfrared = 122
    case lightGetHevCycle = 142
    case lightSetHevCycle = 143
    case lightStateHevCycle = 144
    case lightGetHevCycleConfiguration = 145
    case lightSetHevCycleConfiguration = 146
    case lightStateHevCycleConfiguration = 147
    case lightGetLastHevCycleResult = 148
    case lightStateLastHevCycleResult = 149
    case deviceStateUnhandled = 223
    case multiZoneSetColorZones = 501
    case multiZoneGetColorZones = 502
    case multiZoneStateZone = 503
    case multiZoneStateMultiZone = 506
    case multiZoneGetEffect = 507
    case multiZoneSetEffect = 508
    case multiZoneStateEffect = 509
    case multiZoneExtendedSetColorZones = 510
    case multiZoneExtendedGetColorZones = 511
    case multiZoneExtendedStateMultiZone = 512
    case tileGetDeviceChain = 701
    case tileStateDeviceChain = 702
    case tileSetUserPosition = 703
    case tileGet64 = 707
    case tileState64 = 711
    case tileSet64 = 715
    case tileGetEffect = 718
    case tileSetEffect = 719
    case tileStateEffect = 720
    case relayGetPower = 816
    case relaySetPower = 817
    case relayStatePower = 818
}
