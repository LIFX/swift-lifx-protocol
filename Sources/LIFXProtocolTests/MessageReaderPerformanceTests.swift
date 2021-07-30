///
///  MessageReaderPerformanceTests.swift
///  LIFXProtocolTests
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 20/1/21

import Nimble
import XCTest

@testable import LIFXProtocol

extension Data { static func random(bytes: Int) -> Data { Data((0..<bytes).map { _ in UInt8.random(in: 0...255) }) } }

extension MACAddress { static func random() -> MACAddress { MACAddress(bytes: Data.random(bytes: 6))! } }

class MessageReaderPerformanceTests: XCTestCase {
    func stateServiceMessages() -> [AbstractMessageType] {
        let payload = Device.StateService(service: .udp, port: 56700)
        return (0..<100).map { _ in payload.toMessage(target: TargetType.macAddress(MACAddress.random())) }
    }
    func stateServiceData() -> Data {
        let messages = stateServiceMessages()
        return Data(messages.map { $0.toData() }.flatMap { $0 })
    }
    func testReadStateService() {
        let data = stateServiceData()
        measure {
            let messages = Messages.read(data: data)
            expect(messages.count) == 100
            expect(messages.allSatisfy({ $0 is Device.StateServiceMessage })) == true
        }
    }
    func testReadState64() throws {
        let data = try tileData()
        measure {
            let messages = Messages.read(data: data)
            expect(messages.count) == 100
            expect(messages.allSatisfy({ $0 is Tile.State64Message })) == true
        }
    }
    func testWriteStateService() throws {
        let messages = stateServiceMessages()
        var allData: [Data] = []
        measure {
            allData = messages.map { $0.toData() }
            expect(allData.count) == 100
        }
        let data = Data(allData.flatMap { $0 })
        expect(data) == Data(messages.map { $0.toData() }.flatMap { $0 })
    }
    func testWriteState64() throws {
        let messages = try tileMessages()
        var allData: [Data] = []
        measure {
            allData = messages.map { $0.toData() }
            expect(allData.count) == 100
        }
        let data = Data(allData.flatMap { $0 })
        expect(data) == Data(messages.map { $0.toData() }.flatMap { $0 })
    }
    func tileData() throws -> Data {
        let messages = try tileMessages()
        return Data(messages.map { $0.toData() }.flatMap { $0 })
    }

    func tileMessages() throws -> [AbstractMessageType] {
        let payload = try Tile.State64(
            tileIndex: 0,
            rect: .init(x: 0, y: 0, width: 8),
            colors: (0..<64).map { i in try Light.HSBK(hue: i, saturation: i, brightness: i, kelvin: 3500) }
        )
        return (0..<100).map { _ in payload.toMessage(target: TargetType.macAddress(MACAddress.random())) }
    }

}
