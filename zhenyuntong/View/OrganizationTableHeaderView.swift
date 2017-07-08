//
//  OrganizationTableHeaderView.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/19.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit

class OrganizationTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivArrow: UIImageView!
    var tap : UITapGestureRecognizer?
    var flag = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if tap == nil {
            tap = UITapGestureRecognizer(target: self, action: #selector(OrganizationTableHeaderView.handleTap(recognizer:)))
            self.addGestureRecognizer(tap!)
        }
    }
    
    func handleTap(recognizer : UITapGestureRecognizer) {
        NotificationCenter.default.post(name: Notification.Name(flag > 0 ? "dialogdep" : "org"), object: tag)
    }
}
