//
//  WarningVC.swift
//  Tiberian
//
//  Created by Michel Kansou on 06/12/2017.
//  Copyright © 2017 Michel Kansou. All rights reserved.
//

import UIKit
import Spring

protocol WarningDelegate: class {
    func onContinueTapped()
}

class WarningVC: UIViewController{
    
    @IBOutlet weak var popupView: DesignableView!
    weak var delegate: WarningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func undoBtnPressed(_ sender: Any) {
        dismissAnimation()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueBtnPressed(_ sender: Any) {
        dismissAnimation()
        dismiss(animated: true, completion: nil)
        self.delegate?.onContinueTapped()
    }
    
    func dismissAnimation() {
        popupView.animation = "fadeOut"
        popupView.duration = 1
        popupView.animate()
    }
}
