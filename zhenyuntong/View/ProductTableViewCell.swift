//
//  ProductTableViewCell.swift
//  AntService
//
//  Created by 张晓飞 on 2017/7/4.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblRemark: UILabel!
    var delegate : ProductTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func selectProduct(_ sender: Any) {
        delegate?.selectProduct(withTag: tag)
    }
}

protocol ProductTableViewCellDelegate {
    func selectProduct(withTag : Int)
}
