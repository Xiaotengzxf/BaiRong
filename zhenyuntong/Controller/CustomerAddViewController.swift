//
//  CustomerAddViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/18.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class CustomerAddViewController: UIViewController {

    @IBOutlet weak var tfCustomerName: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfConnName: UITextField!
    @IBOutlet weak var tvAddress: PlaceholderTextView!
    @IBOutlet weak var tvRemark: PlaceholderTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: Any) {
        tfPhone.resignFirstResponder()
        tfCustomerName.resignFirstResponder()
        tfConnName.resignFirstResponder()
        tvAddress.resignFirstResponder()
        tvRemark.resignFirstResponder()
        let phone = tfPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let connName = tfConnName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let name = tfCustomerName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = tvAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let remark = tvRemark.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if name == nil || name?.characters.count == 0 {
            Toast(text: "请输入客户名称").show()
            return
        }else if phone == nil || phone?.characters.count == 0 {
            Toast(text: "请输入客户联系电话").show()
            return
        }else if (!Invalidate.isPhoneNumber(phoneNumber: phone!)) {
            Toast(text: "客户联系电话输入有误").show()
            return
        }
        let hud = self.showHUD(text: "加载中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appAddCust, params: ["customer" : name! , "mobile" : phone! , "address" : address , "remark" : remark , "connName" : connName]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    _ = self?.navigationController?.popViewController(animated: true)
                }else if let result = object["result"].string , result == "1000" {
                    _ = self?.navigationController?.popViewController(animated: true)
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

}
