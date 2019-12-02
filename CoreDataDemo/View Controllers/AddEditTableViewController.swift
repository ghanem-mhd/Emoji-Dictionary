//
//  AddEditTableViewController.swift
//  CoreDataDemo
//
//  Created by Mohammed Ghannm on 09.11.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import UIKit
import CoreData
import TagListView

class AddEditTableViewController: UITableViewController, TagListViewDelegate {
    
    
    @IBOutlet weak var symbolTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tagsList: TagListView!
    
    
    var moc : NSManagedObjectContext!
    
    var viewedEmoji : NSManagedObject?
    
    var selectedTags = Set<String>()
    
    var allTags = [Tag]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getting appDelegate's reference
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        self.moc = appDelegate.persistentContainer.viewContext
        
        // initializing text fields
        symbolTextField.text        = self.viewedEmoji?.value(forKeyPath: "symbol") as? String
        nameTextField.text          = self.viewedEmoji?.value(forKeyPath: "name") as? String
        descriptionTextField.text   = self.viewedEmoji?.value(forKeyPath: "desc") as? String
        
        // fetch selectedTags from entity and saves it in attribute
        if let emojiTags = self.viewedEmoji?.value(forKey: "tags") as? Set<Tag> {
            for tag in emojiTags {
                selectedTags.insert(tag.name!)
            }
        }
        
        fetchAllTags()
        
        tagsList.delegate = self
        
        updateSaveButtonState()
    }
    
    // fetches all tags from CoreData and adds them to the UI
    func fetchAllTags(){
        do {
            // fetches all Tag entities from CoreData
            let fetchRequest = NSFetchRequest<Tag>(entityName: "Tag")
            self.allTags = try moc.fetch(fetchRequest)
            
            // adds tags to UI list ...
            for tag in self.allTags {
                tagsList.addTag(tag.name!)
            }
            
            // ... and highlights the selected ones
            for tagView in tagsList.tagViews {
                if let title = tagView.titleLabel?.text {
                    if selectedTags.contains(title) {
                        tagView.isSelected = true
                    }
                }
            }
        } catch {
            fatalError("Failed to fetch tags: \(error)")
        }
    }
    
    // adds/removes tags from selectedTags list attribute
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if (!tagView.isSelected) {
            selectedTags.insert(title)
        } else {
            selectedTags.remove(title)
        }
        tagView.isSelected = !tagView.isSelected
    }
    
    @IBAction func onSaveButtonClicked(_ sender: Any) {
        // creates new ManagedObject if no Emoji MO is present
        if viewedEmoji == nil {
            let entity = NSEntityDescription.entity(forEntityName: "Emoji", in: moc)!
            viewedEmoji = NSManagedObject(entity: entity, insertInto: moc) // at this stage, the ManageObject is already in memory!
        }
        
        // sets values for ManageObject
        viewedEmoji!.setValue(symbolTextField.text!, forKeyPath: "symbol")
        viewedEmoji!.setValue(nameTextField.text!, forKeyPath: "name")
        viewedEmoji!.setValue(descriptionTextField.text!, forKeyPath: "desc")
        let newTags = viewedEmoji!.mutableSetValue(forKey: "tags") // since tags is many to many relation, CoreData uses Sets beneath the hood
        for tag in allTags {
            if (selectedTags.contains(tag.name!)) {
                newTags.add(tag)
            } else {
                newTags.remove(tag)
            }
        }
        
        do {
            // try viewedEmoji!.validateForInsert()
            
            // saves changes to persistent store
            try moc.save()
            
            // updates relations (in this case "tags")
            moc.refreshAllObjects()
            
            performSegue(withIdentifier: "SaveUnwind", sender: nil)
        } catch let error as NSError {
            // discards all insertions/deletions and restores updated objects to their initial state
            moc.rollback()
            
            // for demo purposes
            showWarning("\(error)")
        }
    }
    
    // for demo purposes
    func showWarning(_ warningMessage:String){
        let alertController = UIAlertController(title: "🤯😡🤬", message: warningMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func updateSaveButtonState(){
        let symbolText      = symbolTextField.text ?? ""
        let nameText        = nameTextField.text ?? ""
        let descripitonText = descriptionTextField.text ?? ""
        
        saveButton.isEnabled = !symbolText.isEmpty && !nameText.isEmpty && !descripitonText.isEmpty
    }
    
    @IBAction func textChanged(_ sender: Any) {
        updateSaveButtonState()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SaveUnwind" else {
            return
        }
    }
}
