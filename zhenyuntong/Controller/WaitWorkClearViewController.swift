//
//  WaitWorkClearViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/4/2.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class WaitWorkClearViewController: UIViewController {

    @IBOutlet weak var tvReason: PlaceholderTextView!
    var wfId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }

    @IBAction func ok(_ sender: Any) {
        tvReason.resignFirstResponder()
        let remark = tvReason.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if remark.characters.count == 0 {
            Toast(text: "请输入销毁原因").show()
            return
        }
        let hud = showHUD(text: "保存中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWFClose, params: ["wf_id" : "\(wfId)" , "remark" : remark]) {[weak self] (json, error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    Toast(text: "销毁成功").show()
                    self?.dismiss(animated: true, completion: {
                        
                    })
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
