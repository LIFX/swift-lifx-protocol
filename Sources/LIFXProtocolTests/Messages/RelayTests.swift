///
///  Relay.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Nimble
import XCTest

@testable import LIFXProtocol

class RelayTests: BaseTestCase {
    func testRelayGetPowerMessage() {
        do {
            let relay_index: UInt8 = 0x1f
            let msgPayload = Relay.GetPower(relayIndex: relay_index)
            let message = Relay.GetPowerMessage(
                target: target,
                resRequired: false,
                ackRequired: false,
                sequence: sequence,
                payload: msgPayload
            )

            expect(message.isDeviceMessage).to(beFalse())
            expect(message.isClientMessage).to(beTrue())

            expect(message.isMatch(message)).to(beTrue())
            expect(message.isMatch(Device.AcknowledgementMessage(target: .broadcast))).to(beFalse())

            let data = message.toData()

            expect(data.count).to(equal(Relay.GetPowerMessage.size))

            let read = try Relay.GetPowerMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Relay.GetPowerMessage.size)))
            expect(read.header.type).to(equal(Relay.GetPowerMessage.messageType.rawValue))
            expect(read.payload.relayIndex).to(equal(relay_index))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidRelayGetPowerMessage() {
        do {
            _ = try Relay.GetPowerMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Relay.GetPower.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testRelaySetPowerMessage() {
        do {
            let relay_index: UInt8 = 0x1f
            let level: UInt16 = 0x04_00
            let msgPayload = Relay.SetPower(relayIndex: relay_index, level: level)
            let message = Relay.SetPowerMessage(
                target: target,
                resRequired: false,
                ackRequired: false,
                sequence: sequence,
                payload: msgPayload
            )

            expect(message.isDeviceMessage).to(beFalse())
            expect(message.isClientMessage).to(beTrue())

            expect(message.isMatch(message)).to(beTrue())
            expect(message.isMatch(Device.AcknowledgementMessage(target: .broadcast))).to(beFalse())

            let data = message.toData()

            expect(data.count).to(equal(Relay.SetPowerMessage.size))

            let read = try Relay.SetPowerMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Relay.SetPowerMessage.size)))
            expect(read.header.type).to(equal(Relay.SetPowerMessage.messageType.rawValue))
            expect(read.payload.relayIndex).to(equal(relay_index))
            expect(read.payload.level).to(equal(level))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidRelaySetPowerMessage() {
        do {
            _ = try Relay.SetPowerMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Relay.SetPower.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testRelayStatePowerMessage() {
        do {
            let relay_index: UInt8 = 0x1f
            let level: UInt16 = 0x04_00
            let msgPayload = Relay.StatePower(relayIndex: relay_index, level: level)
            let message = Relay.StatePowerMessage(
                target: target,
                resRequired: false,
                ackRequired: false,
                sequence: sequence,
                payload: msgPayload
            )

            expect(Messages.deviceMessage(for: message)).toNot(beNil())
            expect(message.isDeviceMessage).to(beTrue())
            expect(message.isClientMessage).to(beFalse())

            expect(message.isMatch(message)).to(beTrue())
            expect(message.isMatch(Device.AcknowledgementMessage(target: .broadcast))).to(beFalse())

            let data = message.toData()

            expect(data.count).to(equal(Relay.StatePowerMessage.size))

            let read = try Relay.StatePowerMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Relay.StatePowerMessage.size)))
            expect(read.header.type).to(equal(Relay.StatePowerMessage.messageType.rawValue))
            expect(read.payload.relayIndex).to(equal(relay_index))
            expect(read.payload.level).to(equal(level))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidRelayStatePowerMessage() {
        do {
            _ = try Relay.StatePowerMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Relay.StatePower.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

}
