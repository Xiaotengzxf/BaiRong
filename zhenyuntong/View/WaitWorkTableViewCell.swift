//
//  WaitWorkTableViewCell.swift
//  AntService
//
//  Created by 张晓飞 on 2017/4/4.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit

class WaitWorkTableViewCell: UITableViewCell {

    @IBOutlet weak var btnFile: UIButton!
    @IBOutlet weak var lcBottom: NSLayoutConstraint!
    var delegate : WaitWorkTableViewCellDelegate?
    var file = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showFile(_ sender: Any) {
        delegate?.showFile(file: file)
    }

}

protocol WaitWorkTableViewCellDelegate {
    func showFile(file : String)
}
