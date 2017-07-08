//
//  ModifyNickViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/9.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class ModifyNickViewController: UIViewController {
    @IBOutlet weak var nickTextField: UITextField!
    @IBOutlet weak var lblTip: UILabel!
    var row = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        let userinfo = UserDefaults.standard.object(forKey: "mine") as? [String : Any]
        if row == 2 {
            nickTextField.text = userinfo?["nickname"] as? String
        }else if row == 3 {
            title = "修改手机号"
            lblTip.isHidden = true
            nickTextField.text = userinfo?["mobile"] as? String
            nickTextField.keyboardType = .numberPad
        }else if row == 7 {
            title = "修改签名"
            lblTip.text = "好签名可以让你的朋友容易记住你。"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveNick(_ sender: Any) {
        nickTextField.resignFirstResponder()
        if let nick = nickTextField.text , nick.characters.count > 0 {
            let nickname = nick.trimmingCharacters(in: .whitespacesAndNewlines)
            if nickname.characters.count > 0 {
                if row == 3 && !Invalidate.isPhoneNumber(phoneNumber: nickname) {
                    Toast(text: "手机号输入有误").show()
                    return
                }
                var params : [String : Any] = [:]
                if row == 2 {
                    params = ["act" : "nickname" , "mnickname" : nickname]
                }else if row == 3 {
                    params = ["act" : "mobile" , "mobile" : nickname]
                }else if row == 7 {
                    params = ["act" : "sign" , "msign" : nickname]
                }
                let hud = self.showHUD(text: "加载中...")
                NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appModifySelf, params: params){
                    [weak self] (json , error) in
                    hud.hide(animated: true)
                    if let object = json {
                        if let result = object["result"].int , result == 1000 {
                            if let info = UserDefaults.standard.object(forKey: "mine") {
                                var json = JSON(info)
                                if self!.row == 2 {
                                    json["nickname"].string = nickname
                                }else if self!.row == 3 {
                                    json["mobile"].string = nickname
                                }else if self!.row == 7 {
                                    json["sign"].string = nickname
                                }
                                
                                UserDefaults.standard.set(json.object, forKey: "mine")
                                UserDefaults.standard.synchronize()
                            }
                            _ = self?.navigationController?.popViewController(animated: true)
                        }else{
                            if let message = object["msg"].string , message.characters.count > 0 {
                                Toast(text: message).show()
                            }
                        }
                    }else{
                        Toast(text: "网络异常，请检查网络").show()
                    }
                }
            }else{
                if row == 2 {
                    Toast(text: "昵称输入有误").show()
                }else if row == 3 {
                    Toast(text: "手机号输入有误").show()
                }else if row == 7 {
                    Toast(text: "签名输入有误").show()
                }
            }
        }else{
            if row == 2 {
                Toast(text: "请输入昵称").show()
            }else if row == 3 {
                Toast(text: "请输入手机号").show()
            }else if row == 7 {
                Toast(text: "请输入签名").show()
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
