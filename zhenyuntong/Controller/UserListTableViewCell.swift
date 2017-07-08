//
//  UserListTableViewCell.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/18.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserListTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDepartment: UILabel!
    @IBOutlet weak var ivHead: UIImageView!
    var json : JSON!
    var delegate : UserListTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func call(_ sender: Any) {
        if let mobile = json["mobile"].string{
            if Invalidate.isPhoneNumber(phoneNumber: mobile) {
                delegate?.makeCall(mobile: mobile)
            }
        }
    }
}

protocol UserListTableViewCellDelegate {
    func makeCall(mobile : String)
}
