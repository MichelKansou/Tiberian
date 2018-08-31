//
//  EditVC.swift
//  Tiberian
//
//  Created by Michel Kansou on 19/01/2018.
//  Copyright © 2018 Michel Kansou. All rights reserved.
//

import UIKit
import CoreData

class EditVC: UIViewController, NSFetchedResultsControllerDelegate {

    var key: Key!
    
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var issuerTxtField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
//    var controller: NSFetchedResultsController<Key>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTxtField.text = key.name
        issuerTxtField.text = key.issuer
        urlTextField.text = key.url
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        key.name = nameTxtField.text
        key.issuer = issuerTxtField.text
        key.url = urlTextField.text
        ad.saveContext()
        dismiss(animated: true, completion: nil)
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
