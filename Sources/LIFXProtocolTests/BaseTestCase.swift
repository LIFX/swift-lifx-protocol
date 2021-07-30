///
///  BaseTestCase.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import XCTest

@testable import LIFXProtocol

class BaseTestCase: XCTestCase {
    let sequence: UInt8 = 99
    let serial = "d073d522628f"
    lazy var target: TargetType = .macAddress(MACAddress(bytes: Data(hexEncoded: serial)!)!)
    let sampleHeader = "2400001400000000d073d522628f00004c4946585632000000000000000000000e000000"
}
