//
//  OrderNewViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/26.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster
import TabPageViewController

class OrderNewViewController: UIViewController {
    @IBOutlet weak var lblHandler: UILabel!
    @IBOutlet weak var vHandler: UIView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfFrom: UITextField!
    @IBOutlet weak var tfQuestion: UITextField!
    @IBOutlet weak var tvRemark: PlaceholderTextView!
    @IBOutlet weak var vOther: UIView!
    @IBOutlet weak var lcHeight: NSLayoutConstraint!
    var tid = 0
    var tType = ""
    var height : CGFloat = 0
    var custId = 0
    var customer = ""
    var tomove = 0
    var other : [JSON] = []
    var content : [String : String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfQuestion.text = tType
        tfFrom.text = customer
        tfFrom.isUserInteractionEnabled = false
        tfQuestion.isUserInteractionEnabled = false
        vHandler.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1).cgColor
        vHandler.layer.borderWidth = 0.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(OrderNewViewController.tap(recognizer:)))
        vHandler.addGestureRecognizer(tap)
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(OrderNewViewController.handleNotification(notification:)), name: Notification.Name("ordernew"), object: nil)
    }
    
    // 点击事件，选择用户列表
    func tap(recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "userlist") as? UserListTableViewController {
            controller.flag = 1
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 处理通知
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : Any] {
                    let json = JSON(userInfo)
                    tomove = Int(json["id"].stringValue)!
                    lblHandler.text = json["nickname"].string
                }
            }else if tag == 2 {
                if let userInfo = notification.userInfo as? [String : String] {
                    content[userInfo["fname"]!] = userInfo["value"]!
                }
            }else if tag == 3 {
                if let userInfo = notification.userInfo as? [String : String] {
                    if userInfo["select"] == "0" {
                        let value = content[userInfo["fname"]!]!
                        let val = userInfo["value"]!
                        if value.hasPrefix(val) {
                            if value.contains(",") {
                                let v = value.replacingOccurrences(of: "\(val),", with: "")
                                content[userInfo["fname"]!] = v
                            }else{
                                content[userInfo["fname"]!] = ""
                            }
                        }else{
                            let v = value.replacingOccurrences(of: ",\(val)", with: "")
                            content[userInfo["fname"]!] = v
                        }
                    }else{
                        if content[userInfo["fname"]!] != nil {
                            let value = content[userInfo["fname"]!]!
                            content[userInfo["fname"]!] = "\(value),\(userInfo["value"]!)"
                        }else{
                            content[userInfo["fname"]!] = userInfo["value"]!
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWOTempDetail, params: ["tid" : tid]){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    if let array = object["data"].array {
                        self?.other += array
                        for (index , value) in array.enumerated() {
                            self?.addInputView(json: value, tag: index)
                        }
                        self?.lcHeight.constant = self!.height
                    }
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
    
    func rightView(name : String, size : CGSize) -> UIView {
        let view = UIView()
        view.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        let iv = UIImageView(image: UIImage(named: name))
        iv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iv)
        view.addConstraint(NSLayoutConstraint(item: iv, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: iv, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: iv, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: size.width))
        view.addConstraint(NSLayoutConstraint(item: iv, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: size.height))
        
        return view
    }
    
    func addInputView(json : JSON ,  tag : Int) {
        if let inputView = Bundle.main.loadNibNamed("InputView", owner: nil, options: nil)?.first as? InputView {
            inputView.tag = tag
            inputView.item = json
            inputView.translatesAutoresizingMaskIntoConstraints = false
            vOther?.addSubview(inputView)
            var cellheight : CGFloat = 0
            let type = json["ftype"].stringValue
            inputView.label.text = json["fname"].string
            if type == "char" {
                //inputView.textField.keyboardType = .numberPad
                let textField = inputView.textField as UITextField
                textField.placeholder = "请输入\(json["fname"].stringValue)"
                cellheight = 91
            }else if type == "radio" {
                inputView.textField.isHidden = true
                if let keyValues = json["items"].array {
                    inputView.addRadioButton(keyValues: keyValues)
                    let row = keyValues.count % 3 == 0 ? keyValues.count / 3 : (keyValues.count / 3 + 1)
                    cellheight = CGFloat(row * 44 + 91 - 40)
                }
            }
            
            vOther?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[inputView(width)]|", options: .directionLeadingToTrailing, metrics: ["width" : SCREENWIDTH], views: ["inputView" : inputView]))
            vOther?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[inputView(cellheight)]", options: .directionLeadingToTrailing, metrics: ["top" : height , "cellheight" : cellheight], views: ["inputView" : inputView]))
            
            height += cellheight
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        self.view.endEditing(true)
        guard let title = tfTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            Toast(text: "请输入工单标题").show()
            return
        }
        if tomove == 0 {
            Toast(text: "请选择指派人").show()
            return
        }
        for value in other {
            let type = value["ftype"].stringValue
            let fname = value["fname"].stringValue
            if type == "char" {
                if content[fname] == nil || content[fname] == "" {
                    Toast(text: "请输入\(fname)").show()
                    return
                }
            }else if type == "radio" {
                if content[fname] == nil || content[fname] == "" {
                    Toast(text: "请选择\(fname)").show()
                    return
                }
            }
        }
        var params : [String : Any] = ["custId" : custId , "typeid" : tid , "work_title" : title , "tomove" : tomove]
        let remark = tvRemark.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if remark.characters.count > 0 {
            params["remark"] = remark
        }
        if content.count > 0 {
            var con = ""
            do {
                let data = try JSONSerialization.data(withJSONObject: self.content, options: .prettyPrinted)
                con = String(data: data, encoding: .utf8)!
            }catch {
                print(error)
                return
            }
            params["content"] = con
        }
        let hud = showHUD(text: "提交中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appAddCustTicket, params: params){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    Toast(text: "添加工单成功").show()
                    for controller in self!.navigationController!.viewControllers {
                        if controller is TabPageViewController {
                            _ = self?.navigationController?.popToViewController(controller, animated: true)
                        }
                    }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
