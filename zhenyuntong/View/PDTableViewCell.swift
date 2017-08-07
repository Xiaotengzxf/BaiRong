//
//  PDTableViewCell.swift
//  BaiRong
//
//  Created by ANKER on 2017/8/1.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit

class PDTableViewCell: UITableViewCell {

    @IBOutlet weak var lcTrailing: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
