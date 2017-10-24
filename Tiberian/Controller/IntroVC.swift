//
//  IntroVC.swift
//  Tiberian
//
//  Created by Michel Kansou on 23/10/2017.
//  Copyright © 2017 Michel Kansou. All rights reserved.
//

import UIKit
import CoreData

class IntroVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func getStartedPressed(_ sender: Any) {
        performSegue(withIdentifier: "ScannerVC", sender: sender)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScannerVC" {

            if let scannerVC = segue.destination as? QRScannerVC {
                scannerVC.pushToMainView = true
            }
        }
    }
 

}
