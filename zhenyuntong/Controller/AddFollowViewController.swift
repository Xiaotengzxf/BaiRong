//
//  AddFollowViewController.swift
//  BaiRong
//
//  Created by ANKER on 2017/8/1.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class AddFollowViewController: UIViewController, RadioViewDelegate {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var btnResult: UIButton!
    @IBOutlet weak var lc1T: NSLayoutConstraint!
    @IBOutlet weak var lc2T: NSLayoutConstraint!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var lc2H: NSLayoutConstraint!
    @IBOutlet weak var iv2: UIImageView!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lc3T: NSLayoutConstraint!
    @IBOutlet weak var iv3: UIImageView!
    @IBOutlet weak var lc3H: NSLayoutConstraint!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var lc4H: NSLayoutConstraint!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var iv4: UIImageView!
    @IBOutlet weak var lc4T: NSLayoutConstraint!
    @IBOutlet weak var tvContent: UITextView!
    var json : JSON!
    var arrConfig : [JSON] = []
    var radioView : RadioView?
    var array1 : [JSON] = []
    var array2 : [JSON] = []
    var array3 : [JSON] = []
    var array4 : [JSON] = []
    var dicPop : JSON?
    var fo_callresult = 0
    var fo_handle = 0
    var nTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tvContent.layer.borderWidth = 0.5
        tvContent.layer.borderColor = UIColor.lightGray.cgColor
        
        addPopWindow()
        appCallResultConfig()
        
        lc1T.constant = 0
        btn2.isHidden = true
        lc2H.constant = 0
        iv2.isHidden = true
        lc2T.constant = 0
        lbl2.isHidden = true
        lc3T.constant = 0
        lc3H.constant = 0
        iv3.isHidden = true
        btn3.isHidden = true
        lc4T.constant = 0
        btn4.isHidden = true
        iv4.isHidden = true
        lc4H.constant = 0
        
        if let customer = json["customer"].string, customer.characters.count > 0 {
            tfName.text = customer
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectCallResult(_ sender: Any) {
        if arrConfig.count == 0 {
            Toast(text: "数据获取异常，请稍后重试").show()
            appCallResultConfig()
            return
        }
        let button = sender as! UIButton
        nTag = button.tag
        var array : [JSON] = []
        switch nTag {
        case 10:
            array1.removeAll()
            for item in arrConfig {
                if item["type"].stringValue == "1" && item["level"].stringValue == "2" && item["_parentId"].stringValue == "1" {
                    array1.append(item)
                }
            }
            array = array1
        case 11:
            array = array2
        case 12:
            array = array3
        case 13:
            array = array4
        default:
            fatalError()
        }
        if radioView == nil {
            if array.count == 0 {
                return
            }
            radioView = RadioView(frame: .zero)
            radioView?.delegate = self
            radioView?.tableData = array.map{$0["name"].stringValue}
            radioView?.translatesAutoresizingMaskIntoConstraints = false
            radioView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.view.addSubview(radioView!)
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[radioView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["radioView" : radioView!]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[radioView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["radioView" : radioView!]))
            
            radioView?.addSubTableView()
        }
    }
    
    func showRadioView() {
        
    }
    
    @IBAction func save(_ sender: Any) {
        tfName.resignFirstResponder()
        tvContent.resignFirstResponder()
        let name = tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let content = tvContent.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let hud = showHUD(text: "提交中...")
        var params : [String : Any] = ["mobile" : json["phmobile"].stringValue, "customer": name, "projectid" : json["projectid"].stringValue, "fo_project": dicPop!["fo_project"].stringValue, "fo_content": content, "fo_callresult": fo_callresult, "fo_handle": fo_handle]
        if let cid = dicPop!["cid"].string, cid != "0" && cid.characters.count > 0 {
            params["cid"] = cid
        }
        if let taskid = dicPop!["taskid"].string, taskid != "0" && taskid.characters.count > 0 {
            params["taskid"] = taskid
        }
        if self.arrConfig.count > 0, let custbatch = arrConfig[0]["custbatch"].string, custbatch.characters.count > 0 {
            params["custbatch"] = custbatch
        }else{
            if let custbatch = json["custbatch"].string, custbatch.characters.count > 0 {
                params["custbatch"] = custbatch
            }else if let custbatch = json["cust_batch"].string, custbatch.characters.count > 0{
                params["custbatch"] = custbatch
            }
        }
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appCustfollow, params: params){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let info = object["info"].string {
                    Toast(text: info).show()
                }
                if let status = object["status"].int, status == 1 {
                    self?.navigationController?.popViewController(animated: true)
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
            }
        }
    }
    
    func addPopWindow() {
        var params : [String : Any] = ["mobile" : json["phmobile"].stringValue, "customer": json["name"].stringValue, "projectid" : json["projectid"].stringValue]
        if let taskid = json["task_id"].string, taskid.characters.count > 0 {
            params["taskid"] = taskid
        }
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appPopWindow, params: params){
            [weak self] (json , error) in
            if let object = json {
                if let total = object["total"].int, total == 1 {
                    self?.dicPop = object["rows"]
                    self?.showButton()
                    //self?.tvContent.text = self!.dicPop!["fo_content"].stringValue
                    if let customer = self!.json["customer"].string, customer.characters.count > 0 {
                        
                    }else{
                        self?.tfName.text = self!.dicPop!["customer"].stringValue
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
            }
        }
    }
    
    func appCallResultConfig() {
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appCallResultConfig, params: nil){
            [weak self] (json , error) in
            if let object = json {
                if let total = object["total"].int, total > 0 {
                    if let array = object["rows"].array {
                        self?.arrConfig = array
                        self?.showButton()
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
            }
        }
    }
    
    func showButton() {
        if let fo1 = dicPop?["fo_callresult"].string, fo1.characters.count > 0 {
            fo_callresult = Int(fo1) ?? 0
            if arrConfig.count > 0 {
                for item in arrConfig {
                    if item["id"].stringValue == fo1 {
                        if item["_parentId"].stringValue == "1" {
                            btnResult.setTitle(item["name"].stringValue, for: .normal)
                            btnResult.isUserInteractionEnabled = false
                        }else{
                            btnResult.isUserInteractionEnabled = false
                            btn2.isUserInteractionEnabled = false
                            btn2.setTitle(item["name"].stringValue, for: .normal)
                            lc1T.constant = 10
                            btn2.isHidden = false
                            lc2H.constant = 40
                            iv2.isHidden = false
                            for config in arrConfig {
                                if item["_parentId"].stringValue == config["id"].stringValue {
                                    btnResult.setTitle(config["name"].stringValue, for: .normal)
                                    break
                                }
                            }
                        }
                        break
                    }
                }
            }
        }
        
        if let fo2 = dicPop?["fo_handle"].string, fo2.characters.count > 0 {
            fo_handle = Int(fo2) ?? 0
            if arrConfig.count > 0 {
                for item in arrConfig {
                    if item["id"].stringValue == fo2 {
                        if item["_parentId"].stringValue == "2" {
                            btn3.setTitle(item["name"].stringValue, for: .normal)
                            lc2T.constant = 10
                            lbl2.isHidden = false
                            lc3T.constant = 10
                            lc3H.constant = 40
                            iv3.isHidden = false
                            btn3.isHidden = false
                            for item in arrConfig {
                                if item["type"].stringValue == "2" && item["_parentId"].stringValue == "2" {
                                    array3.append(item)
                                }
                            }
                        }else{
                            btn4.setTitle(item["name"].stringValue, for: .normal)
                            lc2T.constant = 10
                            lbl2.isHidden = false
                            lc3T.constant = 10
                            lc3H.constant = 40
                            iv3.isHidden = false
                            btn3.isHidden = false
                            lc4T.constant = 10
                            btn4.isHidden = false
                            iv4.isHidden = false
                            lc4H.constant = 40
                            for config in arrConfig {
                                if item["_parentId"].stringValue == config["id"].stringValue {
                                    btn3.setTitle(config["name"].stringValue, for: .normal)
                                    for item2 in arrConfig {
                                        if item2["_parentId"].stringValue == "\(config["id"].stringValue)" && item2["type"].stringValue == "2" {
                                            array4.append(item2)
                                        }
                                    }
                                    break
                                }
                            }
                            for item in arrConfig {
                                if item["type"].stringValue == "2" && item["_parentId"].stringValue == "2" {
                                    array3.append(item)
                                }
                            }
                            
                        }
                        break
                    }
                }
            }
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddAppointmentViewController {
            controller.json = json
        }
    }
    
    func getSelected(title : String, row : Int, type : Int) {
        removeRadioView()
        if nTag == 10 {
            fo_callresult = Int(array1[row]["id"].stringValue) ?? 0
            array2.removeAll()
            for item in arrConfig {
                if item["_parentId"].stringValue == "\(fo_callresult)" &&  item["type"].stringValue == "1" {
                    array2.append(item)
                }
            }
            if fo_callresult == 9 {
                btnResult.setTitle(title, for: .normal)
                lc2T.constant = 10
                lbl2.isHidden = false
                lc3T.constant = 10
                lc3H.constant = 40
                iv3.isHidden = false
                btn3.isHidden = false
                if fo_handle > 0 {
                    lc4T.constant = 10
                    btn4.isHidden = false
                    iv4.isHidden = false
                    lc4H.constant = 40
                } else {
                    lc4T.constant = 0
                    btn4.isHidden = true
                    iv4.isHidden = true
                    lc4H.constant = 0
                }
                for item in arrConfig {
                    if item["type"].stringValue == "2" && item["_parentId"].stringValue == "2" {
                        array3.append(item)
                    }
                }
            }else {
                btnResult.setTitle(title, for: .normal)
                lc2T.constant = 0
                lbl2.isHidden = true
                lc3T.constant = 0
                lc3H.constant = 0
                iv3.isHidden = true
                btn3.isHidden = true
                lc4T.constant = 0
                btn4.isHidden = true
                iv4.isHidden = true
                lc4H.constant = 0
                array3.removeAll()
            }
            if array2.count > 0 {
                lc1T.constant = 10
                btn2.isHidden = false
                lc2H.constant = 40
                iv2.isHidden = false
                fo_callresult = Int(array2[0]["id"].stringValue) ?? 0
                btn2.setTitle(array2[0]["name"].stringValue, for: .normal)
            }else{
                lc1T.constant = 0
                btn2.isHidden = true
                lc2H.constant = 0
                iv2.isHidden = true
            }
            
        }else if nTag == 11 {
            fo_callresult = Int(array2[row]["id"].stringValue) ?? 0
            btn2.setTitle(array2[row]["name"].stringValue, for: .normal)
        }else if nTag == 12 {
            fo_handle = Int(array3[row]["id"].stringValue) ?? 0
            btn3.setTitle(array3[row]["name"].stringValue, for: .normal)
            array4.removeAll()
            for item in arrConfig {
                if item["_parentId"].stringValue == "\(fo_handle)" && item["type"].stringValue == "2" {
                    array4.append(item)
                }
            }
            if array4.count > 0 {
                lc4T.constant = 10
                btn4.isHidden = false
                iv4.isHidden = false
                lc4H.constant = 40
                fo_handle = Int(array4[0]["id"].stringValue) ?? 0
                btn4.setTitle(array4[0]["name"].stringValue, for: .normal)
            }else{
                lc4T.constant = 0
                btn4.isHidden = true
                iv4.isHidden = true
                lc4H.constant = 0
            }
        }else{
            fo_handle = Int(array4[row]["id"].stringValue) ?? 0
            btn4.setTitle(array4[row]["name"].stringValue, for: .normal)
        }
    }
    
    func removeRadioView() {
        radioView?.removeFromSuperview()
        radioView = nil
    }

}
