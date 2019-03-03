//
//  Label.swift
//  SocketChat
//
//  Created by Kiryl Holubeu on 3/3/19.
//  Copyright © 2019 brakhmen. All rights reserved.
//

import UIKit

class Label: UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets = frame.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        super.drawText(in: insets)
    }
    
}
