//
//  SocketRoomViewControllerExtension.swift
//  SocketChat
//
//  Created by Kiryl Holubeu on 3/3/19.
//  Copyright © 2019 brakhmen. All rights reserved.
//

import UIKit

extension SocketRoomViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messages.count == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SomeoneEntered", for: indexPath) as! JoinedTableViewCell
            cell.joinedLabel.text = "host error"
            inputTextField.isEnabled = false
            return cell
            
        } else {
            
            let message = messages[indexPath.row]
        
            if message.senderUsername.contains("has joined") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SomeoneEntered", for: indexPath) as! JoinedTableViewCell
                cell.joinedLabel.text = message.senderUsername
                return cell
            } else if message.message.contains("has left.") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SomeoneEntered", for: indexPath) as! JoinedTableViewCell
                cell.joinedLabel.text = message.senderUsername + " " + message.message
                return cell
            } else if message.messageSender == .ourself {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessages", for: indexPath) as! MyTableViewCell
                cell.myMessageLabel.text = message.message
                cell.myMessageLabel.sizeToFit()
                return cell
            } else if message.messageSender == .someoneElse {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherMessages", for: indexPath) as! OtherTableViewCell
                cell.userNameLabel.text = message.senderUsername
                cell.messageLabel.text = message.message
                cell.messageLabel.sizeToFit()
                return cell
            }
            return UITableViewCell()
    
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count == 0 {
            return 1
        } else {
            return messages.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func insertNewMessageCell(_ message: SocketMessage) {
        messages.append(message)
        tableView.reloadData()
        let indexPath = IndexPath(row: messages.count-1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    
}

