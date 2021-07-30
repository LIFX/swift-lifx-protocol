///
///  MACAddressTests.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Nimble
import XCTest

@testable import LIFXProtocol

class MACAddressTests: XCTestCase {
    func testMACParsing() {
        let mac1 = MACAddress(bytes: Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
        expect(mac1).to(beNil())
        let mac2 = MACAddress(bytes: Data([0xd0, 0x73, 0xd5, 0x10, 0x36, 0x66, 0x00, 0x00]))
        expect(mac2).toNot(beNil())
        expect(mac2?.string) == "d0:73:d5:10:36:66"
        expect(mac2?.bytes) == Data([0xd0, 0x73, 0xd5, 0x10, 0x36, 0x66])
        let mac3 = MACAddress(bytes: Data([0xd0, 0x73, 0xd5, 0x10, 0x00, 0x66]))
        expect(mac3).toNot(beNil())
        expect(mac3?.string) == "d0:73:d5:10:00:66"
        expect(mac3?.bytes) == Data([0xd0, 0x73, 0xd5, 0x10, 0x00, 0x66])
        let mac4 = MACAddress(bytes: Data([0x00, 0x26, 0xdd, 0x14, 0xc4, 0xee]))
        expect(mac4).toNot(beNil())
    }
}
