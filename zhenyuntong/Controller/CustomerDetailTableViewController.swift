//
//  CustomerDetailTableViewController.swift
//  BaiRong
//
//  Created by 张晓飞 on 2017/7/28.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class CustomerDetailTableViewController: UITableViewController, CustomDetailTableViewCellDelegate {
    
    let arrTitle = ["姓名：", "数据批次：", "归属项目：", "手机号码：", "归属人：", "备注：", "添加时间："]
    var json : JSON! = nil
    var rows : [String : Any] = [:]
    var bCustomer = false
    var level = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let hud = showHUD(text: "加载中...")
        var params : [String : Any] = [:]
        if bCustomer {
            params["mobile"] = json["phmobile"].stringValue
        }else{
            params["id"] = json["id"].stringValue
        }
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appCustDetail, params: params ){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let total = object["total"].int, total > 0 {
                    self!.level = object["level"].intValue
                    if let arr = object["rows"].dictionaryObject {
                        self!.rows = arr
                    }
                    self?.tableView.reloadData()
                }else{
                    if let info = object["info"].string {
                        Toast(text: info).show()
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
            }
        }
    }
    
    @IBAction func showStar(_ sender: Any) {
        if level == 0 {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "PortrayalDetail") as? PortrayalDetailTableViewController {
                controller.json = JSON(rows)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }else{
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "PortrayalList") as? PortrayalTableViewController {
                controller.hidesBottomBarWhenPushed = true
                controller.mobile = json["phmobile"].stringValue
                controller.flag = 1
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
    }

    @IBAction func showHistoryRecord(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Follow") as? FollowTableViewController {
            if !bCustomer {
                controller.strId = json["id"].stringValue
            }
            controller.mobile = json["phmobile"].stringValue
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! CustomDetailTableViewCell
        cell.delegate = self

        if let label = cell.contentView.viewWithTag(1) as? UILabel {
            label.text = arrTitle[indexPath.row]
        }
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            switch indexPath.row {
            case 0:
                label.text = rows["customer"] as? String ?? ""
            case 1:
                label.text = rows["cust_batch"] as? String ?? ""
            case 2:
                label.text = rows["proname"] as? String ?? ""
            case 3:
                label.text = rows["mobile"] as? String ?? ""
            case 4:
                label.text = rows["adduser"] as? String ?? ""
            case 5:
                label.text = rows["remark"] as? String ?? ""
            case 6:
                label.text = rows["addtime"] as? String ?? ""
            default:
                fatalError()
            }
        }
        if let button = cell.contentView.viewWithTag(3) as? UIButton {
            if indexPath.row == 3 {
                button.isHidden = false
            }else{
                button.isHidden = true
            }
        }
        if let button = cell.contentView.viewWithTag(4) as? UIButton {
            if indexPath.row == 3 {
                button.isHidden = false
            }else{
                button.isHidden = true
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITable view cell delegate
    func call(tag: Int) {
        let hud = showHUD(text: "提交中...")
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appClickCall, params: ["mobile" : json["phmobile"].stringValue]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let status = object["status"].int, status == 1 {
                    let alertController = UIAlertController(title: "呼叫成功，请等待回拨电话并接听", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "确定", style: .cancel, handler: {[weak self] (action) in
                        if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "AddFollow") as? AddFollowViewController {
                            controller.json = self!.json
                            self?.navigationController?.pushViewController(controller, animated: true)
                        }
                    }))
                    self?.present(alertController, animated: true, completion: {
                        
                    })
                }else{
                    if let info = object["info"].string {
                        Toast(text: info).show()
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
            }
        }
    }
    
    func search(tag: Int) {
        
        guard let name = rows["customer"] as? String , name.characters.count > 0 else {
            Toast(text: "客户姓名为空，无法查询").show()
            return
        }
        guard let mobile = rows["phmobile"] as? String , mobile.characters.count > 0 else {
            Toast(text: "手机号码为空，无法查询").show()
            return
        }
        let hud = showHUD(text: "加载中...")
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appFigure, params: ["mobile" : mobile, "name": name]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let status = object["status"].int, status == 1 {
                    if let arr = object["info"].array, arr.count > 0 {
                        if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "PortrayalDetail") as? PortrayalDetailTableViewController {
                            controller.json = arr[0]
                            self?.navigationController?.pushViewController(controller, animated: true)
                        }
                    }else{
                        Toast(text: "无数据").show()
                    }
                }else{
                    if let info = object["info"].string {
                        Toast(text: info).show()
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
            }
        }
    }

}
