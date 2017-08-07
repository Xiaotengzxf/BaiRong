//
//  StatisticsSearchViewController.swift
//  BaiRong
//
//  Created by 张晓飞 on 2017/7/31.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import DatePickerDialog

class StatisticsSearchViewController: UIViewController {

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnEnd: UIButton!
    @IBOutlet weak var tfSub: UITextField!
    var stime : String?
    var etime : String?
    var exten : String?
    var delegate : StatisticsSearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if stime == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            btnStart.setTitle("\(formatter.string(from: Date()))", for: .normal)
        }
        if etime == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            btnEnd.setTitle("\(formatter.string(from: Date()))", for: .normal)
        }
        if exten != nil {
            tfSub.text = exten
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        for touch in touches {
            print(touch.location(in: self.view))
            if touch.location(in: self.view).y < 64 || touch.location(in: self.view).y > 257 + 64 {
                self.dismiss(animated: true) {
                    
                }
            }
        }
    }
    
    @IBAction func selectStartTime(_ sender: Any) {
        DatePickerDialog().show(title: "选择时间", doneButtonTitle: "确定", cancelButtonTitle: "取消", datePickerMode: .date) {[weak self]
            (date) -> Void in
            if let selectedDate = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self?.btnStart.setTitle("\(formatter.string(from: selectedDate))", for: .normal)
                self?.stime = formatter.string(from: selectedDate)
            }
            
        }
        
    }
    @IBAction func selectEndTime(_ sender: Any) {
        DatePickerDialog().show(title: "选择时间", doneButtonTitle: "确定", cancelButtonTitle: "取消", datePickerMode: .date) {[weak self]
            (date) -> Void in
            if let selectedDate = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self?.btnEnd.setTitle("\(formatter.string(from: selectedDate))", for: .normal)
                self?.etime = formatter.string(from: selectedDate)
            }
            
        }
    }

    @IBAction func doSearch(_ sender: Any) {
        tfSub.resignFirstResponder()
        exten = tfSub.text
        delegate?.callback(stime: stime, etime: etime, exten: exten)
        self.dismiss(animated: true) { 
            
        }
    }
}

protocol StatisticsSearchViewControllerDelegate {
    func callback(stime : String?, etime: String?, exten: String?)
}
