//
//  exportCSV.swift
//  2Factor
//
//  Created by Michel Kansou on 22/10/2017.
//  Copyright © 2017 Michel Kansou. All rights reserved.
//

import Foundation
import UIKit
import CoreData

func createExportString(key: NSFetchRequest<Key>) -> String {
    var name : String?
    var issuer : String?
    var url : String?
    var created : NSDate? = NSDate()
    
    var export : String = NSLocalizedString("Name, Issuer, Url, Created Date \n", comment: "")
    
    do {
        let searchResults = try context.fetch(key)
        for key in searchResults {
            name = key.name
            issuer = key.issuer
            url = key.url
            created = key.created
            
            if let createdDateString = created {
                export += "\(name!), \(issuer!), \(url!), \(createdDateString)\n"
            } else {
                export += "\(name!), \(issuer!), \(url!)\n"
            }
        }
    } catch {
        
    }
    
    return export
}


func importCSV(documentPicker: UIDocumentPickerViewController, view: UIViewController) {
    documentPicker.modalPresentationStyle = .formSheet
    view.present(documentPicker, animated: true, completion: nil)
}

func exportCSV(exportString: String, view: UIViewController) {
    
    let exportFilePath = NSTemporaryDirectory() + "tiberian.csv"
    let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
    FileManager.default.createFile(atPath: exportFilePath, contents: NSData() as Data, attributes: nil)
    
    var fileHandle: FileHandle? = nil
    do {
        fileHandle = try FileHandle(forWritingTo: exportFileURL as URL)
    } catch {
        print("Error with fileHandle")
    }
    
    if fileHandle != nil {
        fileHandle!.seekToEndOfFile()
        let csvData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        fileHandle!.write(csvData!)
        
        fileHandle!.closeFile()
        
        let firstActivityItem = NSURL(fileURLWithPath: exportFilePath)
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        
        view.present(activityViewController, animated: true, completion: nil)
    }
}
