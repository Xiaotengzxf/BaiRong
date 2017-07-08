//
//  CustomerDetailTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/25.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class CustomerDetailTableViewController: UITableViewController {

    // connLabel
    let titles = ["客户名称：", "公司名称：" , "客户分类：" , "手机号码：" , "电话号码：" , "添  加  人：" , "添加时间：" ,
                  "地        址：" , "备        注："]
    var data : JSON!
    @IBOutlet weak var footerView: UIView!
    var x : CGFloat = 16
    var y : CGFloat = 10
    var labels : [String] = []
    var bSingle = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView?.frame = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: 64)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if bSingle {
            return
        }
        bSingle = true
        if let connLabel = data["connLabel"].string {
            let array = connLabel.components(separatedBy: ",")
            if array.count > 0 {
                labels += array
                print("标签:\(labels)")
            }
        }
        loadLabel()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDefaultValue(value : String?) -> String {
        if value == nil || value!.characters.count == 0 {
            return " "
        }
        return value ?? " "
    }
    
    func loadLabel() {
        if labels.count > 0 {
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appCustLabel, params: nil){
                [weak self] (json , error) in
                if let object = json {
                    if let result = object["result"].int {
                        if result == 1000 {
                            if let array = object["data"].array {
                                var count = 0
                                for json in array {
                                    if let jid = json["id"].string {
                                        if self!.labels.contains(jid) {
                                            count += 1
                                            let label = UILabel()
                                            let name = json["name"].string
                                            let size = NSString(string: name!).size(attributes: [UIFontDescriptorNameAttribute : UIFont.systemFont(ofSize: 16)])
                                            label.text = name
                                            label.textAlignment = .center
                                            label.layer.cornerRadius = 15.0
                                            label.clipsToBounds = true
                                            label.font = UIFont.systemFont(ofSize: 16)
                                            label.textColor = UIColor.white
                                            label.backgroundColor = UIColor.colorWithHexString(hex: json["color"].stringValue)
                                            label.translatesAutoresizingMaskIntoConstraints = false
                                            self?.footerView?.addSubview(label)
                                            
                                            if (self!.x + size.width + 40 + 16) > SCREENWIDTH {
                                                self!.x = 16
                                                self!.y += 40
                                            }
                                            self?.footerView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(x)-[label(w)]", options: .directionLeadingToTrailing, metrics: ["x" : self!.x , "w" : size.width + 40], views: ["label" : label]))
                                            self?.footerView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(y)-[label(30)]", options: .directionLeadingToTrailing, metrics: ["y" : self!.y], views: ["label" : label]))
                                            self!.x += size.width + 40 + 16
                                        }
                                    }
                                }
                                if count > 0 {
                                    self?.footerView?.bounds = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: self!.y + 40)
                                    self?.tableView.tableFooterView?.bounds = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: self!.y + 40)
                                }
                            }
                            
                        }
                    }
                }
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
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = titles[indexPath.row]
        }
        
        if let label = cell.viewWithTag(3) as? UILabel {
            switch indexPath.row {
            case 0:
                label.text = setDefaultValue(value: data["customer"].string)
                label.textColor = UIColor.darkGray
            case 1:
                label.text = setDefaultValue(value: data["connName"].string)
                label.textColor = UIColor.darkGray
            case 2:
                label.text = setDefaultValue(value: data["connType"].string)
                label.textColor = UIColor.darkGray
            case 3:
                label.text = setDefaultValue(value: data["mobile"].string)
                label.textColor = UIColor(red: 30/255.0, green: 160/255.0, blue: 20/255.0, alpha: 1)
            case 4:
                label.text = setDefaultValue(value: data["phone"].string)
                label.textColor = UIColor(red: 30/255.0, green: 160/255.0, blue: 20/255.0, alpha: 1)
            case 5:
                label.text = setDefaultValue(value: data["adduser"].string)
                label.textColor = UIColor.darkGray
            case 6:
                label.text = setDefaultValue(value: data["add_time"].string)
                label.textColor = UIColor.darkGray
            case 7:
                label.text = setDefaultValue(value: data["address"].string)
                label.textColor = UIColor.darkGray
            case 8:
                label.text = setDefaultValue(value: data["remark"].string)
                label.textColor = UIColor.darkGray
            default:
                fatalError()
            }
        }
        
        if let imageView = cell.viewWithTag(5) as? UIImageView {
            if indexPath.row == 2 || indexPath.row == 3 {
                if indexPath.row == 2 {
                    if let mobile = data["mobile"].string ,mobile.characters.count > 0 {
                        imageView.isHidden = false
                    }else{
                        imageView.isHidden = true
                    }
                }else{
                    if let mobile = data["phone"].string ,mobile.characters.count > 0 {
                        imageView.isHidden = false
                    }else{
                        imageView.isHidden = true
                    }
                }
                
            }else{
                imageView.isHidden = true
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 2 {
            if MODELITEM == "外出模式" {
                if let phone = data["mobile"].string {
                    openUrlForCall(mobile: phone)
                }
            }else{
                Toast(text: "请在首页将工作模式设置为外出模式").show()
            }
            
            
        }else if indexPath.row == 3 {
            if MODELITEM == "外出模式" {
                if let mobile = data["phone"].string {
                    openUrlForCall(mobile: mobile)
                }
            }else{
                Toast(text: "请在首页将工作模式设置为外出模式").show()
            }
        }
    }
    
    func openUrlForCall(mobile : String) {
        let alert = UIAlertController(title: "系统提示", message: "确定回拨该客户吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] (action) in
            //UIApplication.shared.openURL(URL(string: "tel://\(mobile)")!)
            self?.callback(mobile: mobile)
        }))
        self.present(alert, animated: true) { 
            
        }
    }
    
    func callback(mobile : String)  {
        let hud = showHUD(text: "回拨中...")
        if let userinfo = UserDefaults.standard.object(forKey: "mine") as? [String : Any] {
            let exten = userinfo["exten"] as? String ?? ""
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appCallBack, params: ["exten": exten , "toPhone": mobile]){
                (json , error) in
                hud.hide(animated: true)
                if let object = json {
                    if let result = object["result"].int {
                        if result == 1000 {
                            Toast(text: "回拨成功，请耐心等待！").show()
                        }else{
                            if let msg = object["msg"].string {
                                Toast(text: msg).show()
                            }
                        }
                    }
                }else{
                    Toast(text: "网络异常，请检查网络").show()
                }
            }
        }
    }
    
    @IBAction func startCommercial(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "commercialadd") as? CommercialAddViewController {
            controller.title = "发起商机"
            controller.cust_id = data?["id"].string ?? ""
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
