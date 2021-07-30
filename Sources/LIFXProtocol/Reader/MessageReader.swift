///
///  MessageReader.swift
///  LIFXProtocol
///
///  - Copyright: 2021 Lifi Labs, Inc.
///  - Authors: Alexander Stonehouse
///  - Date: 25/2/19

import ByteBuffer
import Foundation

public class Messages {
    /// Reads in data and produces parsed messages. Data may contain multiple messages
    /// in sequence. As soon as an invalid message is discovered, only the valid
    /// messages will be returned.
    public static func read(data: Data) -> [AbstractMessageType] {
        var mut = data
        var messages: [AbstractMessageType] = []
        while mut.count > 0 {
            do {
                let msg = try readMessage(data: mut)
                mut = mut.subdata(in: Int(msg.header.size)..<mut.count)
                messages.append(msg)
            } catch let e {
                print("LIFX Message Parser: Error \(e)")
                break
            }
        }
        return messages
    }
    /// Takes serialized LIFX Messages bytes and materializes the correct implementation.
    ///
    /// - Parameters:
    ///   - data: Serialized LIFX Message content
    ///   - deserializeStateService: When false, only the MAC address from StateService messages will be parsed and a proxy message will be returned to speed up deserialialization.
    /// - Throws: DeserializationErrors
    /// - Returns: Deserialized LIFX Message
    public static func readMessage(data: Data, deserializeStateService: Bool = false) throws -> AbstractMessageType {
        try validate(data: data)
        let typeInt = UInt16.from(data: data[32..<34])
        guard let type = MessageType(rawValue: typeInt) else { throw DeserializationErrors.invalidMessageType }
        // If the message is a StateService, we can save deserialization by creating a message with the correct target.
        if type == MessageType.deviceStateService && !deserializeStateService {
            let target = Data(data[8..<14])
            if let mac = MACAddress(bytes: target) { return Device.StateServiceMessage.stub(for: mac) }
        }
        let messageType = message(for: type)
        let header = try readHeaderWithoutValidation(data: data)
        if let ackType = messageType as? AbstractAcknowledgementMessageType.Type {
            return ackType.init(header: header)
        } else if let payloadType = messageType as? AbstractPayloadMessageType.Type {
            // Make sure data is big enough to contain a
            // valid message of this type.
            guard data.count >= messageType.size else { throw DeserializationErrors.invalidSize }
            let payloadData = data.subdata(in: Header.size..<Int(messageType.size))
            return try payloadType.init(header: header, payload: payloadData)
        } else {
            throw DeserializationErrors.unsupportedMessageType
        }
    }
    private static func validate(data: Data) throws {
        guard data.count > 2 else { throw DeserializationErrors.insufficientBytes }
        var buffer = ByteBuffer(data: data)
        let size = try buffer.readShort()
        guard data.count >= Header.size && data.count >= size else { throw DeserializationErrors.invalidSize }
    }

    public static func readHeader(data: Data) throws -> Header {
        try validate(data: data)
        return try readHeaderWithoutValidation(data: data)
    }
    private static func readHeaderWithoutValidation(data: Data) throws -> Header {
        let headerData = data.subdata(in: 0..<Header.size)
        let header = try Header.from(data: headerData)
        guard header.protocol == protocolVersion else { throw DeserializationErrors.unsupportedProtocolVersion }
        return header
    }
}
