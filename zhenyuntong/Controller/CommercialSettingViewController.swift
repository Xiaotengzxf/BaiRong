//
//  CommercialSettingViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/7/5.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommercialSettingViewController: UIViewController, IQDropDownTextFieldDelegate, IQDropDownTextFieldDataSource {

    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var tfNum: UITextField!
    @IBOutlet weak var ddtfPrice: IQDropDownTextField!
    @IBOutlet weak var tfDiscount: UITextField!
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var tfRemark: UITextField!
    
    var row = 0
    var remark = ""
    var price : Double = 0
    var num = 0
    var discount : Double = 0
    var product : JSON!
    var priceCH : JSON!
    var delegate : CommercialSettingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblProductName.text = "商品名称：\(product["name"].string ?? "")"
        tfNum.text = "\(num)"
        tfDiscount.text = "\(discount)"
        tfAmount.text = "\(Double(num) * discount * price)"
        tfRemark.text = remark
        ddtfPrice.itemList = ["\(priceCH["price1"].stringValue)：\(product["price1"].stringValue)", "\(priceCH["price2"].stringValue)：\(product["price2"].stringValue)", "\(priceCH["price3"].stringValue)：\(product["price3"].stringValue)", "\(priceCH["price4"].stringValue)：\(product["price4"].stringValue)"]
        ddtfPrice.text = "\(price)"
        
        tfNum.addTarget(self, action: #selector(CommercialSettingViewController.textfieldDidChange(sender:)), for: .editingChanged)
        tfDiscount.addTarget(self, action: #selector(CommercialSettingViewController.textfieldDidChange(sender:)), for: .editingChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - private method
    @IBAction func doCannel(_ sender: Any) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func doSubmit(_ sender: Any) {
        delegate?.callbackWithParam(num: num, price: price, discount: discount, remark: remark, row : row)
        self.dismiss(animated: true) {
            
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
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?) {
        if let array = item?.components(separatedBy: "：") {
            if array.count > 1 {
                textField.text = array[1]
                price = Double(array[1]) ?? 0
                tfAmount.text = "\(Double(num) * discount * price)"
            }
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfNum {
            let strNum = tfNum.text ?? "0"
            let n = Int(strNum) ?? 0
            if n <= 0 {
                tfNum.text = "1"
                num = 1
                tfAmount.text = "\(Double(num) * discount * price)"
            }
        }else if textField == tfDiscount {
            let text = tfDiscount.text ?? "0"
            let dDiscount = Double(text) ?? 0
            if dDiscount > 1 || dDiscount <= 0 {
                tfDiscount.text = "1.0"
                discount = 1.0
                tfAmount.text = "\(Double(num) * discount * price)"
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func textfieldDidChange(sender : Any) {
        if let textfield = sender as? UITextField {
            if textfield == tfNum {
                let text = tfNum.text ?? "0"
                num = Int(text) ?? 0
                tfAmount.text = "\(Double(num) * discount * price)"
            }else{
                let text = tfDiscount.text ?? "0"
                discount = Double(text) ?? 0
                tfAmount.text = "\(Double(num) * discount * price)"
            }
        }
    }
}

protocol CommercialSettingViewControllerDelegate {
    func callbackWithParam(num : Int , price : Double , discount : Double , remark : String, row : Int)
}
