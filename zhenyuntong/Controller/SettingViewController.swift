//
//  SettingViewController.swift
//  BaiRong
//
//  Created by 张晓飞 on 2017/7/27.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster

class SettingViewController: UIViewController {

    @IBOutlet weak var mSwitch: UISwitch!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mine = UserDefaults.standard.object(forKey: "mine") as? [String : Any] {
            lblMobile.text = mine["phone"] as? String ?? ""
        }
        lblVersion.text = "当前版本号：\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setWorkModel(_ sender: Any) {
        let hud = showHUD(text: "加载中...")
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appSetOutIn, params: nil ){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let status = object["status"].int, status > 0 {
                    self?.mSwitch.isOn = true
                }else{
                    self?.mSwitch.isOn = false
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
            }
        }
    }

    @IBAction func exit(_ sender: Any) {
        
    }
    
    func loadData() {
        let hud = showHUD(text: "加载中...")
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appGetOut, params: nil ){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let status = object["status"].int, status > 0 {
                    self?.mSwitch.isOn = true
                }else{
                    self?.mSwitch.isOn = false
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
