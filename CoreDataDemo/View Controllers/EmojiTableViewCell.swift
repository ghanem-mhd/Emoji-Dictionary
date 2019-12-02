//
//  EmojiTableViewCell.swift
//  CoreDataDemo
//
//  Created by Mohammed Ghannm on 09.11.19.
//  Copyright © 2019 Mohammed Ghannm. All rights reserved.
//

import UIKit
import CoreData

class EmojiTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(with emoji : NSManagedObject) {
        symbolLabel.text = emoji.value(forKeyPath: "symbol") as? String
        descriptionLabel.text = emoji.value(forKeyPath: "desc") as? String
        nameLabel.text = emoji.value(forKeyPath: "name") as? String
    }
    
    /* equivalent with entity class definition:
       
     func update(with emoji: Emoji) {
         symbolLabel.text = emoji.symbol
         descriptionLabel.text = emoji.desc
         nameLabel.text = emoji.name
     }
     
    */

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
