//
//  TableViewCell.swift
//  TwitterDisplay
//
//  Created by Marcus Hughes on 5/18/16.
//  Copyright © 2016 Marcus Hughes. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var textL: UILabel!

    @IBOutlet weak var imageL: UIImageView!
    @IBOutlet weak var nameT: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
