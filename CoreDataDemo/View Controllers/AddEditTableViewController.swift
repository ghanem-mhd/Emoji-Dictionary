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
    
    var moc : NSManagedObjectContext!
    
    @IBOutlet weak var symbolTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tagsList: TagListView!
    
    var viewedEmoji : NSManagedObject?
    
    var selectedTags = Set<String>()
    
    var alltags = [Tag]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        self.moc = appDelegate.persistentContainer.viewContext
        
        symbolTextField.text        = self.viewedEmoji?.value(forKeyPath: "symbol") as? String
        nameTextField.text          = self.viewedEmoji?.value(forKeyPath: "name") as? String
        descriptionTextField.text   = self.viewedEmoji?.value(forKeyPath: "desc") as? String
        if let emojiTags = self.viewedEmoji?.value(forKey: "tags") as? Set<Tag> {
            for tag in emojiTags {
                selectedTags.insert(tag.name!)
            }
        }
        
        fetchAllTags()
        
        tagsList.delegate = self
        
        updateSaveButtonState()
    }
    
    func fetchAllTags(){
        do {
            let fetchRequest = NSFetchRequest<Tag>(entityName: "Tag")
            self.alltags = try moc.fetch(fetchRequest)
            for tag in self.alltags {
                tagsList.addTag(tag.name!)
            }
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
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if (!tagView.isSelected){
            selectedTags.insert(title)
        }else{
            selectedTags.remove(title)
        }
        tagView.isSelected = !tagView.isSelected
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
    
    @IBAction func onSaveButtonClicked(_ sender: Any) {
        if viewedEmoji == nil {
            let entity = NSEntityDescription.entity(forEntityName: "Emoji", in: moc)!
            viewedEmoji = NSManagedObject(entity: entity, insertInto: moc)
        }
        
        viewedEmoji!.setValue(symbolTextField.text!, forKeyPath: "symbol")
        viewedEmoji!.setValue(nameTextField.text!, forKeyPath: "name")
        viewedEmoji!.setValue(descriptionTextField.text!, forKeyPath: "desc")
        let newTags = viewedEmoji!.mutableSetValue(forKey: "tags")
        for tag in alltags{
            if (selectedTags.contains(tag.name!)) {
                newTags.add(tag)
            }else{
                newTags.remove(tag)
            }
        }
        do {
            try viewedEmoji!.validateForInsert()
            try moc.save()
            moc.refreshAllObjects()
            performSegue(withIdentifier: "SaveUnwind", sender: nil)
        } catch let error as NSError {
            moc.rollback()
            showWarning("\(error)")
        }
    }
        
    func showWarning(_ warningMessage:String){
        let alertController = UIAlertController(title: "🤯😡🤬", message: warningMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
}
