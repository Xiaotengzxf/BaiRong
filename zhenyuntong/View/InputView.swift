//
//  InputView.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/15.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON

class InputView: UIView , UITextFieldDelegate{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    var item : JSON?
    
    func addRadioButton(keyValues : [JSON]) {
        textField.isHidden = true
        let x : CGFloat = 16
        for i in 0..<keyValues.count {
            let keyValue = keyValues[i]
            let width = (SCREENWIDTH - 32) / 3
            let radioButton = UIButton(frame: CGRect(x: x + CGFloat(i % 3) * width, y:  CGFloat(i / 3 * 44 + 40), width: width, height: CGFloat(44)))
            radioButton.addTarget(self, action: #selector(InputView.onRadioButtonValueChanged(sender:)), for: .touchUpInside)
            radioButton.setTitle(keyValue["name"].stringValue, for: .normal)
            radioButton.setTitleColor(UIColor.darkGray, for: .normal)
            radioButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            radioButton.setImage(UIImage(named: "checkbox"), for: .normal)
            radioButton.setImage(UIImage(named: "checkbox1"), for: .selected)
            radioButton.contentHorizontalAlignment = .center
            radioButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0)
            radioButton.contentHorizontalAlignment = .left
            self.addSubview(radioButton)
            radioButton.tag = i
        }
    }
    
    func onRadioButtonValueChanged(sender : UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
        NotificationCenter.default.post(name: Notification.Name("ordernew"), object: 3, userInfo: ["fname" : item?["fname"].string ?? "", "value" : sender.titleLabel!.text! , "select" : (sender.isSelected ? "1" :"0")])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text , text.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
            NotificationCenter.default.post(name: Notification.Name("ordernew"), object: 2, userInfo: ["fname" : item?["fname"].string ?? "" , "value" : value])
        }
    }
}
