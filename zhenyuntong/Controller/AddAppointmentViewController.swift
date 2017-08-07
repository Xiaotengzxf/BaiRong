//
//  AddAppointmentViewController.swift
//  BaiRong
//
//  Created by ANKER on 2017/8/1.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class AddAppointmentViewController: UIViewController, PTXDatePickerViewDelegate, UITextViewDelegate {

    @IBOutlet weak var tvRemark: UITextView!
    @IBOutlet weak var btnTime: UIButton!
    var selectedDate : Date?
    var datePicker : PTXDatePickerView?
    var json : JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnTime.layer.borderColor = UIColor.lightGray.cgColor
        btnTime.layer.borderWidth = 0.5
        btnTime.setTitle("请选择", for: .normal)
        tvRemark.layer.borderWidth = 0.5
        tvRemark.layer.borderColor = UIColor.lightGray.cgColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectTime(_ sender: Any) {
        tvRemark.resignFirstResponder()
        if datePicker == nil {
            datePicker = PTXDatePickerView(frame: CGRect(x: 0, y: SCREENHEIGHT, width: SCREENWIDTH, height: 246))
            datePicker?.delegate = self
            datePicker?.datePickerViewDateRangeModel = .custom
            datePicker?.maxYear = 2050
            self.view.addSubview(datePicker!)
        }
        datePicker?.show(with: selectedDate, animation: true)
    }

    @IBAction func save(_ sender: Any) {
        tvRemark.resignFirstResponder()
        datePicker?.hide(withAnimation: true)
        if selectedDate == nil {
            Toast(text: "请选择时间").show()
            return
        }
        let remark = tvRemark.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if remark.characters.count == 0 {
            Toast(text: "请输入备注").show()
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let hud = showHUD(text: "查询中...")
        let params : [String : Any] = ["mobile": json["phmobile"].stringValue, "revisiday": formatter.string(from: selectedDate!), "remark": remark]
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appMyAppoint, params: params){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let info = object["info"].string {
                    Toast(text: info).show()
                }
                if let status = object["status"].int, status == 1 {
                    self?.navigationController?.popViewController(animated: true)
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        datePicker?.hide(withAnimation: true)
    }
    
    // MARK: -PTXDatePickerViewDelegate
    func datePickerView(_ datePickerView: PTXDatePickerView!, didSelect date: Date!) {
        selectedDate = date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        btnTime.setTitle(formatter.string(from: selectedDate!), for: .normal)
    }
    
    

}
