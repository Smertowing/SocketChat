//
//  SocketRoomViewController.swift
//  SocketChat
//
//  Created by Kiryl Holubeu on 3/3/19.
//  Copyright © 2019 brakhmen. All rights reserved.
//

import UIKit

class SocketRoomViewController: UIViewController {

    let tableView = UITableView()
    let messageInputBar = MessageInputView()
    
    let socketRoom = SocketRoom()
    var messages = [SocketMessage]()
    
    var host = "192.168.1.102"
    var port: UInt32 = 55556
    var username = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        socketRoom.delegate = self
        socketRoom.setupNetworkCommunication(host: host, port: port)
        socketRoom.joinChat(username: username)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        socketRoom.stopChatSession()
    }
}

extension SocketRoomViewController: MessageInputDelegate {
    func sendWasTapped(message: String) {
        socketRoom.sendMessage(message: message)
    }
}

extension SocketRoomViewController: SocketRoomDelegate {
    func receivedMessage(message: SocketMessage) {
        insertNewMessageCell(message)
    }

}


