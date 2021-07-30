import Foundation

extension Data {
    func hexEncodedString() -> String { return map { String(format: "%02hhx", $0) }.joined() }
    static func fromHexEncoded(string: String) -> Data? {
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
        return data
    }
}
