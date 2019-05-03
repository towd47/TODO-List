//
//  TODOItemViewCell.swift
//  TODO List
//
//  Created by Tom on 5/2/19.
//  Copyright © 2019 Towd47. All rights reserved.
//

import UIKit

class TODOItemViewCell: UITableViewCell {
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var spacerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
