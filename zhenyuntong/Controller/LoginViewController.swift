//
//  LoginViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/6.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class LoginViewController: UIViewController , UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var tfCode: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var btnCode: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let username = UserDefaults.standard.object(forKey: "username") as? String {
            userNameTextField.text = username
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func getCode(_ sender: Any) {
        
    }
    
    @IBAction func doLogin(_ sender: Any) {
        resign()
        let mobile = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = tfCode.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if mobile == nil || mobile?.characters.count == 0 {
            Toast(text: "请输入手机号码").show()
            return
        }else if mobile!.characters.count != 11 {
            Toast(text: "手机号码输入有误").show()
            return
        }else if code == nil || code?.characters.count == 0 {
            Toast(text: "请输入验证码").show()
            return
        }
        let hud = self.showHUD(text: "加载中...")
        UserDefaults.standard.set(mobile!, forKey: "username")
        UserDefaults.standard.synchronize()
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.login, params: nil){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    if var dict = object["data"].dictionaryObject {
                        for (key , value) in dict {
                            if value is NSNull {
                                dict[key] = ""
                            }
                        }
                        UserDefaults.standard.set(dict, forKey: "mine")
                        UserDefaults.standard.synchronize()
                    }
                    let tabbar = self?.storyboard?.instantiateViewController(withIdentifier: "tabbar")
                    self?.view.window?.rootViewController = tabbar
                    
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
    
    // 取消输入焦点
    func resign()  {
        userNameTextField.resignFirstResponder()
        tfCode.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let len = textField.text?.characters.count , len >= 11 {
            if range.length == 0 {
                return false
            }
        }
        return true
    }

}
