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


protocol updateView {
    func changeName()
}

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var controller : NSFetchedResultsController<Key>!
    var filteredKeys = [Key]()
    var inSearchMode = false
    var timer = Timer()
    @IBOutlet weak var progressBar: CustomProgressView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        progressBar.progress = 0.0
        
        updateCurrentPasswords()
        attemptFetch()
        progressTimer()
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
        
        print("user pressed Cell")
        
        let cell = tableView.cellForRow(at: indexPath) as! KeyCell
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            cell.backgroundColor = UIColor(hex: "746EC2")
            
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                cell.backgroundColor = .clear
                
            }, completion: nil)
        })
        
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
            
            let selectedKey = controller.object(at: indexPath as IndexPath)
            context.delete(selectedKey)
            ad.saveContext()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
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
                if let url = key.url {
                    if let token = Token(url: URL(string: url)!) {
                        key.currentPassword = "\(token.currentPassword!)"
                    }
                }
            }
            ad.saveContext()
        } catch {
            
        }
        
    }
    
    
    // MARK: Export Core Data to CSV
    
    @IBAction func exportBtnPressed(_ sender: Any) {
        let request:NSFetchRequest<Key> = Key.fetchRequest()
        let exportString = createExportString(key: request)
        saveAndExport(exportString: exportString, view: self)
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
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "QRScannerVC" {
//
//            if let scannerVC = segue.destination as? QRScannerVC {
//                scannerVC.delegate = self
//            }
//        }
//    }


}

