///
///  Data+Hex.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 27/7/21

import Foundation

extension Data {
    public func hexEncodedString() -> String { return map { String(format: "%02hhx", $0) }.joined() }
    public init?(hexEncoded string: String) {
        var data = Data(capacity: string.count / 2)
        let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex?
            .enumerateMatches(in: string, range: NSRange(string.startIndex..., in: string)) { match, _, _ in
                guard let match = match else { return }
                let byteString = (string as NSString).substring(with: match.range)
                guard let num = UInt8(byteString, radix: 16) else { return }
                data.append(num)
            }
        guard data.count > 0 else { return nil }
        self = data
    }
}
