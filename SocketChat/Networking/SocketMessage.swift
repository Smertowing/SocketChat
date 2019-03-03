//
//  SocketMessage.swift
//  SocketChat
//
//  Created by Kiryl Holubeu on 3/3/19.
//  Copyright © 2019 brakhmen. All rights reserved.
//

import Foundation

enum MessageSender {
    case ourself
    case someoneElse
}

struct SocketMessage {
    let message: String
    let senderUsername: String
    let messageSender: MessageSender
    
    init(message: String, messageSender: MessageSender, username: String) {
        self.message = message.withoutWhitespace()
        self.messageSender = messageSender
        self.senderUsername = username
    }
}
