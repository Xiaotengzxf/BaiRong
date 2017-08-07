//
//  NewTaskTableViewCell.swift
//  BaiRong
//
//  Created by ANKER on 2017/8/1.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit

class NewTaskTableViewCell: UITableViewCell {
    
    var delegate : NewTaskTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func call(_ sender: Any) {
        delegate?.call(tag: tag)
    }
    
    @IBAction func search(_ sender: Any) {
        delegate?.search(tag: tag)
    }
    
}

protocol NewTaskTableViewCellDelegate {
    func call(tag : Int)
    func search(tag : Int)
}
