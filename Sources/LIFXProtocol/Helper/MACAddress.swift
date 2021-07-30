///
///  MACAddress.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

public struct MACAddress: Hashable, Equatable {
    public static let size = 6
    public let bytes: Data
    public var string: String { return bytes.map({ String(format: "%02hhx", $0) }).joined(separator: ":") }
    public init?(bytes: Data) {
        let trimmedBytes = bytes.filter({ $0 != 0x00 })
        // There could be trailing null bytes, just make sure there aren't filled
        // bytes over 6, and that there is at least one non-zero byte.
        guard bytes.count >= MACAddress.size && trimmedBytes.count <= MACAddress.size && trimmedBytes.count > 0 else {
            return nil
        }
        self.bytes = bytes[0..<MACAddress.size]
    }
}
