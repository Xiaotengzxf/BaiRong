//
//  QuoteDetailTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/25.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class QuoteDetailTableViewController: UITableViewController {
    
    var offerId = 0
    var data : JSON?
    var commdata : JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appOfferDetail, params: ["offerId" : offerId]){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.data = object["data"]
                    var comm = object["data" , "commdata"].stringValue
                    comm = comm.replacingOccurrences(of: "\\\\", with: "\\")
                    comm = comm.replacingOccurrences(of: "\\\"", with: "\"")
                    self?.commdata = JSON(parseJSON:comm)
                    self?.tableView.reloadData()
                    self?.title = object["data" , "title"].string
                    
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
                
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (commdata?["headerList"].array?.count ?? 0) + (commdata?["commList"].array?.count ?? 0)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let count = commdata?["headerList"].array?.count ?? 0
        if indexPath.row < count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            if let label = cell.viewWithTag(2) as? UILabel {
                label.text = commdata?["headerList" ,indexPath.row ,  "name"].string
            }
            
            if let label = cell.viewWithTag(3) as? UILabel {
                label.text = commdata?["headerList" ,indexPath.row ,  "value"].string
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            
            if let label = cell.viewWithTag(2) as? UILabel {
                label.text = "商品名称：\(commdata?["commList" , indexPath.row - count , "name"].string ?? "")"
            }
            if let label = cell.viewWithTag(3) as? UILabel {
                label.text = "商品编号：\(commdata?["commList" , indexPath.row - count , "number"].string ?? "")"
            }
            if let label = cell.viewWithTag(4) as? UILabel {
                label.text = "型号规格：\(commdata?["commList" , indexPath.row - count , "number"].string ?? "") 单位：\(commdata?["commList" , indexPath.row - count , "company"].string ?? "") 数量：\(commdata?["commList" , indexPath.row - count , "count"].string ?? "")"
            }
            if let label = cell.viewWithTag(6) as? UILabel {
                label.text = "单价：\(commdata?["commList" , indexPath.row - count , "price"].string ?? "") 折扣：\(commdata?["commList" , indexPath.row - count , "discount"].string ?? "") 金额：\(commdata?["commList" , indexPath.row - count , "Amount"].string ?? "")"
            }
            if let label = cell.viewWithTag(5) as? UILabel {
                label.text = "明细备注：\(commdata?["commList" , indexPath.row - count , "remark"].string ?? "")"
            }
            return cell
        }
       
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let count = commdata?["headerList"].array?.count ?? 0
        if indexPath.row < count {
            return 44
        }else{
            return 120
        }
    }
    
}
