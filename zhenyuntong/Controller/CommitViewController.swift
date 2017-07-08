//
//  CommitViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/4/16.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class CommitViewController: UIViewController {

    @IBOutlet weak var phtvContent: PlaceholderTextView!
    var c_id = ""
    var delegate : CommitViewControllerDelegate?
    
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

    @IBAction func commit(_ sender: Any) {
        phtvContent.resignFirstResponder()
        let remark = phtvContent.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if remark.characters.count == 0 {
            Toast(text: "请输入点评内容").show()
            return
        }
        let hud = showHUD(text: "点评中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appSaveComm, params: ["c_id" : c_id , "content" : remark]) {[weak self] (json, error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.delegate?.saveCommitSuccess()
                    self?.dismiss(animated: true, completion: {
                        
                    })
                    Toast(text: "点评成功").show()
                }else if let result = object["result"].string , result == "1000" {
                    self?.delegate?.saveCommitSuccess()
                    self?.dismiss(animated: true, completion: {
                        
                    })
                    Toast(text: "点评成功").show()
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

protocol CommitViewControllerDelegate {
    func saveCommitSuccess()
}
