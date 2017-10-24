//
//  PopUpVC.swift
//  Tiberian
//
//  Created by Michel Kansou on 24/10/2017.
//  Copyright © 2017 Michel Kansou. All rights reserved.
//

import UIKit
import Spring

class PopupVC: UIViewController {
    
    @IBOutlet weak var popupView: DesignableView!
    
    var selectedKey: Key!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func undoBtnPressed(_ sender: Any) {
        dismissAnimation()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeBtnPressed(_ sender: Any) {
        context.delete(selectedKey)
        ad.saveContext()
        dismissAnimation()
        dismiss(animated: true, completion: nil)
    }
    
    func dismissAnimation() {
        popupView.animation = "fadeOut"
        popupView.duration = 1
        popupView.animate()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
