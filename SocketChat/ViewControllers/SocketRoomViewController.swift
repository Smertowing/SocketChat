//
//  SocketRoomViewController.swift
//  SocketChat
//
//  Created by Kiryl Holubeu on 3/3/19.
//  Copyright © 2019 brakhmen. All rights reserved.
//

import UIKit

class SocketRoomViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    
    let socketRoom = SocketRoom()
    var messages = [SocketMessage]()
    
    var host = ""
    var port: UInt32 = 0
    var username = ""
    
    
    
    @IBAction func sendAction(_ sender: Any) {
        if let message = inputTextField.text {
            if message.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                socketRoom.sendMessage(message: message)
                inputTextField.text = ""
            }
        }
    }
    
    @IBAction func attachAction(_ sender: Any) {
        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
        AttachmentHandler.shared.imagePickedBlock = { (image) in
            self.socketRoom.sendImage(image)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let sv = UIViewController.displaySpinner(onView: self.view)
        sv.becomeFirstResponder()
        socketRoom.delegate = self
        socketRoom.setupNetworkCommunication(host: host, port: port)
        socketRoom.joinChat(username: username)
        UIViewController.removeSpinner(spinner: sv)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        socketRoom.sendMessage(message: "has left.")
        socketRoom.stopChatSession()
    }
}

extension SocketRoomViewController: SocketRoomDelegate {
    func receivedMessage(message: SocketMessage) {
        insertNewMessageCell(message)
    }

}


