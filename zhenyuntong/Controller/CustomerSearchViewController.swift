//
//  CustomerSearchViewController.swift
//  BaiRong
//
//  Created by 张晓飞 on 2017/7/30.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class CustomerSearchViewController: UIViewController, RadioViewDelegate {
    
    var radioView : RadioView?
    var arrCall : [JSON] = []
    var arrHandle : [JSON] = []
    var nCall = -1
    var nHandle = -1
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnHandle: UIButton!
    var delegate : CustomerSearchViewControllerDelegate?

    @IBOutlet weak var tfPhone: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let hud = showHUD(text: "加载中...")
        //var mobile =
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appCallResultConfig, params: nil){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let total = object["total"].int, total > 0 {
                    if let arr = object["rows"].array {
                        for item in arr {
                            if item["type"].stringValue == "1" {
                                self?.arrCall.append(item)
                            }else{
                                self?.arrHandle.append(item)
                            }
                        }
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
    
    @IBAction func selectCallResult(_ sender: Any) {
        if radioView == nil {
            if arrCall.count == 0 {
                return
            }
            radioView = RadioView(frame: .zero)
            radioView?.delegate = self
            radioView?.tableData = arrCall.map{$0["name"].stringValue}
            radioView?.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(radioView!)
            radioView?.bTouch = true

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[radioView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["radioView" : radioView!]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[radioView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["radioView" : radioView!]))
            
            radioView?.addSubTableView()
            
        }
    }

    @IBAction func selectHandleResult(_ sender: Any) {
        if radioView == nil {
            if arrHandle.count == 0 {
                return
            }
            radioView = RadioView(frame: .zero)
            radioView?.delegate = self
            radioView?.type = 1
            radioView?.tableData = arrHandle.map{$0["name"].stringValue}
            radioView?.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(radioView!)
            radioView?.bTouch = true
           
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[radioView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["radioView" : radioView!]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[radioView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["radioView" : radioView!]))
            
            radioView?.addSubTableView()
        }
    }
    
    @IBAction func doSearch(_ sender: Any) {
        tfPhone.resignFirstResponder()
        delegate?.customerSearch(nCall: nCall, nHandle: nHandle, mobile: tfPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines))
        self.dismiss(animated: true) {
            
        }
    }
    
    func removeRadioView() {
        radioView?.removeFromSuperview()
        radioView = nil
    }
    
    func getSelected(title: String, row: Int, type : Int) {
        removeRadioView()
        if type == 0 {
            btnCall.setTitle(title, for: .normal)
            nCall = arrCall[row]["id"].intValue
        }else{
            btnHandle.setTitle(title, for: .normal)
            nHandle = arrHandle[row]["id"].intValue
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        if radioView != nil {
            return
        }
        for touch in touches {
            print(touch.location(in: self.view))
            if touch.location(in: self.view).y < 64 || touch.location(in: self.view).y > 257 + 64 {
                self.dismiss(animated: true) {
                    
                }
            }
        }
    }

}

protocol CustomerSearchViewControllerDelegate {
    func customerSearch(nCall : Int , nHandle : Int ,mobile : String?)
}
