//
//  OrderHandleViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/4/1.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import ALCameraViewController
import Toaster
import Photos

class OrderHandleViewController: UIViewController , IQDropDownTextFieldDelegate {

    @IBOutlet weak var tvSuggestion: PlaceholderTextView!
    @IBOutlet weak var vAccessory: UIView!
    @IBOutlet weak var idtfNext: IQDropDownTextField!
    @IBOutlet weak var idtfUser: IQDropDownTextField!
    @IBOutlet weak var lblAccessory: UILabel!
    var arrayStep : [JSON]!
    var arrayUser : [JSON]!
    var wfId = 0
    var hand_result = ""
    var to_user = ""
    var image : UIImage?
    @IBOutlet weak var ivAccessory: UIImageView!
    @IBOutlet weak var lcHeight: NSLayoutConstraint!
    var bFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vAccessory.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1).cgColor
        vAccessory.layer.borderWidth = 0.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(WaitWorkNewViewController.tap(recognizer:)))
        vAccessory.addGestureRecognizer(tap)
        
        idtfNext.dropDownMode = .textPicker
        idtfNext.itemList = arrayStep.map{$0["process_name"].stringValue}
        idtfNext.optionalItemText = "请选择下一步"
        idtfUser.isUserInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func save(_ sender: Any) {
        idtfNext.resignFirstResponder()
        idtfUser.resignFirstResponder()
        tvSuggestion.resignFirstResponder()
        if hand_result.characters.count == 0 {
            Toast(text: "请选择下一步").show()
            return
        }
        if to_user.characters.count == 0 && !bFinished{
            Toast(text: "请选择指派人").show()
            return
        }
        let opinion = tvSuggestion.text
        let filepath = lblAccessory.text != "请选择" ? lblAccessory.text! : ""
        let hud = showHUD(text: "保存中...")
        var params = ["wf_id" : "\(wfId)" , "opinion" : opinion ?? "" , "hand_result" : hand_result , "filepath" : filepath]
        if !bFinished {
            params["hand_wf_to"] = to_user
        }
        NetworkManager.installshared.upload(url: NetworkManager.installshared.appWFSaveHandle, params: params, data: (image != nil ? UIImageJPEGRepresentation(image!, 0.2) : nil)) {[weak self] (json, error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    Toast(text: "保存成功").show()
                    self?.dismiss(animated: true, completion: { 
                        NotificationCenter.default.post(name: Notification.Name("waitworkdetail"), object: 2)
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
    
    // 添加附件
    func tap(recognizer : UITapGestureRecognizer) {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            // Do something with your image here.
            // If cropping is enabled this image will be the cropped version
            self?.dismiss(animated: true, completion: nil)
            self?.image = image
            if image != nil {
                self?.ivAccessory.image = image
                let height = (image!.size.width > SCREENWIDTH - 72) ? (image!.size.height * ((SCREENWIDTH - 72) / image!.size.width)) : (image!.size.height * (image!.size.width / (SCREENWIDTH - 72)))
                self?.lcHeight.constant = height
                
                let manager = PHImageManager.default()
                manager.requestImageData(for: asset!, options: nil, resultHandler: {[weak self] (data, path, orientation, other) in
                    self?.lblAccessory.text = path
                })
                
            }
        }
        self.present(cameraViewController, animated: true, completion: nil)
    }
    
    func loadUser() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWFDesig, params: ["wf_id" : wfId , "hand_result" : hand_result]){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    if let array = object["data"].array {
                        self?.idtfUser.isUserInteractionEnabled = true
                        self?.arrayUser = array
                        self?.idtfUser.itemList = self!.arrayUser.map{$0["process_name"].stringValue}
                    }
                }
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
    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?) {
        if textField == idtfNext {
            for json in arrayStep {
                if json["process_name"].stringValue == item {
                    hand_result = json["id"].stringValue
                    if item == "完成" {
                        bFinished = true
                    }else{
                        loadUser()
                    }
                }
            }
        } else {
            for json in arrayUser {
                if json["process_name"].stringValue == item {
                    to_user = json["to_user"].stringValue
                }
            }
        }
    }
    

}
