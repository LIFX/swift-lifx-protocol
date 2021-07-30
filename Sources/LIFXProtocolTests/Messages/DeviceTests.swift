///
///  Device.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Nimble
import XCTest

@testable import LIFXProtocol

class DeviceTests: BaseTestCase {
    func testDeviceGetServiceMessage() {
        do {
            let message = Device.GetServiceMessage(
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

            expect(data.count).to(equal(Device.GetServiceMessage.size))

            let read = try Device.GetServiceMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.GetServiceMessage.size)))
            expect(read.header.type).to(equal(Device.GetServiceMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceStateServiceMessage() {
        do {
            let service = Device.Service(rawValue: 0) ?? Device.Service(rawValue: 1)!
            let port: UInt32 = 0x04_01_00_ff
            let msgPayload = Device.StateService(service: service, port: port)
            let message = Device.StateServiceMessage(
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

            expect(data.count).to(equal(Device.StateServiceMessage.size))

            let read = try Device.StateServiceMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StateServiceMessage.size)))
            expect(read.header.type).to(equal(Device.StateServiceMessage.messageType.rawValue))
            expect(read.payload.service).to(equal(service))
            expect(read.payload.port).to(equal(port))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStateServiceMessage() {
        do {
            _ = try Device.StateServiceMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StateService.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceGetHostFirmwareMessage() {
        do {
            let message = Device.GetHostFirmwareMessage(
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

            expect(data.count).to(equal(Device.GetHostFirmwareMessage.size))

            let read = try Device.GetHostFirmwareMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.GetHostFirmwareMessage.size)))
            expect(read.header.type).to(equal(Device.GetHostFirmwareMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceStateHostFirmwareMessage() {
        do {
            let build: UInt64 = 0x01_00_ff_10_aa_00_01_0a
            let reserved1 = Data(Array((0..<8)))
            let version_minor: UInt16 = 0x04_00
            let version_major: UInt16 = 0x04_00
            let msgPayload = try! Device.StateHostFirmware(
                build: build,
                reserved1: reserved1,
                versionMinor: version_minor,
                versionMajor: version_major
            )
            let message = Device.StateHostFirmwareMessage(
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

            expect(data.count).to(equal(Device.StateHostFirmwareMessage.size))

            let read = try Device.StateHostFirmwareMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StateHostFirmwareMessage.size)))
            expect(read.header.type).to(equal(Device.StateHostFirmwareMessage.messageType.rawValue))
            expect(read.payload.build).to(equal(build))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.versionMinor).to(equal(version_minor))
            expect(read.payload.versionMajor).to(equal(version_major))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStateHostFirmwareMessage() {
        do {
            _ = try Device.StateHostFirmwareMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StateHostFirmware.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceGetWifiInfoMessage() {
        do {
            let message = Device.GetWifiInfoMessage(
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

            expect(data.count).to(equal(Device.GetWifiInfoMessage.size))

            let read = try Device.GetWifiInfoMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.GetWifiInfoMessage.size)))
            expect(read.header.type).to(equal(Device.GetWifiInfoMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceStateWifiInfoMessage() {
        do {
            let signal: Float = 0.5
            let reserved1 = Data(Array((0..<4)))
            let reserved2 = Data(Array((0..<4)))
            let reserved3 = Data(Array((0..<2)))
            let msgPayload = try! Device.StateWifiInfo(
                signal: signal,
                reserved1: reserved1,
                reserved2: reserved2,
                reserved3: reserved3
            )
            let message = Device.StateWifiInfoMessage(
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

            expect(data.count).to(equal(Device.StateWifiInfoMessage.size))

            let read = try Device.StateWifiInfoMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StateWifiInfoMessage.size)))
            expect(read.header.type).to(equal(Device.StateWifiInfoMessage.messageType.rawValue))
            expect(read.payload.signal).to(equal(signal))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.reserved2).to(equal(reserved2))
            expect(read.payload.reserved3).to(equal(reserved3))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStateWifiInfoMessage() {
        do {
            _ = try Device.StateWifiInfoMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StateWifiInfo.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceGetWifiFirmwareMessage() {
        do {
            let message = Device.GetWifiFirmwareMessage(
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

            expect(data.count).to(equal(Device.GetWifiFirmwareMessage.size))

            let read = try Device.GetWifiFirmwareMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.GetWifiFirmwareMessage.size)))
            expect(read.header.type).to(equal(Device.GetWifiFirmwareMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceStateWifiFirmwareMessage() {
        do {
            let build: UInt64 = 0x01_00_ff_10_aa_00_01_0a
            let reserved1 = Data(Array((0..<8)))
            let version_minor: UInt16 = 0x04_00
            let version_major: UInt16 = 0x04_00
            let msgPayload = try! Device.StateWifiFirmware(
                build: build,
                reserved1: reserved1,
                versionMinor: version_minor,
                versionMajor: version_major
            )
            let message = Device.StateWifiFirmwareMessage(
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

            expect(data.count).to(equal(Device.StateWifiFirmwareMessage.size))

            let read = try Device.StateWifiFirmwareMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StateWifiFirmwareMessage.size)))
            expect(read.header.type).to(equal(Device.StateWifiFirmwareMessage.messageType.rawValue))
            expect(read.payload.build).to(equal(build))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.versionMinor).to(equal(version_minor))
            expect(read.payload.versionMajor).to(equal(version_major))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStateWifiFirmwareMessage() {
        do {
            _ = try Device.StateWifiFirmwareMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StateWifiFirmware.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceGetPowerMessage() {
        do {
            let message = Device.GetPowerMessage(
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

            expect(data.count).to(equal(Device.GetPowerMessage.size))

            let read = try Device.GetPowerMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.GetPowerMessage.size)))
            expect(read.header.type).to(equal(Device.GetPowerMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceSetPowerMessage() {
        do {
            let level: UInt16 = 0x04_00
            let msgPayload = Device.SetPower(level: level)
            let message = Device.SetPowerMessage(
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

            expect(data.count).to(equal(Device.SetPowerMessage.size))

            let read = try Device.SetPowerMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.SetPowerMessage.size)))
            expect(read.header.type).to(equal(Device.SetPowerMessage.messageType.rawValue))
            expect(read.payload.level).to(equal(level))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceSetPowerMessage() {
        do {
            _ = try Device.SetPowerMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.SetPower.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceStatePowerMessage() {
        do {
            let level: UInt16 = 0x04_00
            let msgPayload = Device.StatePower(level: level)
            let message = Device.StatePowerMessage(
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

            expect(data.count).to(equal(Device.StatePowerMessage.size))

            let read = try Device.StatePowerMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StatePowerMessage.size)))
            expect(read.header.type).to(equal(Device.StatePowerMessage.messageType.rawValue))
            expect(read.payload.level).to(equal(level))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStatePowerMessage() {
        do {
            _ = try Device.StatePowerMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StatePower.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceGetLabelMessage() {
        do {
            let message = Device.GetLabelMessage(
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

            expect(data.count).to(equal(Device.GetLabelMessage.size))

            let read = try Device.GetLabelMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.GetLabelMessage.size)))
            expect(read.header.type).to(equal(Device.GetLabelMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceSetLabelMessage() {
        do {
            let label: String = "Hello World, 你好,世界"
            let msgPayload = try! Device.SetLabel(label: label)
            let message = Device.SetLabelMessage(
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

            expect(data.count).to(equal(Device.SetLabelMessage.size))

            let read = try Device.SetLabelMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.SetLabelMessage.size)))
            expect(read.header.type).to(equal(Device.SetLabelMessage.messageType.rawValue))
            expect(read.payload.label).to(equal(label))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceSetLabelMessage() {
        do {
            _ = try Device.SetLabelMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.SetLabel.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceStateLabelMessage() {
        do {
            let label: String = "Hello World, 你好,世界"
            let msgPayload = try! Device.StateLabel(label: label)
            let message = Device.StateLabelMessage(
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

            expect(data.count).to(equal(Device.StateLabelMessage.size))

            let read = try Device.StateLabelMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StateLabelMessage.size)))
            expect(read.header.type).to(equal(Device.StateLabelMessage.messageType.rawValue))
            expect(read.payload.label).to(equal(label))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStateLabelMessage() {
        do {
            _ = try Device.StateLabelMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StateLabel.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceGetVersionMessage() {
        do {
            let message = Device.GetVersionMessage(
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

            expect(data.count).to(equal(Device.GetVersionMessage.size))

            let read = try Device.GetVersionMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.GetVersionMessage.size)))
            expect(read.header.type).to(equal(Device.GetVersionMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceStateVersionMessage() {
        do {
            let vendor: UInt32 = 0x04_01_00_ff
            let product: UInt32 = 0x04_01_00_ff
            let reserved1 = Data(Array((0..<4)))
            let msgPayload = try! Device.StateVersion(vendor: vendor, product: product, reserved1: reserved1)
            let message = Device.StateVersionMessage(
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

            expect(data.count).to(equal(Device.StateVersionMessage.size))

            let read = try Device.StateVersionMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StateVersionMessage.size)))
            expect(read.header.type).to(equal(Device.StateVersionMessage.messageType.rawValue))
            expect(read.payload.vendor).to(equal(vendor))
            expect(read.payload.product).to(equal(product))
            expect(read.payload.reserved1).to(equal(reserved1))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStateVersionMessage() {
        do {
            _ = try Device.StateVersionMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StateVersion.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceGetInfoMessage() {
        do {
            let message = Device.GetInfoMessage(
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

            expect(data.count).to(equal(Device.GetInfoMessage.size))

            let read = try Device.GetInfoMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.GetInfoMessage.size)))
            expect(read.header.type).to(equal(Device.GetInfoMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceStateInfoMessage() {
        do {
            let time: UInt64 = 0x01_00_ff_10_aa_00_01_0a
            let uptime: UInt64 = 0x01_00_ff_10_aa_00_01_0a
            let downtime: UInt64 = 0x01_00_ff_10_aa_00_01_0a
            let msgPayload = Device.StateInfo(time: time, uptime: uptime, downtime: downtime)
            let message = Device.StateInfoMessage(
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

            expect(data.count).to(equal(Device.StateInfoMessage.size))

            let read = try Device.StateInfoMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StateInfoMessage.size)))
            expect(read.header.type).to(equal(Device.StateInfoMessage.messageType.rawValue))
            expect(read.payload.time).to(equal(time))
            expect(read.payload.uptime).to(equal(uptime))
            expect(read.payload.downtime).to(equal(downtime))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStateInfoMessage() {
        do {
            _ = try Device.StateInfoMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StateInfo.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceSetRebootMessage() {
        do {
            let message = Device.SetRebootMessage(
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

            expect(data.count).to(equal(Device.SetRebootMessage.size))

            let read = try Device.SetRebootMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.SetRebootMessage.size)))
            expect(read.header.type).to(equal(Device.SetRebootMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceAcknowledgementMessage() {
        do {
            let message = Device.AcknowledgementMessage(
                target: target,
                resRequired: false,
                ackRequired: false,
                sequence: sequence
            )

            expect(message.isDeviceMessage).to(beTrue())
            expect(message.isClientMessage).to(beFalse())

            expect(message.isMatch(message)).to(beTrue())

            let data = message.toData()

            expect(data.count).to(equal(Device.AcknowledgementMessage.size))

            let read = try Device.AcknowledgementMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.AcknowledgementMessage.size)))
            expect(read.header.type).to(equal(Device.AcknowledgementMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceGetLocationMessage() {
        do {
            let message = Device.GetLocationMessage(
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

            expect(data.count).to(equal(Device.GetLocationMessage.size))

            let read = try Device.GetLocationMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.GetLocationMessage.size)))
            expect(read.header.type).to(equal(Device.GetLocationMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceSetLocationMessage() {
        do {
            let location = Data(Array((0..<16)))
            let label: String = "Hello World, 你好,世界"
            let updated_at: UInt64 = 0x01_00_ff_10_aa_00_01_0a
            let msgPayload = try! Device.SetLocation(location: location, label: label, updatedAt: updated_at)
            let message = Device.SetLocationMessage(
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

            expect(data.count).to(equal(Device.SetLocationMessage.size))

            let read = try Device.SetLocationMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.SetLocationMessage.size)))
            expect(read.header.type).to(equal(Device.SetLocationMessage.messageType.rawValue))
            expect(read.payload.location).to(equal(location))
            expect(read.payload.label).to(equal(label))
            expect(read.payload.updatedAt).to(equal(updated_at))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceSetLocationMessage() {
        do {
            _ = try Device.SetLocationMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.SetLocation.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceStateLocationMessage() {
        do {
            let location = Data(Array((0..<16)))
            let label: String = "Hello World, 你好,世界"
            let updated_at: UInt64 = 0x01_00_ff_10_aa_00_01_0a
            let msgPayload = try! Device.StateLocation(location: location, label: label, updatedAt: updated_at)
            let message = Device.StateLocationMessage(
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

            expect(data.count).to(equal(Device.StateLocationMessage.size))

            let read = try Device.StateLocationMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StateLocationMessage.size)))
            expect(read.header.type).to(equal(Device.StateLocationMessage.messageType.rawValue))
            expect(read.payload.location).to(equal(location))
            expect(read.payload.label).to(equal(label))
            expect(read.payload.updatedAt).to(equal(updated_at))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStateLocationMessage() {
        do {
            _ = try Device.StateLocationMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StateLocation.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceGetGroupMessage() {
        do {
            let message = Device.GetGroupMessage(
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

            expect(data.count).to(equal(Device.GetGroupMessage.size))

            let read = try Device.GetGroupMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.GetGroupMessage.size)))
            expect(read.header.type).to(equal(Device.GetGroupMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testDeviceSetGroupMessage() {
        do {
            let group = Data(Array((0..<16)))
            let label: String = "Hello World, 你好,世界"
            let updated_at: UInt64 = 0x01_00_ff_10_aa_00_01_0a
            let msgPayload = try! Device.SetGroup(group: group, label: label, updatedAt: updated_at)
            let message = Device.SetGroupMessage(
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

            expect(data.count).to(equal(Device.SetGroupMessage.size))

            let read = try Device.SetGroupMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.SetGroupMessage.size)))
            expect(read.header.type).to(equal(Device.SetGroupMessage.messageType.rawValue))
            expect(read.payload.group).to(equal(group))
            expect(read.payload.label).to(equal(label))
            expect(read.payload.updatedAt).to(equal(updated_at))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceSetGroupMessage() {
        do {
            _ = try Device.SetGroupMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.SetGroup.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceStateGroupMessage() {
        do {
            let group = Data(Array((0..<16)))
            let label: String = "Hello World, 你好,世界"
            let updated_at: UInt64 = 0x01_00_ff_10_aa_00_01_0a
            let msgPayload = try! Device.StateGroup(group: group, label: label, updatedAt: updated_at)
            let message = Device.StateGroupMessage(
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

            expect(data.count).to(equal(Device.StateGroupMessage.size))

            let read = try Device.StateGroupMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StateGroupMessage.size)))
            expect(read.header.type).to(equal(Device.StateGroupMessage.messageType.rawValue))
            expect(read.payload.group).to(equal(group))
            expect(read.payload.label).to(equal(label))
            expect(read.payload.updatedAt).to(equal(updated_at))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStateGroupMessage() {
        do {
            _ = try Device.StateGroupMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StateGroup.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceEchoRequestMessage() {
        do {
            let payload = Data(Array((0..<64)))
            let msgPayload = try! Device.EchoRequest(payload: payload)
            let message = Device.EchoRequestMessage(
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

            expect(data.count).to(equal(Device.EchoRequestMessage.size))

            let read = try Device.EchoRequestMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.EchoRequestMessage.size)))
            expect(read.header.type).to(equal(Device.EchoRequestMessage.messageType.rawValue))
            expect(read.payload.payload).to(equal(payload))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceEchoRequestMessage() {
        do {
            _ = try Device.EchoRequestMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.EchoRequest.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceEchoResponseMessage() {
        do {
            let payload = Data(Array((0..<64)))
            let msgPayload = try! Device.EchoResponse(payload: payload)
            let message = Device.EchoResponseMessage(
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

            expect(data.count).to(equal(Device.EchoResponseMessage.size))

            let read = try Device.EchoResponseMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.EchoResponseMessage.size)))
            expect(read.header.type).to(equal(Device.EchoResponseMessage.messageType.rawValue))
            expect(read.payload.payload).to(equal(payload))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceEchoResponseMessage() {
        do {
            _ = try Device.EchoResponseMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.EchoResponse.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testDeviceStateUnhandledMessage() {
        do {
            let unhandled_type: UInt16 = 0x04_00
            let msgPayload = Device.StateUnhandled(unhandledType: unhandled_type)
            let message = Device.StateUnhandledMessage(
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

            expect(data.count).to(equal(Device.StateUnhandledMessage.size))

            let read = try Device.StateUnhandledMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Device.StateUnhandledMessage.size)))
            expect(read.header.type).to(equal(Device.StateUnhandledMessage.messageType.rawValue))
            expect(read.payload.unhandledType).to(equal(unhandled_type))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidDeviceStateUnhandledMessage() {
        do {
            _ = try Device.StateUnhandledMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Device.StateUnhandled.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

}
