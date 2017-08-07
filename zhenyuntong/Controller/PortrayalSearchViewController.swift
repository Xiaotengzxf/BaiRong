//
//  PortrayalSearchViewController.swift
//  BaiRong
//
//  Created by 张晓飞 on 2017/7/31.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON

class PortrayalSearchViewController: UIViewController, UITextFieldDelegate, RadioViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfIDCard: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfBland: UITextField!
    @IBOutlet weak var btnProjectType: UIButton!
    var arrProject : [JSON]!
    var radioView : RadioView?
    var projectType : String?
    var delegate : PortrayalSearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resignResponder() {
        tfName.resignFirstResponder()
        tfMobile.resignFirstResponder()
        tfIDCard.resignFirstResponder()
        tfEmail.resignFirstResponder()
        tfBland.resignFirstResponder()
    }
    
    @IBAction func selectProjectType(_ sender: Any) {
        resignResponder()
        if radioView == nil {
            if arrProject.count == 0 {
                return
            }
            radioView = RadioView(frame: .zero)
            radioView?.delegate = self
            radioView?.tableData = arrProject.map{$0["typename"].stringValue}
            radioView?.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(radioView!)
            radioView?.bTouch = true
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[radioView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["radioView" : radioView!]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[radioView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["radioView" : radioView!]))
            
            radioView?.addSubTableView()
            
        }
    }
    
    @IBAction func doSearch(_ sender: Any) {
        resignResponder()
        
        delegate?.callback(name: tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines), mobile: tfMobile.text?.trimmingCharacters(in: .whitespacesAndNewlines), idCard: tfIDCard.text?.trimmingCharacters(in: .whitespacesAndNewlines), email: tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines), batch: tfBland.text?.trimmingCharacters(in: .whitespacesAndNewlines), projectType: projectType)
        self.dismiss(animated: true) {
            
        }
    }
    
    func handleTap(sender : UITapGestureRecognizer) {
        if radioView != nil {
            return
        }
        resignResponder()
        self.dismiss(animated: true) {
            
        }
    }
    
    // mark: - RadioViewDelegate
    
    func getSelected(title: String, row: Int, type : Int) {
        removeRadioView()
        btnProjectType.setTitle(title, for: .normal)
        projectType = arrProject[row]["id"].string
    }
    
    func removeRadioView() {
        if radioView != nil {
            radioView?.removeFromSuperview()
            radioView = nil
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if NSStringFromClass(touch.view!.classForCoder) == "UITableViewCellContentView" {
            return false
        }
        return true
    }
    
    
}

protocol PortrayalSearchViewControllerDelegate {
    func callback(name: String?, mobile: String?, idCard: String?,email:String?,batch: String?,projectType: String?)
}
