//
//  AreaListTableViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/11.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster
import DZNEmptyDataSet

class UserListTableViewController: UITableViewController, DZNEmptyDataSetDelegate , DZNEmptyDataSetSource , UserListTableViewCellDelegate {
    
    var areas : [JSON] = []
    var data : [String : JSON] = [:]
    var capital : [String : [String]] = [:]
    var indexes : [String] = []
    var other : [Int] = []
    var bOffset = false
    var flag = 0  // 标识来源处理通知
    var bSearch = false
    var nShowEmpty = 2 // 1 无数据 2 加载中 3 无网络
    var search = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.sectionIndexColor = UIColor.darkGray
        if bOffset {
            tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(UserListTableViewController.handleNotification(notification:)), name: Notification.Name("userlist"), object: nil)
        if bSearch {
            navigationItem.rightBarButtonItem = nil
        }
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : Any] {
                    if let message = userInfo["message"] as? String {
                        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "userlist") as? UserListTableViewController {
                            controller.search = message
                            controller.bSearch = true
                            controller.title = "搜索结果"
                            controller.flag = flag
                            controller.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(controller, animated: true)
                            
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - 自定义方法
    
    func loadData() {
        NetworkManager.installshared.request(type: .get, url: flag > 0 ? NetworkManager.installshared.appWOAppoint : NetworkManager.installshared.appUserList, params: ["search" : search]){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    if let array = object["data"].array {
                        if array.count == 0 {
                            self?.nShowEmpty = 1
                        }else{
                            self?.nShowEmpty = 0
                        }
                        self?.areas += array
                        if self!.bSearch {
                            
                        }else{
                            let keys = array.map{$0["nickname"].stringValue}
                            var k : Set<String> = []
                            var ks : [String : [String]] = [:]
                            for key in keys {
                                let c = NSString(format: "%c", pinyinFirstLetter(NSString(string : key).character(at: 0))).uppercased
                                k.insert(c)
                                if let _ = ks[c] {
                                    ks[c]! += [key]
                                }else{
                                    ks[c] = [key]
                                }
                            }
                            let arrk = Array(k)
                            self!.indexes = arrk.sorted(by: <)
                            for index in self!.indexes {
                                let array = ks[index]!.sorted(by: { (s1, s2) -> Bool in
                                    let str1 = NSString(string : s1)
                                    let mStr1 = NSMutableString()
                                    for i in 0..<str1.length  {
                                        mStr1.appendFormat("%c", pinyinFirstLetter(str1.character(at: i)))
                                    }
                                    let str2 = NSString(string : s2)
                                    let mStr2 = NSMutableString()
                                    for i in 0..<str2.length  {
                                        mStr2.appendFormat("%c", pinyinFirstLetter(str2.character(at: i)))
                                    }
                                    return String(mStr1).compare(String(mStr2)) == .orderedAscending
                                })
                                self!.capital[index] = array
                            }
                            
                            for json in array {
                                self?.data[json["nickname"].stringValue] = json
                            }
                        }
                    }
                    self?.tableView.reloadData()
                }else{
                    self?.nShowEmpty = 1
                    self?.tableView.reloadData()
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                self?.nShowEmpty = 3
                self?.tableView.reloadData()
                print(error?.localizedDescription ?? "")
                Toast(text: "网络出错，请检查网络").show()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if bSearch {
            return 1
        }else{
            return indexes.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bSearch {
            return areas.count
        }else{
            return capital[indexes[section]]?.count ?? 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserListTableViewCell
        var json : JSON?
        if bSearch {
            json = areas[indexPath.row]
        }else{
            if let array = capital[indexes[indexPath.section]] {
                json = data[array[indexPath.row]]
                
            }
        }
        if let icon = json?["img"].string {
            cell.ivHead.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "header_default"))
        }else{
            cell.ivHead.image = UIImage(named: "header_default")
        }
        cell.delegate = self
        cell.json = json!
        cell.lblName.text = json?["nickname"].string
        cell.lblDepartment.text = json?["status"].string  == "0" ? "禁用" : "启用"
        cell.lblDepartment.textColor = json?["status"].string  == "0" ? (UIColor.red) : (UIColor(red: 30/255.0, green: 160/255.0, blue: 20/255.0, alpha: 1))
        cell.btnCall.isHidden = (json?["mobile"].string == nil || json?["mobile"].string?.characters.count == 0) ? true : false
        cell.lblStatus.text = json!["depname"].stringValue + json!["priname"].stringValue
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if bSearch {
            return nil
        }else{
            return indexes[section]
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if bSearch {
            return 0
        }else{
            return indexes.index(of: title) ?? 0
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if  bSearch {
            return nil
        }else{
            return indexes
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if bOffset == false {
            if bSearch == false {
                if let array = capital[indexes[indexPath.section]] {
                    let json = data[array[indexPath.row]]
                    if flag == 0 {
                        let dict = json?.dictionaryValue
                        NotificationCenter.default.post(name: Notification.Name(NotificationName.OrderDetail.rawValue), object: 1, userInfo: dict)
                    }else if flag == 1 {
                        NotificationCenter.default.post(name: Notification.Name("ordernew"), object: 1, userInfo: json?.dictionaryValue)
                    }
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    func makeCall(mobile: String) {
        let alert = UIAlertController(title: mobile, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            UIApplication.shared.openURL(URL(string: "tel://\(mobile)")!)
        }))
        self.present(alert, animated: true) { 
            
        }
    }
    
    

    // MARK: - 空数据
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        var name = ""
        if nShowEmpty == 1 {
            name = "empty"
        }else if nShowEmpty == 2 {
            name = "jiazaizhong"
        }else if nShowEmpty == 3 {
            name = "empty"
        }
        return UIImage(named: name)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var message = ""
        if nShowEmpty == 1 {
            message = "世界上最遥远的距离就是没有WIFI...\n请点击屏幕重新加载！"
        }else if nShowEmpty == 2 {
            message = "加载是件正经事儿，走心加载中..."
        }else if nShowEmpty == 3 {
            message = "空空如也，啥子都没有噢！"
        }
        let att = NSMutableAttributedString(string: message)
        att.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, att.length))
        return att
    }
    
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty == 2
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        if nShowEmpty > 0 && nShowEmpty != 2 {
            nShowEmpty = 2
            tableView.reloadData()
            loadData()
        }
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty > 0
    }
    
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0))
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0))
        animation.duration = 0.5
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }


}
