//
//  AddEditTableViewController.swift
//  CoreDataDemo
//
//  Created by Mohammed Ghannm on 09.11.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import UIKit
import CoreData

class AddEditTableViewController: UITableViewController {

    @IBOutlet weak var symbolTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var usageTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
        
    var emojiData : NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        symbolTextField.text = self.emojiData?.value(forKeyPath: "symbol") as? String
        nameTextField.text = self.emojiData?.value(forKeyPath: "name") as? String
        descriptionTextField.text = self.emojiData?.value(forKeyPath: "desc") as? String
        usageTextField.text = self.emojiData?.value(forKeyPath: "usage") as? String
        
        
        updateSaveButtonState()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    func updateSaveButtonState(){
        let symbolText = symbolTextField.text ?? ""
        let nameText = nameTextField.text ?? ""
        let descripitonText = descriptionTextField.text ?? ""
        let usageText = usageTextField.text ?? ""
        
        saveButton.isEnabled = !symbolText.isEmpty && !nameText.isEmpty && !descripitonText.isEmpty && !usageText.isEmpty
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SaveUnwind" else {
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "EmojiMO", in: managedContext)!
        
        let emoji = NSManagedObject(entity: entity, insertInto: managedContext)

        emoji.setValue(symbolTextField.text!, forKeyPath: "symbol")
        emoji.setValue(nameTextField.text!, forKeyPath: "name")
        emoji.setValue(descriptionTextField.text!, forKeyPath: "desc")
        emoji.setValue(usageTextField.text!, forKeyPath: "usage")
        
        self.emojiData = emoji
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
