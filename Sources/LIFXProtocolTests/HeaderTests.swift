///
///  HeaderTests.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Nimble
import XCTest

@testable import LIFXProtocol

class HeaderTests: XCTestCase {
    func testDecoding() {
        let serial = "d073d522628f"
        let expected = "2400001400000000d073d522628f00004c4946585632000000000000000000000e000000"
        let data = Data(hexEncoded: expected)!
        let header = try? Header.from(data: data)
        expect(header).toNot(beNil())
        expect(header?.size).to(equal(36))
        expect(header?.protocol).to(equal(1024))
        expect(header?.addressable).to(beTrue())
        expect(Data(header!.target).hexEncodedString().hasPrefix(serial)).to(beTrue())
        expect(header?.ackRequired).to(beFalse())
        expect(header?.resRequired).to(beFalse())
        expect(header?.sequence).to(equal(0))
        expect(header?.type).to(equal(14))
        let out = header!.toData()
        let outStr = out.hexEncodedString()
        expect(outStr).to(equal(expected))
    }
    func testInvalidHeaderSize() {
        do {
            _ = try Header.from(
                data: Data(hexEncoded: "2400001400000000d073d522628f00004c4946585632000000000000000000000")!
            )
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testTarget() throws {
        let serial = "d073d522628f"
        let macAddress = Device.AcknowledgementMessage(
            target: .macAddress(MACAddress(bytes: Data(hexEncoded: serial)!)!),
            resRequired: false,
            ackRequired: false,
            sequence: 0
        )
        guard let macTarget = macAddress.header.targetType else {
            XCTFail()
            return
        }
        switch macTarget {
        case .macAddress(let mac):
            expect(mac.bytes).to(equal(Data(hexEncoded: serial)!))
            expect(mac.string).to(equal("d0:73:d5:22:62:8f"))
        default: XCTFail()
        }
        expect(macAddress.header.isBroadcast).to(beFalse())
        let payload = try Light.SetColor(color: defaultColor, duration: 0)
        let broadcast = payload.toMessage(target: .broadcast)
        guard let broadcastTarget = broadcast.header.targetType else {
            XCTFail()
            return
        }
        switch broadcastTarget {
        case .broadcast: break
        default: XCTFail()
        }
        expect(broadcast.header.isBroadcast).to(beTrue())
        let random = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        let header = try Header(
            size: UInt16(Light.SetColorMessage.size),
            addressable: true,
            tagged: false,
            target: random,
            resRequired: false,
            ackRequired: true,
            sequence: 0,
            type: Light.SetColorMessage.messageType.rawValue
        )
        let unknown = Light.SetColorMessage(header: header, payload: payload)
        expect(unknown.header.targetType).to(beNil())
        expect(unknown.header.target).to(equal(random))
        expect(unknown.header.isBroadcast).to(beFalse())
    }
    func testIsResponse() throws {
        let setLabel = try Device.SetLabel(label: "My Label").toMessage(target: .broadcast, sequence: 20)
        let ack = Device.AcknowledgementMessage(target: .broadcast, sequence: 20)
        expect(setLabel.isResponse(ack)).to(beTrue())
        let ack2 = Device.AcknowledgementMessage(target: .broadcast, sequence: 1)
        expect(setLabel.isResponse(ack2)).to(beFalse())
        let getLabel = Device.GetLabelMessage(target: .broadcast, sequence: 90)
        let stateLabel = try Device.StateLabel(label: "My Label").toMessage(target: .broadcast, sequence: 90)
        expect(getLabel.isResponse(stateLabel)).to(beTrue())
        expect(stateLabel.isResponse(getLabel)).to(beFalse())
        let mac = MACAddress(bytes: Data([0xd0, 0x73, 0xd5, 0x12, 0x34, 0x56]))!
        let mac2 = MACAddress(bytes: Data([0xd0, 0x73, 0xd5, 0x12, 0x34, 0x66]))!
        let getLight = Light.GetMessage(target: TargetType.macAddress(mac), sequence: 20)
        let payload = try Light.State(color: defaultColor, power: UInt16.max, label: "My Label")
        let stateLight1 = payload.toMessage(target: .macAddress(mac), sequence: 19)
        expect(getLight.isResponse(stateLight1)).to(beFalse())
        let stateLight2 = payload.toMessage(target: .macAddress(mac2), sequence: 20)
        expect(getLight.isResponse(stateLight2)).to(beFalse())
        let stateLight3 = payload.toMessage(target: .macAddress(mac), sequence: 20)
        expect(getLight.isResponse(stateLight3)).to(beTrue())
        let ack3 = Device.AcknowledgementMessage(target: TargetType.macAddress(mac), sequence: 20)
        expect(getLight.isResponse(ack3)).to(beTrue())
    }

}
