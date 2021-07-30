///
///  LightHSBKTests.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Nimble
import XCTest

@testable import LIFXProtocol

class LightHSBKTests: XCTestCase {
    func testHSBK() {
        let color = try? Light.HSBK(hue: 500, saturation: 10_000, brightness: 50_000, kelvin: 3500)
        expect(color?.hue).to(equal(500))
        expect(color?.saturation).to(equal(10_000))
        expect(color?.brightness).to(equal(50_000))
        expect(color?.kelvin).to(equal(3500))
        let data = color!.toData()
        let parsed = try? Light.HSBK.from(data: data)
        expect(parsed?.hue).to(equal(500))
        expect(parsed?.saturation).to(equal(10_000))
        expect(parsed?.brightness).to(equal(50_000))
        expect(parsed?.kelvin).to(equal(3500))
    }
}
