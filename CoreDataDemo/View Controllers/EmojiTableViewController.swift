//
//  EmojiTabeViewControllerTableViewController.swift
//  CoreDataDemo
//
//  Created by Mohammed Ghannm on 09.11.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import UIKit
import CoreData

class EmojiTableViewController: UITableViewController {
    
    var emojiList : [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "EmojiMO")
        
        do {
            self.emojiList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // return emojis.count
            return self.emojiList.count
        } else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath) as! EmojiTableViewCell
        // let emoji = emojis[indexPath.row]
        let emoji = emojiList[indexPath.row]
        cell.update(with: emoji)
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let emoji = emojiList[indexPath.row]
            emojiList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            managedContext.delete(emoji)
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Error while deleting entry: \(error.userInfo)")
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            print("----")
        }
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedEmoji = emojiList.remove(at: fromIndexPath.row)
        emojiList.insert(movedEmoji, at: to.row)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEmoji"{
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                let selectedEmoji = self.emojiList[selectedIndexPath.row]
                let addEditTableViewController = (segue.destination as! UINavigationController).viewControllers.first as! AddEditTableViewController
                addEditTableViewController.emojiData = selectedEmoji
            }
        }
    }
    
    @IBAction func unwindToEmojiTableViewController(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "SaveUnwind" else {
            return
        }
        
        let addEditTableViwerController = unwindSegue.source as! AddEditTableViewController

        if let emoji = addEditTableViwerController.emojiData {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                emojiList[selectedIndexPath.row] = emoji
                tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            } else {
                let newIndexPath = IndexPath(row: emojiList.count, section: 0)
                emojiList.append(emoji)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
}
