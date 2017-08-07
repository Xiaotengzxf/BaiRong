//
//  SettingNewPwdViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/29.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class PortrayalViewController: UIViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfIdentify: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func queryPortrayal(_ sender: Any) {
        tfName.resignFirstResponder()
        tfPhone.resignFirstResponder()
        tfIdentify.resignFirstResponder()
        tfEmail.resignFirstResponder()
        let phone = tfPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let name = tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let idCard = tfIdentify.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var count = 0
        if name.characters.count == 0 {
            count += 1
        }else{
            
        }
        if phone.characters.count == 0 {
            count += 1
        }else{
            if !Invalidate.isPhoneNumber(phoneNumber: phone) {
                Toast(text: "手机号码输入有误").show()
                return
            }
        }
        if idCard.characters.count == 0 {
            count += 1
        }else{
            if !Invalidate.validateIDCard(idCard: idCard) {
                Toast(text: "身份证号输入有误").show()
                return
            }
        }
        if email.characters.count == 0 {
            count += 1
        }else {
            if !Invalidate.isValidateEmail(email: email) {
                Toast(text: "邮箱输入有误").show()
                return
            }
        }
        if count > 2 {
            Toast(text: "至少填写二项才可进行画像查询").show()
            return
        }
        let hud = showHUD(text: "查询中...")
        var params : [String : Any] = [:]
        if name.characters.count > 0 {
            params["name"] = name
        }
        if phone.characters.count > 0 {
            params["mobile"] = phone
        }
        if idCard.characters.count > 0 {
            params["codeid"] = idCard
        }
        if email.characters.count > 0 {
            params["mail"] = email
        }
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appFigure, params: params){
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


