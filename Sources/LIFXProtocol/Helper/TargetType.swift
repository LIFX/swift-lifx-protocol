///
///  TargetType.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

public enum TargetType: Hashable, Equatable {
    case macAddress(MACAddress)
    case broadcast
}

extension Header {
    public static let broadcastTarget = Data(count: 8)
    public var targetType: TargetType? {
        if let mac = MACAddress(bytes: target) {
            return .macAddress(mac)
        } else if target == Header.broadcastTarget {
            return .broadcast
        } else {
            return nil
        }
    }
    public var isBroadcast: Bool {
        guard let target = targetType else { return false }
        switch target {
        case .broadcast: return true
        default: return false
        }
    }
}
