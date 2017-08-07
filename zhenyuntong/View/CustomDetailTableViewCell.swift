//
//  CustomDetailTableViewCell.swift
//  BaiRong
//
//  Created by 张晓飞 on 2017/8/2.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit

class CustomDetailTableViewCell: UITableViewCell {
    
    var delegate : CustomDetailTableViewCellDelegate?

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

protocol CustomDetailTableViewCellDelegate {
    func call(tag : Int)
    func search(tag : Int)
}
