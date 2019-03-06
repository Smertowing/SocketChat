//
//  JoinChatViewController.swift
//  SocketChat
//
//  Created by Kiryl Holubeu on 3/3/19.
//  Copyright © 2019 brakhmen. All rights reserved.
//

import UIKit

class JoinChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var ipTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBAction func joinChat(_ sender: Any) {
        
        let roomVC = self.storyboard?.instantiateViewController(withIdentifier: "RoomID") as! SocketRoomViewController
        
        if let ipString = ipTextField.text {
            let characterset = CharacterSet(charactersIn: ".0123456789")
            guard ipString.rangeOfCharacter(from: characterset.inverted) == nil else {
                print("ip contains characters")
                createAlert(title: "ip field error", message: "ip contains bad characters")
                return
            }
            roomVC.host = ipString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let portString = portTextField.text {
            if let portInt32 = UInt32(portString) {
                roomVC.port = portInt32
            } else {
                print("port contains characters")
                createAlert(title: "port field error", message: "port contains bad characters")
                return
            }
        }
        
        if let nameString = nameTextField.text {
            if nameString.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                roomVC.username = nameString
            }
        }
        
        self.show(roomVC, sender: self)

    }
    
    
}
