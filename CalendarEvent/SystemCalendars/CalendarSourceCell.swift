//
//  CalendarSourceCell.swift
//  Workopolo
//
//  Created by Shawon Rejaul on 19/8/21.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class CalendarSourceCell: UITableViewCell {
    
    @IBOutlet weak var sourceSelected: UIImageView!
    @IBOutlet weak var calendarName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
