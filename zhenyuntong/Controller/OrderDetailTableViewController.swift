//
//  OrderDetailTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/18.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh
import Toaster

class OrderDetailTableViewController: UITableViewController {
    
    var data : JSON?
    var detail : JSON!
    var woId = 0
    let titles = ["工  单  号：" , "工单名称：" , "工单备注：" , "工单种类：" ,
                  "客户姓名：" , "联系方式：" , "进        度：" , "下  单  人：" , "下单时间："]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.loadData()
        })
        tableView.mj_header.beginRefreshing()
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailTableViewController.handleNotification(notification:)), name: Notification.Name(NotificationName.OrderDetail.rawValue), object: nil)
        
        if self.detail?["progress"].intValue == 2 {
            self.navigationItem.rightBarButtonItem = nil
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "处理", style: .plain, target: self, action: #selector(OrderDetailTableViewController.handle(_:)))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWODetail, params: ["woId" : woId]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.data = object["data"]
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

    func handle(_ sender: Any) {
        
        let action = UIAlertController(title: "操作", message: nil, preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "指派", style: .default, handler: {[weak self] (action) in
            self?.performSegue(withIdentifier: "userlist", sender: self)
        }))
        action.addAction(UIAlertAction(title: "闭单", style: .default, handler: {[weak self] (action) in
            self?.closeOrder()
        }))
        self.present(action, animated: true) { 
            
        }
        
    }
    
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : JSON] {
                    let alert = UIAlertController(title: "指派给\(userInfo["nickname"]?.string ?? "")", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] (action) in
                        if let desc = alert.textFields?.first?.text {
                            self?.assign(userInfo: userInfo, desc: desc)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        
                    }))
                    alert.addTextField(configurationHandler: { (textField) in
                        textField.placeholder = "请输入指派说明"
                    })
                    self.present(alert, animated: true, completion: { 
                        
                    })
                }
            }
        }
    }
    
    func assign(userInfo: [String : JSON] , desc : String)  {
        let hud = showHUD(text: "指派中...")
        let tomove = userInfo["id"]?.string ?? ""
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWOAssign, params: ["tomove" : tomove , "woId" : woId , "remarks" : desc]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    Toast(text: "指派成功").show()
                    self?.navigationController?.popViewController(animated: true)
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
    
    // 闭单
    func closeOrder()  {
        let alert = UIAlertController(title: "闭单", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] (action) in
            if let desc = alert.textFields?.first?.text {
                self?.closeOrder(desc: desc)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "请输入闭单说明"
        })
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    func closeOrder(desc: String) {
        let hud = showHUD(text: "闭单中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWOClose, params: ["woId" : woId , "remarks" : desc]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    Toast(text: "闭包成功").show()
                    self?.navigationController?.popViewController(animated: true)
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 9 + (data?["orderstr"].array?.count ?? 0)
        }else{
            return data?["accounts"].array?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            if let label = cell.viewWithTag(2) as? UILabel {
                if  indexPath.row < 9 {
                    label.text = titles[indexPath.row]
                }else{
                    label.text = "\(data?["orderstr" , indexPath.row - 9 , "name"].string ?? "")："
                }
                
                if indexPath.row < 4 {
                    label.textColor = UIColor.red
                }else{
                    label.textColor = UIColor.darkGray
                }
            }
            if let label = cell.viewWithTag(3) as? UILabel {
                if indexPath.row < 9 {
                    switch indexPath.row {
                    case 0:
                        label.text = detail["order_num"].string
                    case 1:
                        label.text = detail["work_title"].string
                    case 2:
                        label.text = detail["orderremark"].string
                    case 3:
                        label.text = detail["typename"].string
                    case 4:
                        label.text = detail["cust_name"].string
                    case 5:
                        label.text = ""
                    case 6:
                        label.text = (detail["progress"].string == "1") ? "处理中" : "已处理"
                    case 7:
                        label.text = detail["add_user"].string
                    case 8:
                        label.text = detail["add_time"].string
                    default:
                        fatalError()
                    }
                }else{
                    label.text = data?["orderstr" , indexPath.row - 9 , "value"].string
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            if let imageView = cell.viewWithTag(2) as? UIImageView {
                let image = UIImage(named: "bg_diggle_white")?.resizableImage(withCapInsets: UIEdgeInsetsMake(40, 30, 22, 20))
                imageView.image = image
            }
            if let label = cell.viewWithTag(3) as? UILabel {
                label.text = data?["accounts" , indexPath.row , "fromname"].string
            }
            if let label = cell.viewWithTag(4) as? UILabel {
                let type = data?["accounts" , indexPath.row , "type"].string
                label.text = type == "1" ? "" : data?["accounts" , indexPath.row , "toname"].string
            }
            if let label = cell.viewWithTag(5) as? UILabel {
                label.text = data?["accounts" , indexPath.row , "remarks"].string
            }
            if let label = cell.viewWithTag(6) as? UILabel {
                label.text = data?["accounts" , indexPath.row , "removetime"].string
            }
            if let label = cell.viewWithTag(7) as? UILabel {
                // 0转移 1闭单 2新建
                if let type = data?["accounts" , indexPath.row , "type"].string {
                    if type == "0" {
                        label.text = "将工单指派给"
                    }else if type == "1" {
                        label.text = "将工单关闭"
                    }else if type == "2" {
                        label.text = "新建工单指派给"
                    }
                }
                
            }
            if let imageView = cell.viewWithTag(10) as? UIImageView {
                let count = data?["accounts"].array?.count ?? 0
                imageView.isHidden = indexPath.row == count - 1
            }
            if let imageView = cell.viewWithTag(11) as? UIImageView {
                imageView.isHidden = indexPath.row == 0
            }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }else{
            return 150
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
