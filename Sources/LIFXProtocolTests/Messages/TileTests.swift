///
///  Tile.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import Nimble
import XCTest

@testable import LIFXProtocol

class TileTests: BaseTestCase {
    func testTileGetDeviceChainMessage() {
        do {
            let message = Tile.GetDeviceChainMessage(
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

            expect(data.count).to(equal(Tile.GetDeviceChainMessage.size))

            let read = try Tile.GetDeviceChainMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Tile.GetDeviceChainMessage.size)))
            expect(read.header.type).to(equal(Tile.GetDeviceChainMessage.messageType.rawValue))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testTileStateDeviceChainMessage() {
        do {
            let start_index: UInt8 = 0x1f
            let tile_devices_count: UInt8 = 16 / 2
            let tile_devices: [Tile.StateDevice] = (0..<tile_devices_count).map { _ in randomTileStateDevice() }
            let msgPayload = try! Tile.StateDeviceChain(startIndex: start_index, tileDevices: tile_devices)
            let message = Tile.StateDeviceChainMessage(
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

            expect(data.count).to(equal(Tile.StateDeviceChainMessage.size))

            let read = try Tile.StateDeviceChainMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Tile.StateDeviceChainMessage.size)))
            expect(read.header.type).to(equal(Tile.StateDeviceChainMessage.messageType.rawValue))
            expect(read.payload.startIndex).to(equal(start_index))
            expect(read.payload.tileDevices).to(equal(tile_devices))
            expect(read.payload.tileDevicesCount).to(equal(tile_devices_count))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidTileStateDeviceChainMessage() {
        do {
            _ = try Tile.StateDeviceChainMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Tile.StateDeviceChain.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testTileSetUserPositionMessage() {
        do {
            let tile_index: UInt8 = 0x1f
            let reserved1 = Data(Array((0..<2)))
            let user_x: Float = 0.5
            let user_y: Float = 0.5
            let msgPayload = try! Tile.SetUserPosition(
                tileIndex: tile_index,
                reserved1: reserved1,
                userX: user_x,
                userY: user_y
            )
            let message = Tile.SetUserPositionMessage(
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

            expect(data.count).to(equal(Tile.SetUserPositionMessage.size))

            let read = try Tile.SetUserPositionMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Tile.SetUserPositionMessage.size)))
            expect(read.header.type).to(equal(Tile.SetUserPositionMessage.messageType.rawValue))
            expect(read.payload.tileIndex).to(equal(tile_index))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.userX).to(equal(user_x))
            expect(read.payload.userY).to(equal(user_y))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidTileSetUserPositionMessage() {
        do {
            _ = try Tile.SetUserPositionMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Tile.SetUserPosition.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testTileGet64Message() {
        do {
            let tile_index: UInt8 = 0x1f
            let length: UInt8 = 0x1f
            let rect = randomTileBufferRect()
            let msgPayload = Tile.Get64(tileIndex: tile_index, length: length, rect: rect)
            let message = Tile.Get64Message(
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

            expect(data.count).to(equal(Tile.Get64Message.size))

            let read = try Tile.Get64Message.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Tile.Get64Message.size)))
            expect(read.header.type).to(equal(Tile.Get64Message.messageType.rawValue))
            expect(read.payload.tileIndex).to(equal(tile_index))
            expect(read.payload.length).to(equal(length))
            expect(read.payload.rect).to(equal(rect))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidTileGet64Message() {
        do {
            _ = try Tile.Get64Message.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Tile.Get64.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testTileState64Message() {
        do {
            let tile_index: UInt8 = 0x1f
            let rect = randomTileBufferRect()
            let colors_count: UInt8 = 64 / 2
            let colors: [Light.HSBK] = (0..<colors_count).map { _ in defaultColor }
            let msgPayload = try! Tile.State64(tileIndex: tile_index, rect: rect, colors: colors)
            let message = Tile.State64Message(
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

            expect(data.count).to(equal(Tile.State64Message.size))

            let read = try Tile.State64Message.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Tile.State64Message.size)))
            expect(read.header.type).to(equal(Tile.State64Message.messageType.rawValue))
            expect(read.payload.tileIndex).to(equal(tile_index))
            expect(read.payload.rect).to(equal(rect))
            expect(read.payload.colors).to(equal(colors))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidTileState64Message() {
        do {
            _ = try Tile.State64Message.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Tile.State64.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testTileSet64Message() {
        do {
            let tile_index: UInt8 = 0x1f
            let length: UInt8 = 0x1f
            let rect = randomTileBufferRect()
            let duration: UInt32 = 0x04_01_00_ff
            let colors_count: UInt8 = 64 / 2
            let colors: [Light.HSBK] = (0..<colors_count).map { _ in defaultColor }
            let msgPayload = try! Tile.Set64(
                tileIndex: tile_index,
                length: length,
                rect: rect,
                duration: duration,
                colors: colors
            )
            let message = Tile.Set64Message(
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

            expect(data.count).to(equal(Tile.Set64Message.size))

            let read = try Tile.Set64Message.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Tile.Set64Message.size)))
            expect(read.header.type).to(equal(Tile.Set64Message.messageType.rawValue))
            expect(read.payload.tileIndex).to(equal(tile_index))
            expect(read.payload.length).to(equal(length))
            expect(read.payload.rect).to(equal(rect))
            expect(read.payload.duration).to(equal(duration))
            expect(read.payload.colors).to(equal(colors))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidTileSet64Message() {
        do {
            _ = try Tile.Set64Message.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Tile.Set64.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testTileGetEffectMessage() {
        do {
            let reserved1 = Data(Array((0..<1)))
            let reserved2 = Data(Array((0..<1)))
            let msgPayload = try! Tile.GetEffect(reserved1: reserved1, reserved2: reserved2)
            let message = Tile.GetEffectMessage(
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

            expect(data.count).to(equal(Tile.GetEffectMessage.size))

            let read = try Tile.GetEffectMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Tile.GetEffectMessage.size)))
            expect(read.header.type).to(equal(Tile.GetEffectMessage.messageType.rawValue))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.reserved2).to(equal(reserved2))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidTileGetEffectMessage() {
        do {
            _ = try Tile.GetEffectMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Tile.GetEffect.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testTileSetEffectMessage() {
        do {
            let reserved1 = Data(Array((0..<1)))
            let reserved2 = Data(Array((0..<1)))
            let settings = randomTileEffectSettings()
            let msgPayload = try! Tile.SetEffect(reserved1: reserved1, reserved2: reserved2, settings: settings)
            let message = Tile.SetEffectMessage(
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

            expect(data.count).to(equal(Tile.SetEffectMessage.size))

            let read = try Tile.SetEffectMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Tile.SetEffectMessage.size)))
            expect(read.header.type).to(equal(Tile.SetEffectMessage.messageType.rawValue))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.reserved2).to(equal(reserved2))
            expect(read.payload.settings).to(equal(settings))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidTileSetEffectMessage() {
        do {
            _ = try Tile.SetEffectMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Tile.SetEffect.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

    func testTileStateEffectMessage() {
        do {
            let reserved1 = Data(Array((0..<1)))
            let settings = randomTileEffectSettings()
            let msgPayload = try! Tile.StateEffect(reserved1: reserved1, settings: settings)
            let message = Tile.StateEffectMessage(
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

            expect(data.count).to(equal(Tile.StateEffectMessage.size))

            let read = try Tile.StateEffectMessage.from(data: data)

            expect(read.header.protocol).to(equal(protocolVersion))
            expect(read.header.ackRequired).to(beFalse())
            expect(read.header.resRequired).to(beFalse())
            guard let target = read.header.targetType else {
                XCTFail("Target shouldn't be nil")
                return
            }
            expect(target).to(equal(self.target))
            expect(read.header.sequence).to(equal(self.sequence))
            expect(read.header.size).to(equal(UInt16(Tile.StateEffectMessage.size)))
            expect(read.header.type).to(equal(Tile.StateEffectMessage.messageType.rawValue))
            expect(read.payload.reserved1).to(equal(reserved1))
            expect(read.payload.settings).to(equal(settings))
        } catch let e { XCTFail("Error \(e)") }
    }

    func testInvalidTileStateEffectMessage() {
        do {
            _ = try Tile.StateEffectMessage.from(data: Data(hexEncoded: sampleHeader)!)
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }

        do {
            _ = try Tile.StateEffect.from(data: Data())
            XCTFail()
        } catch let e { expect(e).to(matchError(DeserializationErrors.insufficientBytes)) }
    }

}
