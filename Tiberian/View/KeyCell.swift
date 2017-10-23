//
//  KeyCell.swift
//  Tiberian
//
//  Created by Michel Kansou on 21/10/2017.
//  Copyright © 2017 Michel Kansou. All rights reserved.
//

import UIKit
import Spring

class KeyCell: UITableViewCell {

    @IBOutlet weak var currentPassword: DesignableLabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var issuer: UILabel!
    
    func configureCell(key: Key) {
        currentPassword.animation = "fadeIn"
        currentPassword.animate()
        currentPassword.duration = 1.5
        currentPassword.text = key.currentPassword
        name.text = key.name
        issuer.text = key.issuer
    }
}
