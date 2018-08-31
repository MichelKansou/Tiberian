//
//  MainVC.swift
//  Tiberian
//
//  Created by Michel Kansou on 21/10/2017.
//  Copyright © 2017 Michel Kansou. All rights reserved.
//

import UIKit
import OneTimePassword
import CoreData
import MessageUI
import CSV

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate, MFMailComposeViewControllerDelegate, UIDocumentPickerDelegate, WarningDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var editBtn: UIButton!
    
    var controller: NSFetchedResultsController<Key>!
    var filteredKeys = [Key]()
    var inSearchMode = false
    var timer = Timer()
    var selectedKey: Key!
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .import)
    
    @IBOutlet weak var progressBar: CustomProgressView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
        })
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        searchBar.delegate = self
        documentPicker.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        progressBar.progress = 0.0
        
        updateCurrentPasswords()
        attemptFetch()
        progressTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if inSearchMode {
            return filteredKeys.count
        } else {
            if let sections = controller.sections {
                
                let sectionInfo = sections[section]
                return sectionInfo.numberOfObjects
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath) as? KeyCell {
            
            configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func configureCell(cell: KeyCell, indexPath: NSIndexPath) {
        
        let key: Key!
        
        if inSearchMode {
            key = filteredKeys[indexPath.row]
        } else {
            key = controller.object(at: indexPath as IndexPath)
        }
        
        cell.configureCell(key: key)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: Get Stored Keys
    
    func attemptFetch() {
        
        let fetchRequest: NSFetchRequest<Key> =  Key.fetchRequest()
        let dateSort = NSSortDescriptor(key: "created", ascending: true)
        
        fetchRequest.sortDescriptors = [dateSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        self.controller = controller
        
        do {
            
            try controller.performFetch()
            
        } catch {
            
            let error = error as NSError
            print("\(error)")
        }
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case.insert:
            if let indexPath = newIndexPath {
                
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
        case.delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case.update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRow(at: indexPath) as? KeyCell {
                    configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
                }
            }
            break
        case.move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
        
    }
    
    // MARK: User Selected Cell
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! KeyCell
        
        if (tableView.isEditing == true) {
            selectedKey = controller.object(at: indexPath as IndexPath)
            performSegue(withIdentifier: "editViewSegue", sender: self)
        } else {
            copyPassword(cell: cell)
        }
        
    }
    
    func copyPassword(cell: KeyCell) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            cell.backgroundColor = UIColor(hex: "746EC2")
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                cell.backgroundColor = .clear
            }, completion: nil)
        })
        
        UIPasteboard.general.string = cell.currentPassword.text
        let oldName = cell.name.text
        cell.name.text = "Copied code"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            cell.name.text = oldName
        })
    }
    
    // MARK: Edit Table view
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            selectedKey = controller.object(at: indexPath as IndexPath)
            performSegue(withIdentifier: "popupSegue", sender: self)
//            context.delete(selectedKey)
//            ad.saveContext()
//            tableView.reloadData()
            
            
        } else if editingStyle == .insert {
            
        }
    }
    
    
    // MARK: Rearrange Rows in Table View
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        <#code#>
//    }
    
    
    
    // MARK: Activity Indicator
    
    // TODO: Add Activity Indicator if loading is long
