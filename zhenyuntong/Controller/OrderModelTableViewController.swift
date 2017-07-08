//
//  OrderModelTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/26.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON
import Toaster

class OrderModelTableViewController: UITableViewController {
    
    var data : [JSON] = []
    var detail : JSON?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.loadData()
        })
        tableView.mj_header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWOTempList, params: nil){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.data.removeAll()
                    
                    if let arr = object["data"].array {
                        self!.data += arr
                    }
                    self?.tableView.reloadData()
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
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = data[indexPath.row]["name"].string
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ordernew") as? OrderNewViewController {
            controller.tid = data[indexPath.row]["id"].intValue
            controller.tType = data[indexPath.row]["name"].stringValue
            controller.custId = Int(detail?["id"].string ?? "0")!
            controller.customer = detail?["customer"].string ?? ""
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
