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

class CustomerDetailTableViewController: UITableViewController {
    
    let arrTitle = ["姓名：", "数据批次：", "归属项目：", "手机号码：", "归属人：", "备注：", "添加时间："]
    var json : JSON! = nil
    var rows : [String : Any] = [:]

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
        //var mobile =
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appCustDetail, params: ["mobile" : json["phmobile"].stringValue , "id" : json["id"].stringValue] ){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let total = object["total"].int, total > 0 {
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
        Toast(text: "正在开发中，敬请期待...").show()
    }

    @IBAction func showHistoryRecord(_ sender: Any) {
        Toast(text: "正在开发中，敬请期待...").show()
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)

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
                label.text = rows["project_id"] as? String ?? ""
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

}
