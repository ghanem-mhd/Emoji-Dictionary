//
//  TagTableViewController.swift
//  CoreDataDemo
//
//  Created by Mohammed Ghannm on 30.11.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import UIKit
import CoreData

class TagTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    
    var moc : NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Tag>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        self.moc = appDelegate.persistentContainer.viewContext
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        // request.predicate = NSPredicate(format: "emojiCount > %d", 0)
        request.sortDescriptors = [nameSort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
     
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagTableCell", for: indexPath)
        guard let tag = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        cell.textLabel?.text = tag.name
        cell.detailTextLabel?.text = "\((tag.emojiCount ))"
        return cell
    }
    
    @IBAction func onAddClicked(_ sender: Any) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Tag name", message: "Please enter a tag name", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let alert = alert {
                let textField = alert.textFields![0]
                self.createAndSaveNewTag(tagName: textField.text!)
            }
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAndSaveNewTag(tagName: String){
        let tagEntity = NSEntityDescription.entity(forEntityName: "Tag", in: moc)!
        let newtagObject = NSManagedObject(entity: tagEntity, insertInto: moc)
        newtagObject.setValue(tagName, forKeyPath: "name")
        do {
            try moc.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
     
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            case .move:
                break
            case .update:
                break
            default:
                break
        }
    }
     
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            break
        }
    }
     
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let tag = self.fetchedResultsController?.object(at: indexPath) else {
                fatalError("Attempt to fetch non existed item")
            }
            do {
                moc.delete(tag)
                try moc.save()
            } catch let error as NSError {
                print("Error while deleting entry: \(error.userInfo)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
}
