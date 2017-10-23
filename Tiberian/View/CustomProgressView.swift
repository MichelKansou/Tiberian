//
//  CustomProgressView.swift
//  Tiberian
//
//  Created by Michel Kansou on 22/10/2017.
//  Copyright © 2017 Michel Kansou. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomProgressView: UIProgressView {
    
    @IBInspectable var barHeight : CGFloat {
        get {
            return transform.d * 2.0
        }
        set {
            // 2.0 Refers to the default height of 2
            let heightScale = newValue / 2.0
            let c = center
            transform = CGAffineTransform(scaleX: 1.0, y: heightScale)
            center = c
        }
    }
}
