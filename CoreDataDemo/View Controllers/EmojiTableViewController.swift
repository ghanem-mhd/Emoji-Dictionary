//
//  EmojiTabeViewControllerTableViewController.swift
//  CoreDataDemo
//
//  Created by Mohammed Ghannm on 09.11.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import UIKit
import CoreData

class EmojiTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var moc : NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Emoji>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        self.moc = appDelegate.persistentContainer.viewContext
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<Emoji>(entityName: "Emoji")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    
    @IBAction func onEditClicked(_ sender: Any) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        self.navigationItem.leftBarButtonItem?.title = self.tableView.isEditing ? "Done" : "Edit"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath) as! EmojiTableViewCell
        guard let emoji = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        cell.update(with: emoji)
        return cell
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
            guard let emoji = self.fetchedResultsController?.object(at: indexPath) else {
                fatalError("Attempt to fetch non existed item")
            }
            do {
                moc.delete(emoji)
                try moc.save()
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
                guard let selectedEmoji = self.fetchedResultsController?.object(at: selectedIndexPath) else {
                    fatalError("Attempt to fetch non existed item")
                }
                let addEditTableViewController = (segue.destination as! UINavigationController).viewControllers.first as! AddEditTableViewController
                addEditTableViewController.viewedEmoji = selectedEmoji
            }
        }
    }
    
    @IBAction func unwindToEmojiTableViewController(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "SaveUnwind" else {
            return
        }
    }
}
