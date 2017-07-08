//
//  CommercialDetailTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/7/3.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class CommercialDetailTableViewController: UITableViewController {
    
    var strId = 0
    var data : JSON!
    var titles = ["商机编号：", "商机名称：", "商机类型：", "发    起    人：", "商机备注："]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5 + (data["commoditys"].array?.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < 5{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            if let label = cell.viewWithTag(2) as? UILabel {
                label.text = titles[indexPath.row]
            }
            
            if let label = cell.viewWithTag(3) as? UILabel {
                switch indexPath.row {
                case 0:
                    label.text = data["oppoInfo", "no"].string
                case 1:
                    label.text = data["oppoInfo", "name"].string
                case 2:
                    label.text = data["oppoInfo", "type"].string
                case 3:
                    label.text = data["oppoInfo", "adduser"].string
                default:
                    label.text = data["oppoInfo", "remark"].string
                }
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            
            if let label = cell.viewWithTag(2) as? UILabel {
                label.text = "企航\(data["commoditys" , indexPath.row - 5 , "model"].string ?? "")"
            }
            if let label = cell.viewWithTag(3) as? UILabel {
                label.text = "商品编号：\(data["commoditys" , indexPath.row - 5, "number"].string ?? "")"
            }
            if let label = cell.viewWithTag(4) as? UILabel {
                label.text = "商品型号：\(data["commoditys" , indexPath.row - 5, "number"].string ?? "") 单位：\(data["commoditys" , indexPath.row - 5, "company"].string ?? "")"
            }
            if let label = cell.viewWithTag(6) as? UILabel {
                label.text = "商品数量：\(data["commoditys" , indexPath.row - 5, "count"].string ?? "") 商品单价：\(data["commoditys" , indexPath.row - 5, "price"].string ?? "") 库存数量：\(data["commoditys" , indexPath.row - 5, "quantity"].string ?? "")"
            }
            if let label = cell.viewWithTag(5) as? UILabel {
                label.text = "折扣：\(data["commoditys" , indexPath.row - 5, "discount"].string ?? "") 金额：\(data["commoditys" , indexPath.row - 5, "amount"].string ?? "")"
            }
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < 5 {
            return 44
        }else{
            return 120
        }
    }
    
}
