///
///  MultiZone.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Nimble
import XCTest

@testable import LIFXProtocol

class MultiZoneTests: BaseTestCase {
    func testMultiZoneSetColorZonesMessage() {
        do {
            let start_index: UInt8 = 0x1f
            let end_index: UInt8 = 0x1f
            let color = defaultColor
            let duration: UInt32 = 0x04_01_00_ff
            let apply = MultiZone.ApplicationRequest(rawValue: 0) ?? MultiZone.ApplicationRequest(rawValue: 1)!
            let msgPayload = MultiZone.SetColorZones(
                startIndex: start_index,
                endIndex: end_index,
                color: color,
                duration: duration,
                apply: apply
            )
            let message = MultiZone.SetColorZonesMessage(
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

            expect(data.count).to(equal(MultiZone.SetColorZonesMessage.size))

            let read = try MultiZone.SetColorZonesMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(MultiZone.SetColorZonesMessage.size)))
            expect(read.header.type).to(equal(MultiZone.SetColorZonesMessage.messageType.rawValue))
            expect(read.payload.startIndex).to(equal(start_index))
            expect(read.payload.endIndex).to(equal(end_index))
            expect(read.payload.color).to(equal(color))
            expect(read.payload.duration).to(equal(duration))
            expect(read.payload.apply).to(equal(apply))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidMultiZoneSetColorZonesMessage() {
        do {
            _ = try MultiZone.SetColorZonesMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try MultiZone.SetColorZones.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testMultiZoneGetColorZonesMessage() {
        do {
            let start_index: UInt8 = 0x1f
            let end_index: UInt8 = 0x1f
            let msgPayload = MultiZone.GetColorZones(startIndex: start_index, endIndex: end_index)
            let message = MultiZone.GetColorZonesMessage(
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

            expect(data.count).to(equal(MultiZone.GetColorZonesMessage.size))

            let read = try MultiZone.GetColorZonesMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(MultiZone.GetColorZonesMessage.size)))
            expect(read.header.type).to(equal(MultiZone.GetColorZonesMessage.messageType.rawValue))
            expect(read.payload.startIndex).to(equal(start_index))
            expect(read.payload.endIndex).to(equal(end_index))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidMultiZoneGetColorZonesMessage() {
        do {
            _ = try MultiZone.GetColorZonesMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try MultiZone.GetColorZones.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testMultiZoneStateZoneMessage() {
        do {
            let count: UInt8 = 0x10
            let index: UInt8 = 0x1f
            let color = defaultColor
            let msgPayload = MultiZone.StateZone(count: count, index: index, color: color)
            let message = MultiZone.StateZoneMessage(
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

            expect(data.count).to(equal(MultiZone.StateZoneMessage.size))

            let read = try MultiZone.StateZoneMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(MultiZone.StateZoneMessage.size)))
            expect(read.header.type).to(equal(MultiZone.StateZoneMessage.messageType.rawValue))
            expect(read.payload.count).to(equal(count))
            expect(read.payload.index).to(equal(index))
            expect(read.payload.color).to(equal(color))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidMultiZoneStateZoneMessage() {
        do {
            _ = try MultiZone.StateZoneMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try MultiZone.StateZone.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testMultiZoneStateMultiZoneMessage() {
        do {
            let count: UInt8 = 0x10
            let index: UInt8 = 0x1f
            let colors_count: UInt8 = 8 / 2
            let colors: [Light.HSBK] = (0..<colors_count).map { _ in defaultColor }
            let msgPayload = try! MultiZone.StateMultiZone(count: count, index: index, colors: colors)
            let message = MultiZone.StateMultiZoneMessage(
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

            expect(data.count).to(equal(MultiZone.StateMultiZoneMessage.size))

            let read = try MultiZone.StateMultiZoneMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(MultiZone.StateMultiZoneMessage.size)))
            expect(read.header.type).to(equal(MultiZone.StateMultiZoneMessage.messageType.rawValue))
            expect(read.payload.count).to(equal(count))
            expect(read.payload.index).to(equal(index))
            expect(read.payload.colors).to(equal(colors))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidMultiZoneStateMultiZoneMessage() {
        do {
            _ = try MultiZone.StateMultiZoneMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try MultiZone.StateMultiZone.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testMultiZoneGetEffectMessage() {
        do {
            let message = MultiZone.GetEffectMessage(
                target: target,
                resRequired: false,
                ackRequired: false,
                sequence: sequence
            )

            expect(message.isDeviceMessage).to(beFalse())
            expect(message.isClientMessage).to(beTrue())

            expect(message.isMatch(message)).to(beTrue())
            expect(message.isMatch(Device.AcknowledgementMessage(target: .broadcast))).to(beFalse())

            let data = message.toData()

            expect(data.count).to(equal(MultiZone.GetEffectMessage.size))

            let read = try MultiZone.GetEffectMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(MultiZone.GetEffectMessage.size)))
            expect(read.header.type).to(equal(MultiZone.GetEffectMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testMultiZoneSetEffectMessage() {
        do {
            let settings = randomMultiZoneEffectSettings()
            let msgPayload = MultiZone.SetEffect(settings: settings)
            let message = MultiZone.SetEffectMessage(
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

            expect(data.count).to(equal(MultiZone.SetEffectMessage.size))

            let read = try MultiZone.SetEffectMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(MultiZone.SetEffectMessage.size)))
            expect(read.header.type).to(equal(MultiZone.SetEffectMessage.messageType.rawValue))
            expect(read.payload.settings).to(equal(settings))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidMultiZoneSetEffectMessage() {
        do {
            _ = try MultiZone.SetEffectMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try MultiZone.SetEffect.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testMultiZoneStateEffectMessage() {
        do {
            let settings = randomMultiZoneEffectSettings()
            let msgPayload = MultiZone.StateEffect(settings: settings)
            let message = MultiZone.StateEffectMessage(
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

            expect(data.count).to(equal(MultiZone.StateEffectMessage.size))

            let read = try MultiZone.StateEffectMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(MultiZone.StateEffectMessage.size)))
            expect(read.header.type).to(equal(MultiZone.StateEffectMessage.messageType.rawValue))
            expect(read.payload.settings).to(equal(settings))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidMultiZoneStateEffectMessage() {
        do {
            _ = try MultiZone.StateEffectMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try MultiZone.StateEffect.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testMultiZoneExtendedSetColorZonesMessage() {
        do {
            let duration: UInt32 = 0x04_01_00_ff
            let apply =
                MultiZone.ExtendedApplicationRequest(rawValue: 0) ?? MultiZone.ExtendedApplicationRequest(rawValue: 1)!
            let index: UInt16 = 0x04_00
            let colors_count: UInt8 = 82 / 2
            let colors: [Light.HSBK] = (0..<colors_count).map { _ in defaultColor }
            let msgPayload = try! MultiZone.ExtendedSetColorZones(
                duration: duration,
                apply: apply,
                index: index,
                colors: colors
            )
            let message = MultiZone.ExtendedSetColorZonesMessage(
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

            expect(data.count).to(equal(MultiZone.ExtendedSetColorZonesMessage.size))

            let read = try MultiZone.ExtendedSetColorZonesMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(MultiZone.ExtendedSetColorZonesMessage.size)))
            expect(read.header.type).to(equal(MultiZone.ExtendedSetColorZonesMessage.messageType.rawValue))
            expect(read.payload.duration).to(equal(duration))
            expect(read.payload.apply).to(equal(apply))
            expect(read.payload.index).to(equal(index))
            expect(read.payload.colorsCount).to(equal(colors_count))
            expect(read.payload.colors).to(equal(colors))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidMultiZoneExtendedSetColorZonesMessage() {
        do {
            _ = try MultiZone.ExtendedSetColorZonesMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try MultiZone.ExtendedSetColorZones.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testMultiZoneExtendedGetColorZonesMessage() {
        do {
            let message = MultiZone.ExtendedGetColorZonesMessage(
                target: target,
                resRequired: false,
                ackRequired: false,
                sequence: sequence
            )

            expect(message.isDeviceMessage).to(beFalse())
            expect(message.isClientMessage).to(beTrue())

            expect(message.isMatch(message)).to(beTrue())
            expect(message.isMatch(Device.AcknowledgementMessage(target: .broadcast))).to(beFalse())

            let data = message.toData()

            expect(data.count).to(equal(MultiZone.ExtendedGetColorZonesMessage.size))

            let read = try MultiZone.ExtendedGetColorZonesMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(MultiZone.ExtendedGetColorZonesMessage.size)))
            expect(read.header.type).to(equal(MultiZone.ExtendedGetColorZonesMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testMultiZoneExtendedStateMultiZoneMessage() {
        do {
            let count: UInt16 = 0x04_00
            let index: UInt16 = 0x04_00
            let colors_count: UInt8 = 82 / 2
            let colors: [Light.HSBK] = (0..<colors_count).map { _ in defaultColor }
            let msgPayload = try! MultiZone.ExtendedStateMultiZone(count: count, index: index, colors: colors)
            let message = MultiZone.ExtendedStateMultiZoneMessage(
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

            expect(data.count).to(equal(MultiZone.ExtendedStateMultiZoneMessage.size))

            let read = try MultiZone.ExtendedStateMultiZoneMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(MultiZone.ExtendedStateMultiZoneMessage.size)))
            expect(read.header.type).to(equal(MultiZone.ExtendedStateMultiZoneMessage.messageType.rawValue))
            expect(read.payload.count).to(equal(count))
            expect(read.payload.index).to(equal(index))
            expect(read.payload.colorsCount).to(equal(colors_count))
            expect(read.payload.colors).to(equal(colors))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidMultiZoneExtendedStateMultiZoneMessage() {
        do {
            _ = try MultiZone.ExtendedStateMultiZoneMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try MultiZone.ExtendedStateMultiZone.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

}
