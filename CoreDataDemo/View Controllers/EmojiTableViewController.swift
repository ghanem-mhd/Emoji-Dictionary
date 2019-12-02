//
//  EmojiTabeViewControllerTableViewController.swift
//  CoreDataDemo
//
//  Created by Mohammed Ghannm on 09.11.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import UIKit
import CoreData

class EmojiTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var fetchRequest: NSFetchRequest<Emoji>?
    
    var moc: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Emoji>!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getting the appDelegate's reference
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // set delegate so searchBar's input changes can be caught
        self.searchBar.delegate = self
        
        // save ManagedObjectContext in class attribute
        self.moc = appDelegate.persistentContainer.viewContext
        
        // fetch data
        initializeFetchedResultsController()
    }
    
    // Creates a NSFetchRequest and NSFetchedResultsController and fetches the data
    func initializeFetchedResultsController() {
        
        // create fetch request and saves it in an attribute
        self.fetchRequest = NSFetchRequest<Emoji>(entityName: "Emoji")
        
        // add NSSortDescriptor to the fetch request orderung the results by name
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        self.fetchRequest!.sortDescriptors = [nameSort]
        
        // creates NSFetchedResultsController and assigns its fetchRequest and target moc
        fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest!, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        // set delegate so class methods will be called on certain events
        fetchedResultsController.delegate = self
        
        // fetch results, will be accessable in fetchedResultsController
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // updates the fetchRequest's predicates and re-fetches the data
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText == "") {
            self.fetchRequest!.predicate = nil
        } else {
            // todo
            self.fetchRequest!.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func onEditClicked(_ sender: Any) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        self.navigationItem.leftBarButtonItem?.title = self.tableView.isEditing ? "Done" : "Edit"
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // instead of using static source, the fetchedResultsController is used
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // instead of using static source, the fetchedResultsController is used
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath) as! EmojiTableViewCell
        
        // instead of using static source, the fetchedResultsController is used
        guard let emoji = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        cell.update(with: emoji) // todo
        return cell
    }
    
    
    // callback if NSFetchedResultsController updates its Sections
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
    
    // callback if NSFetchedResultsController updates its Rows
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
            // instead of using static source, the fetchedResultsController is used
            guard let emoji = self.fetchedResultsController?.object(at: indexPath) else {
                fatalError("Attempt to fetch non existed item")
            }
            do {
                // managed object deleted from managed object context
                moc.delete(emoji)
                try moc.save()
                
                // updates relations (in this case to "tags")
                moc.refreshAllObjects()
            } catch let error as NSError {
                print("Error while deleting entry: \(error.userInfo)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEmoji"{
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                // instead of using static source, the fetchedResultsController is used
                guard let selectedEmoji = self.fetchedResultsController?.object(at: selectedIndexPath) else {
                    fatalError("Attempt to fetch non existed item")
                }
                
                // set the managed object (in this case viewedEmoji) to the addEditTableViewController
                let addEditTableViewController = (segue.destination as! UINavigationController).viewControllers.first as! AddEditTableViewController
                addEditTableViewController.viewedEmoji = selectedEmoji
            }
        }
    }
    
    @IBAction func unwindToEmojiTableViewController(_ unwindSegue: UIStoryboardSegue){
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}
