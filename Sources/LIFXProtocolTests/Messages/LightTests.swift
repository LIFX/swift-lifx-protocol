///
///  Light.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Nimble
import XCTest

@testable import LIFXProtocol

class LightTests: BaseTestCase {
    func testLightGetMessage() {
        do {
            let message = Light.GetMessage(target: target, resRequired: false, ackRequired: false, sequence: sequence)

            expect(message.isDeviceMessage).to(beFalse())
            expect(message.isClientMessage).to(beTrue())

            expect(message.isMatch(message)).to(beTrue())
            expect(message.isMatch(Device.AcknowledgementMessage(target: .broadcast))).to(beFalse())

            let data = message.toData()

            expect(data.count).to(equal(Light.GetMessage.size))

            let read = try Light.GetMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.GetMessage.size)))
            expect(read.header.type).to(equal(Light.GetMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testLightSetColorMessage() {
        do {
            let reserved1 = Data(Array((0..<1)))
            let color = defaultColor
            let duration: UInt32 = 0x04_01_00_ff
            let msgPayload = try! Light.SetColor(reserved1: reserved1, color: color, duration: duration)
            let message = Light.SetColorMessage(
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

            expect(data.count).to(equal(Light.SetColorMessage.size))

            let read = try Light.SetColorMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.SetColorMessage.size)))
            expect(read.header.type).to(equal(Light.SetColorMessage.messageType.rawValue))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.color).to(equal(color))
            expect(read.payload.duration).to(equal(duration))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightSetColorMessage() {
        do {
            _ = try Light.SetColorMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.SetColor.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightSetWaveformOptionalMessage() {
        do {
            let reserved1 = Data(Array((0..<1)))
            let transient = true
            let color = defaultColor
            let period: UInt32 = 0x04_01_00_ff
            let cycles: Float = 0.5
            let skew_ratio: Int16 = -9_000
            let waveform = Light.Waveform(rawValue: 0) ?? Light.Waveform(rawValue: 1)!
            let set_hue = true
            let set_saturation = true
            let set_brightness = true
            let set_kelvin = true
            let msgPayload = try! Light.SetWaveformOptional(
                reserved1: reserved1,
                transient: transient,
                color: color,
                period: period,
                cycles: cycles,
                skewRatio: skew_ratio,
                waveform: waveform,
                setHue: set_hue,
                setSaturation: set_saturation,
                setBrightness: set_brightness,
                setKelvin: set_kelvin
            )
            let message = Light.SetWaveformOptionalMessage(
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

            expect(data.count).to(equal(Light.SetWaveformOptionalMessage.size))

            let read = try Light.SetWaveformOptionalMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.SetWaveformOptionalMessage.size)))
            expect(read.header.type).to(equal(Light.SetWaveformOptionalMessage.messageType.rawValue))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.transient).to(equal(transient))
            expect(read.payload.color).to(equal(color))
            expect(read.payload.period).to(equal(period))
            expect(read.payload.cycles).to(equal(cycles))
            expect(read.payload.skewRatio).to(equal(skew_ratio))
            expect(read.payload.waveform).to(equal(waveform))
            expect(read.payload.setHue).to(equal(set_hue))
            expect(read.payload.setSaturation).to(equal(set_saturation))
            expect(read.payload.setBrightness).to(equal(set_brightness))
            expect(read.payload.setKelvin).to(equal(set_kelvin))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightSetWaveformOptionalMessage() {
        do {
            _ = try Light.SetWaveformOptionalMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.SetWaveformOptional.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightSetWaveformMessage() {
        do {
            let reserved1 = Data(Array((0..<1)))
            let transient = true
            let color = defaultColor
            let period: UInt32 = 0x04_01_00_ff
            let cycles: Float = 0.5
            let skew_ratio: Int16 = -9_000
            let waveform = Light.Waveform(rawValue: 0) ?? Light.Waveform(rawValue: 1)!
            let msgPayload = try! Light.SetWaveform(
                reserved1: reserved1,
                transient: transient,
                color: color,
                period: period,
                cycles: cycles,
                skewRatio: skew_ratio,
                waveform: waveform
            )
            let message = Light.SetWaveformMessage(
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

            expect(data.count).to(equal(Light.SetWaveformMessage.size))

            let read = try Light.SetWaveformMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.SetWaveformMessage.size)))
            expect(read.header.type).to(equal(Light.SetWaveformMessage.messageType.rawValue))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.transient).to(equal(transient))
            expect(read.payload.color).to(equal(color))
            expect(read.payload.period).to(equal(period))
            expect(read.payload.cycles).to(equal(cycles))
            expect(read.payload.skewRatio).to(equal(skew_ratio))
            expect(read.payload.waveform).to(equal(waveform))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightSetWaveformMessage() {
        do {
            _ = try Light.SetWaveformMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.SetWaveform.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightGetPowerMessage() {
        do {
            let message = Light.GetPowerMessage(
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

            expect(data.count).to(equal(Light.GetPowerMessage.size))

            let read = try Light.GetPowerMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.GetPowerMessage.size)))
            expect(read.header.type).to(equal(Light.GetPowerMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testLightSetPowerMessage() {
        do {
            let level: UInt16 = 0x04_00
            let duration: UInt32 = 0x04_01_00_ff
            let msgPayload = Light.SetPower(level: level, duration: duration)
            let message = Light.SetPowerMessage(
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

            expect(data.count).to(equal(Light.SetPowerMessage.size))

            let read = try Light.SetPowerMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.SetPowerMessage.size)))
            expect(read.header.type).to(equal(Light.SetPowerMessage.messageType.rawValue))
            expect(read.payload.level).to(equal(level))
            expect(read.payload.duration).to(equal(duration))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightSetPowerMessage() {
        do {
            _ = try Light.SetPowerMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.SetPower.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightStatePowerMessage() {
        do {
            let level: UInt16 = 0x04_00
            let msgPayload = Light.StatePower(level: level)
            let message = Light.StatePowerMessage(
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

            expect(data.count).to(equal(Light.StatePowerMessage.size))

            let read = try Light.StatePowerMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.StatePowerMessage.size)))
            expect(read.header.type).to(equal(Light.StatePowerMessage.messageType.rawValue))
            expect(read.payload.level).to(equal(level))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightStatePowerMessage() {
        do {
            _ = try Light.StatePowerMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.StatePower.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightStateMessage() {
        do {
            let color = defaultColor
            let reserved1 = Data(Array((0..<2)))
            let power: UInt16 = 0x04_00
            let label: String = "Hello World, 你好,世界"
            let reserved2 = Data(Array((0..<8)))
            let msgPayload = try! Light.State(
                color: color,
                reserved1: reserved1,
                power: power,
                label: label,
                reserved2: reserved2
            )
            let message = Light.StateMessage(
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

            expect(data.count).to(equal(Light.StateMessage.size))

            let read = try Light.StateMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.StateMessage.size)))
            expect(read.header.type).to(equal(Light.StateMessage.messageType.rawValue))
            expect(read.payload.color).to(equal(color))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.power).to(equal(power))
            expect(read.payload.label).to(equal(label))
            expect(read.payload.reserved2).to(equal(reserved2))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightStateMessage() {
        do {
            _ = try Light.StateMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.State.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightGetInfraredMessage() {
        do {
            let message = Light.GetInfraredMessage(
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

            expect(data.count).to(equal(Light.GetInfraredMessage.size))

            let read = try Light.GetInfraredMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.GetInfraredMessage.size)))
            expect(read.header.type).to(equal(Light.GetInfraredMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testLightStateInfraredMessage() {
        do {
            let brightness: UInt16 = 0x04_00
            let msgPayload = Light.StateInfrared(brightness: brightness)
            let message = Light.StateInfraredMessage(
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

            expect(data.count).to(equal(Light.StateInfraredMessage.size))

            let read = try Light.StateInfraredMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.StateInfraredMessage.size)))
            expect(read.header.type).to(equal(Light.StateInfraredMessage.messageType.rawValue))
            expect(read.payload.brightness).to(equal(brightness))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightStateInfraredMessage() {
        do {
            _ = try Light.StateInfraredMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.StateInfrared.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightSetInfraredMessage() {
        do {
            let brightness: UInt16 = 0x04_00
            let msgPayload = Light.SetInfrared(brightness: brightness)
            let message = Light.SetInfraredMessage(
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

            expect(data.count).to(equal(Light.SetInfraredMessage.size))

            let read = try Light.SetInfraredMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.SetInfraredMessage.size)))
            expect(read.header.type).to(equal(Light.SetInfraredMessage.messageType.rawValue))
            expect(read.payload.brightness).to(equal(brightness))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightSetInfraredMessage() {
        do {
            _ = try Light.SetInfraredMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.SetInfrared.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightGetHEVCycleMessage() {
        do {
            let message = Light.GetHEVCycleMessage(
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

            expect(data.count).to(equal(Light.GetHEVCycleMessage.size))

            let read = try Light.GetHEVCycleMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.GetHEVCycleMessage.size)))
            expect(read.header.type).to(equal(Light.GetHEVCycleMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testLightSetHEVCycleMessage() {
        do {
            let enable = true
            let duration_s: UInt32 = 0x04_01_00_ff
            let msgPayload = Light.SetHEVCycle(enable: enable, durationS: duration_s)
            let message = Light.SetHEVCycleMessage(
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

            expect(data.count).to(equal(Light.SetHEVCycleMessage.size))

            let read = try Light.SetHEVCycleMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.SetHEVCycleMessage.size)))
            expect(read.header.type).to(equal(Light.SetHEVCycleMessage.messageType.rawValue))
            expect(read.payload.enable).to(equal(enable))
            expect(read.payload.durationS).to(equal(duration_s))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightSetHEVCycleMessage() {
        do {
            _ = try Light.SetHEVCycleMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.SetHEVCycle.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightStateHEVCycleMessage() {
        do {
            let duration_s: UInt32 = 0x04_01_00_ff
            let remaining_s: UInt32 = 0x04_01_00_ff
            let last_power = true
            let msgPayload = Light.StateHEVCycle(durationS: duration_s, remainingS: remaining_s, lastPower: last_power)
            let message = Light.StateHEVCycleMessage(
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

            expect(data.count).to(equal(Light.StateHEVCycleMessage.size))

            let read = try Light.StateHEVCycleMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.StateHEVCycleMessage.size)))
            expect(read.header.type).to(equal(Light.StateHEVCycleMessage.messageType.rawValue))
            expect(read.payload.durationS).to(equal(duration_s))
            expect(read.payload.remainingS).to(equal(remaining_s))
            expect(read.payload.lastPower).to(equal(last_power))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightStateHEVCycleMessage() {
        do {
            _ = try Light.StateHEVCycleMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.StateHEVCycle.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightGetHEVCycleConfigurationMessage() {
        do {
            let message = Light.GetHEVCycleConfigurationMessage(
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

            expect(data.count).to(equal(Light.GetHEVCycleConfigurationMessage.size))

            let read = try Light.GetHEVCycleConfigurationMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.GetHEVCycleConfigurationMessage.size)))
            expect(read.header.type).to(equal(Light.GetHEVCycleConfigurationMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testLightSetHEVCycleConfigurationMessage() {
        do {
            let indication = true
            let duration_s: UInt32 = 0x04_01_00_ff
            let msgPayload = Light.SetHEVCycleConfiguration(indication: indication, durationS: duration_s)
            let message = Light.SetHEVCycleConfigurationMessage(
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

            expect(data.count).to(equal(Light.SetHEVCycleConfigurationMessage.size))

            let read = try Light.SetHEVCycleConfigurationMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.SetHEVCycleConfigurationMessage.size)))
            expect(read.header.type).to(equal(Light.SetHEVCycleConfigurationMessage.messageType.rawValue))
            expect(read.payload.indication).to(equal(indication))
            expect(read.payload.durationS).to(equal(duration_s))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightSetHEVCycleConfigurationMessage() {
        do {
            _ = try Light.SetHEVCycleConfigurationMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.SetHEVCycleConfiguration.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightStateHEVCycleConfigurationMessage() {
        do {
            let indication = true
            let duration_s: UInt32 = 0x04_01_00_ff
            let msgPayload = Light.StateHEVCycleConfiguration(indication: indication, durationS: duration_s)
            let message = Light.StateHEVCycleConfigurationMessage(
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

            expect(data.count).to(equal(Light.StateHEVCycleConfigurationMessage.size))

            let read = try Light.StateHEVCycleConfigurationMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.StateHEVCycleConfigurationMessage.size)))
            expect(read.header.type).to(equal(Light.StateHEVCycleConfigurationMessage.messageType.rawValue))
            expect(read.payload.indication).to(equal(indication))
            expect(read.payload.durationS).to(equal(duration_s))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightStateHEVCycleConfigurationMessage() {
        do {
            _ = try Light.StateHEVCycleConfigurationMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.StateHEVCycleConfiguration.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testLightGetLastHEVCycleResultMessage() {
        do {
            let message = Light.GetLastHEVCycleResultMessage(
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

            expect(data.count).to(equal(Light.GetLastHEVCycleResultMessage.size))

            let read = try Light.GetLastHEVCycleResultMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.GetLastHEVCycleResultMessage.size)))
            expect(read.header.type).to(equal(Light.GetLastHEVCycleResultMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testLightStateLastHEVCycleResultMessage() {
        do {
            let result = Light.LastHEVCycleResult(rawValue: 0) ?? Light.LastHEVCycleResult(rawValue: 1)!
            let msgPayload = Light.StateLastHEVCycleResult(result: result)
            let message = Light.StateLastHEVCycleResultMessage(
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

            expect(data.count).to(equal(Light.StateLastHEVCycleResultMessage.size))

            let read = try Light.StateLastHEVCycleResultMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Light.StateLastHEVCycleResultMessage.size)))
            expect(read.header.type).to(equal(Light.StateLastHEVCycleResultMessage.messageType.rawValue))
            expect(read.payload.result).to(equal(result))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidLightStateLastHEVCycleResultMessage() {
        do {
            _ = try Light.StateLastHEVCycleResultMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Light.StateLastHEVCycleResult.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

}
