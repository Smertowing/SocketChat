//
//  Layouts.swift
//  SocketChat
//
//  Created by Kiryl Holubeu on 3/3/19.
//  Copyright © 2019 brakhmen. All rights reserved.
//

import UIKit

extension SocketRoomViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        loadViews()
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue
            let messageBarHeight = self.messageInputBar.bounds.size.height
            let point = CGPoint(x: self.messageInputBar.center.x, y: endFrame.origin.y - messageBarHeight/2.0)
            let inset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame.size.height, right: 0)
            UIView.animate(withDuration: 0.25) {
                self.messageInputBar.center = point
                self.tableView.contentInset = inset
            }
        }
    }
    
    func loadViews() {
        navigationItem.title = "Let's Chat!"
        navigationItem.backBarButtonItem?.title = "Run!"
        
        view.backgroundColor = UIColor(red: 24/255, green: 180/255, blue: 128/255, alpha: 1.0)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        view.addSubview(messageInputBar)
        
        messageInputBar.delegate = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let messageBarHeight:CGFloat = 60.0
        let size = view.bounds.size
        tableView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height - messageBarHeight)
        messageInputBar.frame = CGRect(x: 0, y: size.height - messageBarHeight, width: size.width, height: messageBarHeight)
    }
}

extension MessageTableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isJoinMessage() {
            layoutForJoinMessage()
        } else {
            messageLabel.font = UIFont(name: "Helvetica", size: 17) //UIFont.systemFont(ofSize: 17)
            messageLabel.textColor = .white
            
            let size = messageLabel.sizeThatFits(CGSize(width: 2*(bounds.size.width/3), height: CGFloat.greatestFiniteMagnitude))
            messageLabel.frame = CGRect(x: 0, y: 0, width: size.width + 32, height: size.height + 16)
            
            if messageSender == .ourself {
                nameLabel.isHidden = true
                
                messageLabel.center = CGPoint(x: bounds.size.width - messageLabel.bounds.size.width/2.0 - 16, y: bounds.size.height/2.0)
                messageLabel.backgroundColor = UIColor(red: 24/255, green: 180/255, blue: 128/255, alpha: 1.0)
            } else {
                nameLabel.isHidden = false
                nameLabel.sizeToFit()
                nameLabel.center = CGPoint(x: nameLabel.bounds.size.width/2.0 + 16 + 4, y: nameLabel.bounds.size.height/2.0 + 4)
                
                messageLabel.center = CGPoint(x: messageLabel.bounds.size.width/2.0 + 16, y: messageLabel.bounds.size.height/2.0 + nameLabel.bounds.size.height + 8)
                messageLabel.backgroundColor = .lightGray
            }
        }
        
        messageLabel.layer.cornerRadius = min(messageLabel.bounds.size.height/2.0, 20)
    }
    
    func layoutForJoinMessage() {
        messageLabel.font = UIFont.systemFont(ofSize: 10)
        messageLabel.textColor = .lightGray
        messageLabel.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
        let size = messageLabel.sizeThatFits(CGSize(width: 2*(bounds.size.width/3), height: CGFloat.greatestFiniteMagnitude))
        messageLabel.frame = CGRect(x: 0, y: 0, width: size.width + 32, height: size.height + 16)
        messageLabel.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2.0)
    }
    
    func isJoinMessage() -> Bool {
        if let words = messageLabel.text?.components(separatedBy: " ") {
            if words.count >= 2 && words[words.count - 2] == "has" && words[words.count - 1] == "joined" {
                return true
            }
        }
        
        return false
    }
}

