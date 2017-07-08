//
//  WaitWorkNewViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/25.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster
import IQKeyboardManagerSwift
import ALCameraViewController
import Photos

class WaitWorkNewViewController: UIViewController, IQDropDownTextFieldDelegate , IQDropDownTextFieldDataSource {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var idtfType: IQDropDownTextField!
    @IBOutlet weak var tvContent: PlaceholderTextView!
    @IBOutlet weak var idtfStep: IQDropDownTextField!
    @IBOutlet weak var idtfTo: IQDropDownTextField!
    @IBOutlet weak var tvRemark: PlaceholderTextView!
    @IBOutlet weak var vAccessory: UIView!
    @IBOutlet weak var lblAccessory: UILabel!
    @IBOutlet weak var ivAccessory: UIImageView!
    @IBOutlet weak var lcHeight: NSLayoutConstraint!
    var dataType : [JSON] = []
    var dataStep : [JSON] = []
    var dataTo : [JSON] = []
    var dataAccess : [JSON] = []
    var wf_type = 0
    var wf_step = 0
    var wf_to = 0
    var image : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idtfType.rightView = rightView(name: "icon_arrow_right", size: CGSize(width: 20, height: 20))
        idtfType.rightViewMode = .always
        idtfStep.rightView = rightView(name: "icon_arrow_right", size: CGSize(width: 20, height: 20))
        idtfStep.rightViewMode = .always
        idtfTo.rightView = rightView(name: "icon_arrow_right", size: CGSize(width: 20, height: 20))
        idtfTo.rightViewMode = .always
        vAccessory.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1).cgColor
        vAccessory.layer.borderWidth = 0.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(WaitWorkNewViewController.tap(recognizer:)))
        vAccessory.addGestureRecognizer(tap)
        idtfType.isUserInteractionEnabled = false
        idtfStep.isUserInteractionEnabled = false
        idtfTo.isUserInteractionEnabled = false
        loadData(tid: 0, flag: 0)
    }
    
    func tap(recognizer : UITapGestureRecognizer) {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            self?.dismiss(animated: true, completion: nil)
            self?.image = image
            if image != nil {
                self?.ivAccessory.image = image
                let height = (image!.size.width > SCREENWIDTH - 32) ? (image!.size.height * ((SCREENWIDTH - 32) / image!.size.width)) : (image!.size.height * (image!.size.width / (SCREENWIDTH - 32)))
                self?.lcHeight.constant = height
                
                let manager = PHImageManager.default()
                manager.requestImageData(for: asset!, options: nil, resultHandler: {[weak self] (data, path, orientation, other) in
                    self?.lblAccessory.text = path
                })
            }
        }
        self.present(cameraViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func save(_ sender: Any) {
        self.view.endEditing(true)
        guard let name = tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines) , name.characters.count > 0 else {
            Toast(text: "请输入工作流名称").show()
            return
        }
        if wf_type == 0 {
            Toast(text: "请选择类型").show()
            return
        }
        guard let content = tvContent.text?.trimmingCharacters(in: .whitespacesAndNewlines) , name.characters.count > 0 else {
            Toast(text: "请输入内容").show()
            return
        }
        if wf_step == 0 {
            Toast(text: "请选择步骤").show()
            return
        }
        if wf_to == 0 {
            Toast(text: "请选择指派人").show()
            return
        }
        let filepath = lblAccessory.text != "请选择" ? lblAccessory.text! : ""
        let remark = tvRemark.text ?? ""
        let hud = showHUD(text: "保存中...")
        NetworkManager.installshared.upload(url: NetworkManager.installshared.appWFAdd, params: ["wf_name" : name , "wf_type" : "\(wf_type)" , "wf_content" : content , "wf_step" : "\(wf_step)" , "wf_to" : "\(wf_to)" , "filepath" : filepath , "wf_remark" : remark], data: self.image != nil ? UIImageJPEGRepresentation(image!, 0.2) : nil) {[weak self] (json, error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
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
    
    func loadData(tid : Int , flag : Int) {
        var url = ""
        var params : [String : Int] = [:]
        if flag == 0 {
            url = NetworkManager.installshared.appWFT
        }else if flag == 1 {
            url = NetworkManager.installshared.appWFTDetail
            params["type_id"] = tid
        }else if flag == 2 {
            url = NetworkManager.installshared.appWFSelectTo
            params["setp_id"] = tid
        }
        NetworkManager.installshared.request(type: .post, url: url, params: params){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int {
                    if result == 1000 {
                        if let array = object["data"].array , array.count > 0{
                            if flag == 0 {
                                self?.dataType.removeAll()
                                self?.dataType += array
                                if self?.dataType.count ?? 0 > 0 {
                                    self?.idtfType.itemList = self!.dataType.map{$0["t_name"].stringValue}
                                    self?.idtfType.isUserInteractionEnabled = true
                                }
                                
                            }else if flag == 1 {
                                self?.dataStep.removeAll()
                                self?.dataStep += array
                                if self?.dataStep.count ?? 0 > 0 {
                                    self?.idtfStep.itemList = self!.dataStep.map{$0["process_name"].stringValue}
                                    self?.idtfStep.isUserInteractionEnabled = true
                                }
                            }else if flag == 2 {
                                self?.dataTo.removeAll()
                                self?.dataTo += array
                                if self?.dataTo.count ?? 0 > 0 {
                                    self?.idtfTo.itemList = self!.dataTo.map{$0["name"].stringValue}
                                    self?.idtfTo.isUserInteractionEnabled = true
                                }
                            }
                        }
                    }else if result == 1004 {
                        if flag == 0 {
                            Toast(text: "工作流类型为空").show()
                        }else if flag == 1 {
                            Toast(text: "工作流步骤为空").show()
                        }else if flag == 2 {
                            Toast(text: "工作流指派为空").show()
                        }
                    }else{
                        if let msg = object["msg"].string {
                            Toast(text: msg).show()
                        }
                    }
                }
            }else{
                Toast(text: "网络故障，请检查网络").show()
            }
        }
    }

    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?) {
        if textField == idtfType {
            let index = dataType.map{$0["t_name"].stringValue}.index(of: item!) ?? 0
            wf_type = dataType[index]["id"].intValue
            if wf_type > 0 {
                loadData(tid: wf_type, flag: 1)
            }
        }else if textField == idtfStep {
            let index = dataStep.map{$0["process_name"].stringValue}.index(of: item!) ?? 0
            wf_step = dataStep[index]["id"].intValue
            if wf_type > 0 {
                loadData(tid: wf_step, flag: 2)
            }
        }else if textField == idtfTo {
            let index = dataTo.map{$0["name"].stringValue}.index(of: item!) ?? 0
            wf_to = dataTo[index]["id"].intValue
        }else{
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == idtfType {
            
        }else if textField == idtfStep {
            
        }else if textField == idtfTo {
            
        }else{
            
        }
    }

}
