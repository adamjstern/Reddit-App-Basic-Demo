//
//  CustomTableViewCell.swift
//  StockX Demo
//
//  Created by Adam Stern on 6/5/18.
//  Copyright © 2018 Adam Stern. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    //  Custom class to be easily modifed and styled for the look of the table view cells.
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var subreddit: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
