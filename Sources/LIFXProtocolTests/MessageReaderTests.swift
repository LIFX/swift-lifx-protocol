///
///  MessageReaderTests.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import ByteBuffer
import Nimble
import XCTest

@testable import LIFXProtocol

class MessagesTests: XCTestCase {
    func testReadOneMessage() {
        let sampleMessage =
            "3800001400000000d073d522628f00004c4946585632000000000000000000000f000000000c6002975f8015000ca710381079165a000200"
        let messages = Messages.read(data: Data(hexEncoded: sampleMessage)!)
        expect(messages.count).to(equal(1))
        let msg = messages.first as? Device.StateHostFirmwareMessage
        expect(msg?.payload.build).to(equal(1_549_343_374_000_000_000))
        expect(msg?.payload.versionMinor).to(equal(0x005a))
        expect(msg?.payload.versionMajor).to(equal(0x0002))
    }

    func testReadTwoMessages() {
        let sampleMessage =
            "3800001400000000d073d522628f00004c4946585632000000000000000000000f000000000c6002975f8015000ca710381079165a0002003800001400000000d073d522628f00004c4946585632000000000000000000000f000000000c6002975f8015000ca710381079165a000200"
        let messages = Messages.read(data: Data(hexEncoded: sampleMessage)!)
        expect(messages.count).to(equal(2))
        let msg1 = messages.first as? Device.StateHostFirmwareMessage
        let msg2 = messages.first as? Device.StateHostFirmwareMessage
        expect(msg1?.payload.build).to(equal(1_549_343_374_000_000_000))
        expect(msg1?.payload.versionMinor).to(equal(0x005a))
        expect(msg1?.payload.versionMajor).to(equal(0x0002))
        expect(msg2?.payload.build).to(equal(1_549_343_374_000_000_000))
        expect(msg2?.payload.versionMinor).to(equal(0x005a))
        expect(msg2?.payload.versionMajor).to(equal(0x0002))
    }
    func testReadWithIncompleteData() {
        let sampleMessage =
            "3800001400000000d073d522628f00004c4946585632000000000000000000000f000000000c6002975f8015000ca710381079165a0002003800001400000000d073d522628f00004c4946585632000000000000000000000f000000000"

        let messages = Messages.read(data: Data(hexEncoded: sampleMessage)!)
        expect(messages.count).to(equal(1))
        let msg = messages.first as? Device.StateHostFirmwareMessage

        expect(msg?.payload.build).to(equal(1_549_343_374_000_000_000))
        expect(msg?.payload.versionMinor).to(equal(0x005a))
        expect(msg?.payload.versionMajor).to(equal(0x0002))
    }
    func testMultiZoneEffectWithExtraPadding() {
        let data =
            "6000001462fb60f6d073d525ad8400004c49465856320101c05476f83b0d0600fd010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        do {
            let message = try Messages.readMessage(data: Data(hexEncoded: data)!)
            expect(message).to(beAnInstanceOf(MultiZone.StateEffectMessage.self))
        } catch let e { XCTFail("\(e)") }
    }
    func testExtendedMultiZoneWithExtraPadding() {
        let data =
            "ba020014669cbca9d073d525ad8400004c49465856320102c097598d600f0600000202002000000020ff7fb7de0000ac0d71841dc50000ac0daa8651b80000ac0de38884ab0000ac0d1b8bb79e0000ac0d548dea910000ac0d8d8f1e850000ac0dc69151780000ac0d54ad3d5a00000b131abb324b0000ba15e2c8283c00006a18a9d61e2d0000191b70e4141e0000c91d37f20a0f00007820000000000000282304ebff3f0000c91d87e0ff5f0000191b09d6ff7f00006a188ccbff9f0000ba1510c1ffbf00000b1393b6ffdf00005b1016acffff0000ac0d05a3f4f80000ac0d7c9e6ff50000ac0df499eaf10000ac0d6b9565ee0000ac0de290e0ea0000ac0d5a8c5be70000ac0dd187d6e30000ac0ddda5e0aa00000b13e8c3eb7100006a18f3e1f5380000c91d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        do {
            let message = try Messages.readMessage(data: Data(hexEncoded: data)!)
            expect(message).to(beAnInstanceOf(MultiZone.ExtendedStateMultiZoneMessage.self))
        } catch let e { XCTFail("\(e)") }
    }
    func testSequence() {
        let msg = Device.AcknowledgementMessage(target: .broadcast, sequence: 50)
        let data = msg.toData()
        let read = try! Messages.readMessage(data: data)
        expect(read.header.sequence).to(equal(50))
    }
    func testAck() {
        let ack = Device.AcknowledgementMessage(target: .broadcast)
        expect(ack.isDeviceMessage).to(beTrue())
    }

    func testSetColorZonesMatching() {
        let msg = MultiZone.SetColorZones(startIndex: 0, endIndex: 0, color: defaultColor, duration: 0, apply: .apply)
            .toMessage(target: .broadcast)
        let msg2 = MultiZone.SetColorZones(startIndex: 5, endIndex: 5, color: defaultColor, duration: 0, apply: .apply)
            .toMessage(target: .broadcast)
        expect(msg.isMatch(msg2)).to(beFalse())
        expect(msg.isMatch(msg)).to(beTrue())
    }
    func testSetLabelLength() {
        // String is longer than 32 bytes
        expect(try? Device.SetLabel(label: "😎🎉😎🎉😎🎉😎🎉😎🎉😎🎉😎🎉😎🎉")).to(beNil())
        // String exactly 32 bytes
        expect(try? Device.SetLabel(label: "😎🎉😎🎉😎🎉😎🎉")).toNot(beNil())
        expect(try? Device.SetLabel(label: "")).toNot(beNil())
    }
    func testBadData() {
        let msg = MultiZone.SetColorZones(startIndex: 0, endIndex: 0, color: defaultColor, duration: 0, apply: .apply)
            .toMessage(target: .broadcast)
        let data = msg.toData()
        // Missing data
        let data1 = data.subdata(in: 0..<data.count - 2)
        // Extra bytes should be fine
        let data2 = data + Data([0x00, 0x00])
        // Missing data but size matches data size
        let data3 = Data([0x31, 0x00]) + data.subdata(in: 2..<data.count - 2)
        do {
            _ = try Messages.readMessage(data: data1)
            XCTFail()
        } catch _ {
            // Expected error
        }
        expect(try? Messages.readMessage(data: data2)).toNot(beNil())
        do {
            _ = try Messages.readMessage(data: data3)
            XCTFail()
        } catch _ {
            // Expected error
        }
    }
    func testStateServiceOptimization() throws {
        let mac = Data(hexEncoded: "138be336cb3d")!
        let hex = "2900001410000000138be336cb3d00000000000000000400000000000000000003000000017cdd0000"
        let data = Data(hexEncoded: hex)!

        let msg = try Messages.readMessage(data: data)
        expect(msg).to(beAnInstanceOf(Device.StateServiceMessage.self))
        expect(msg.header.target[0..<6]) == mac
        let msg2 = try Messages.readMessage(data: data, deserializeStateService: true)
        expect(msg2).to(beAnInstanceOf(Device.StateServiceMessage.self))
        expect(msg2.header.target[0..<6]) == mac
    }

    func testDecodeEchoResponseWithOpaqueBytes() {
        let hex =
            "6400005442524b52d073d500fd9400004c494658563200008436869da05687153b0000004c494658fdfb89119f56871500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        let data = Data(hexEncoded: hex)!
        do {
            let msg = try Messages.readMessage(data: data)
            expect(msg).to(beAnInstanceOf(Device.EchoResponseMessage.self))
        } catch let e { XCTFail("\(e)") }
    }

    func testSetColor() throws {
        let target = Data([0xd0, 0x73, 0xd5, 0x5a, 0xd8, 0x40])
        let hsbk = try Light.HSBK(hue: 5000, saturation: UInt16.max, brightness: UInt16.max, kelvin: 3500)
        let mac = MACAddress(bytes: target)!
        let message = try Light.SetColor(color: hsbk, duration: 0).toMessage(target: .macAddress(mac))
        expect(message.header.target).to(equal(target))
        expect(message.payload.color.hue).to(equal(hsbk.hue))
    }
    func testSetTileState64Matching() throws {
        let rect = try Tile.BufferRect(x: 0, y: 0, width: 8)
        let msg = try Tile.Set64(tileIndex: 0, length: 1, rect: rect, duration: 0, colors: [defaultColor])
            .toMessage(target: .broadcast)
        let msg2 = try Tile.Set64(tileIndex: 1, length: 1, rect: rect, duration: 0, colors: [defaultColor])
            .toMessage(target: .broadcast)
        expect(msg.isMatch(msg2)).to(beFalse())
        expect(msg.isMatch(msg)).to(beTrue())
    }

}
