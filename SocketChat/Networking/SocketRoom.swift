//
//  SocketRoom.swift
//  SocketChat
//
//  Created by Kiryl Holubeu on 3/3/19.
//  Copyright © 2019 brakhmen. All rights reserved.
//

import UIKit

protocol SocketRoomDelegate: class {
    func receivedMessage(message: SocketMessage)
}

class SocketRoom: NSObject {
    
    weak var delegate: SocketRoomDelegate?
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    var username = ""
    
    let maxReadLength = 1024
    
    func setupNetworkCommunication(host: String, port: UInt32) {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           host as CFString,
                                           port,
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: .main, forMode: .common)
        outputStream.schedule(in: .main, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
    func joinChat(username: String) {
        let data = "iam:\(username)".data(using: .utf8)!
        self.username = username
        _ = data.withUnsafeBytes {
            outputStream.write($0, maxLength: data.count)
            
        }
    }
    
    func sendMessage(message: String) {
        let data = "msg:\(message)".data(using: .utf8)!
        
        _ = data.withUnsafeBytes {
            outputStream.write($0, maxLength: data.count)
            
        }
    }
    
    func sendImage(_ image: UIImage) {
        
    }
    
    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }
    
}

extension SocketRoom: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            stopChatSession()
        case Stream.Event.errorOccurred:
            print("error occurred")
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
            break
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = inputStream.streamError {
                    break
                }
            }
            
            if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                delegate?.receivedMessage(message: message)
            }
        }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> SocketMessage? {
        guard let stringArray = String(bytesNoCopy: buffer,
                                       length: length,
                                       encoding: .utf8,
                                       freeWhenDone: true)?.components(separatedBy: ":"),
            let name = stringArray.first,
            let message = stringArray.last else {
                return nil
        }
        
        let messageSender:MessageSender = (name == self.username) ? .ourself : .someoneElse
        
        return SocketMessage(message: message, messageSender: messageSender, username: name)
    }
    
}

