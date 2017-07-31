//
//  PTableViewCell.swift
//  BaiRong
//
//  Created by 张晓飞 on 2017/7/31.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit

class PTableViewCell: UITableViewCell {
    
    var delegate : PTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func refresh(_ sender: Any) {
        delegate?.refresh(tag: tag)
    }
}

protocol PTableViewCellDelegate {
    func refresh(tag : Int)
}
