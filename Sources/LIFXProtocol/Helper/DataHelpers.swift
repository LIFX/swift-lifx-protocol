///
///  DataHelpers.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Foundation

extension UInt16 {
    static func from(data: Data) -> UInt16 {
        var value: UInt16 = 0
        _ = withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0) })
        return value
    }
}