//    func startActivityIndicator() {
//
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
//
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//
//        UIApplication.shared.beginIgnoringInteractionEvents()
//    }
//
//
//    func stopActivityIndicator() {
//
//        activityIndicator.stopAnimating()
//        UIApplication.shared.endIgnoringInteractionEvents()
//    }
    
   // MARK: Document Picker
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        return
    }
    
    // Did pick document
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            let stream = InputStream(fileAtPath: url.path)!
            let csv = try! CSVReader(stream: stream, hasHeaderRow: true)
            
            while csv.next() != nil {
                let key = Key(context: context)
                
                if let name = csv["Name"] {
                    key.name = name.trimmingCharacters(in: .whitespaces)
                }
                if let issuer = csv[" Issuer"] {
                    key.issuer = issuer.trimmingCharacters(in: .whitespaces)
                }
                if let url = csv[" Url"] {
                    key.url = url.trimmingCharacters(in: .whitespaces)
                    print(url)
                }
                
                key.created = Date() as NSDate
                ad.saveContext()
                updateCurrentPasswords()
            }
        }
    }
    
    
    // MARK: Empty Core Data
    func DeleteAllData(){
        
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Key"))
        do {
            try context.execute(DelAllReqVar)
            tableView.reloadData()
        }
        catch {
            print(error)
        }
    }
    
    // MARK: Progress Bar Timer
    
    func progressTimer(){
        // Scheduling timer to update progress bar
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateProgressBar)), userInfo: nil, repeats: true)
    }

    func updateProgressBar() {
        if progressBar.progress >= 1 {
            self.updateCurrentPasswords()
            progressBar.progress = 0
        } else {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.progressBar.setProgress(self.progressBar.progress + 0.1/3, animated: true)
            })
        }
    }
    func updateCurrentPasswords(){
        print("update all passwords in core data")
        
        let request:NSFetchRequest<Key> = Key.fetchRequest()
        
        do {
            let searchResults = try context.fetch(request)
            for key in searchResults {
                if let stringUrl = key.url {
                    if let url = URL(string: stringUrl) {
                        if let token = Token(url: url) {
                            key.currentPassword = "\(token.currentPassword!)"
                        }
                    }
                }
            }
            ad.saveContext()
        } catch {
            
        }
        
    }
    
    
    // MARK: More Button
    
    @IBAction func moreBtnPressed(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let exportAction = UIAlertAction(title: "Export CSV", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let request:NSFetchRequest<Key> = Key.fetchRequest()
            let exportString = createExportString(key: request)
            exportCSV(exportString: exportString, view: self)
        })
        
        let importAction = UIAlertAction(title: "Import CSV", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            importCSV(documentPicker: self.documentPicker, view: self)
        })
        
        let donationAction = UIAlertAction(title: "Donation", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "donationSegue", sender: self)
        })
        
        
//        let eraseAction = UIAlertAction(title: "Erase", style: .destructive, handler: {
//            (alert: UIAlertAction!) -> Void in
//            self.performSegue(withIdentifier: "warningSegue", sender: self)
//        })
        
        let contactAction = UIAlertAction(title: "Contact Us", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let subject = "Feedback Tiberian"
            let toRecipents = ["michel.kansou@outlook.fr"]
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(subject)
            mc.setToRecipients(toRecipents)
            
            self.present(mc, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        optionMenu.addAction(exportAction)
        optionMenu.addAction(importAction)
        optionMenu.addAction(contactAction)
        optionMenu.addAction(donationAction)
//        optionMenu.addAction(eraseAction)
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK: Handel Mail
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
            case .cancelled:
                print("Mail cancelled")
            case .saved:
                print("Mail saved")
            case .sent:
                print("Mail sent")
            case .failed:
                print("Mail sent failure: \(String(describing: error?.localizedDescription))")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Edit Button
    
    @IBAction func editBtnPressed(_ sender: Any) {
        
        if let editBtnTitle = editBtn.currentTitle {
            if (editBtnTitle == "Edit") {
                editBtn.setTitle("Done", for: .normal)
                tableView.isEditing = true
                tableView.allowsSelectionDuringEditing = true
            }
            if (editBtnTitle == "Done") {
                editBtn.setTitle("Edit", for: .normal)
                tableView.isEditing = false
                tableView.allowsSelectionDuringEditing = false
            }
        }
        
    }
    
    
    // MARK: Search Bar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false
            tableView.reloadData()
            view.endEditing(true)
            
        } else {
            inSearchMode = true
            let lower = searchBar.text!.lowercased()
            
            if let keys = controller.fetchedObjects {
                filteredKeys = keys.filter() {
                    let filterName = $0.name?.lowercased().range(of: lower) != nil
                    let filterIssuer = $0.issuer?.lowercased().range(of: lower) != nil
                    
                    return filterName || filterIssuer
                }
            }
            
            tableView.reloadData()
            
        }
    }
    
    // TODO: Get back to IntroVC after erase
    func onContinueTapped() {
        DeleteAllData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popupSegue" {

            if let popupVC = segue.destination as? PopupVC {
                popupVC.selectedKey = selectedKey
            }
        }
        if segue.identifier == "warningSegue" {
            
            if let warningVC = segue.destination as? WarningVC {
                warningVC.delegate = self
            }
        }
        if segue.identifier == "editViewSegue" {
            if let editVC = segue.destination as? EditVC {
                editVC.key = selectedKey
            }
        }
    }


}

