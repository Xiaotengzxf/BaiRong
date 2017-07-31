//
//  NewTaskSearchViewController.swift
//  BaiRong
//
//  Created by 张晓飞 on 2017/7/29.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit

class NewTaskSearchViewController: UIViewController {

    @IBOutlet weak var btnAll: UIButton!
    @IBOutlet weak var btnUnCall: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var tfPhone: UITextField!
    var nCall = 0
    var delegate : NewTaskSearchTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        self.view.addGestureRecognizer(tap)
        
        btnAll.setTitleColor(UIColor.white, for: .selected)
        btnAll.setTitleColor(UIColor.black, for: .normal)
        btnAll.setBackgroundImage(UIImage(color: UIColor.colorWithHexString(hex: "3B93EC")), for: .selected)
        btnAll.setBackgroundImage(UIImage(color: UIColor.white), for: .normal)
        
        btnUnCall.setTitleColor(UIColor.white, for: .selected)
        btnUnCall.setTitleColor(UIColor.black, for: .normal)
        btnUnCall.setBackgroundImage(UIImage(color: UIColor.colorWithHexString(hex: "3B93EC")), for: .selected)
        btnUnCall.setBackgroundImage(UIImage(color: UIColor.white), for: .normal)
        
        btnCall.setTitleColor(UIColor.white, for: .selected)
        btnCall.setTitleColor(UIColor.black, for: .normal)
        btnCall.setBackgroundImage(UIImage(color: UIColor.colorWithHexString(hex: "3B93EC")), for: .selected)
        btnCall.setBackgroundImage(UIImage(color: UIColor.white), for: .normal)
        
        btnAll.layer.borderWidth = 0.5
        btnUnCall.layer.borderWidth = 0.5
        btnCall.layer.borderWidth = 0.5
        
        btnAll.clipsToBounds = true
        btnUnCall.clipsToBounds = true
        btnCall.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if nCall == 0 {
            btnAll.isSelected = true
            btnUnCall.isSelected = false
            btnCall.isSelected = false
            
            btnAll.layer.borderColor = UIColor.colorWithHexString(hex: "3B93EC").cgColor
            btnUnCall.layer.borderColor = UIColor.lightGray.cgColor
            btnCall.layer.borderColor = UIColor.lightGray.cgColor
        }else if nCall == 1 {
            btnAll.isSelected = false
            btnUnCall.isSelected = true
            btnCall.isSelected = false
            
            btnAll.layer.borderColor = UIColor.lightGray.cgColor
            btnUnCall.layer.borderColor = UIColor.colorWithHexString(hex: "3B93EC").cgColor
            btnCall.layer.borderColor = UIColor.lightGray.cgColor
        }else{
            btnAll.isSelected = false
            btnUnCall.isSelected = false
            btnCall.isSelected = true
            
            btnAll.layer.borderColor = UIColor.lightGray.cgColor
            btnUnCall.layer.borderColor = UIColor.lightGray.cgColor
            btnCall.layer.borderColor = UIColor.colorWithHexString(hex: "3B93EC").cgColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doSearch(_ sender: Any) {
        tfPhone.resignFirstResponder()
        delegate?.getSearchCondition(mobile: tfPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines), status: nCall)
        self.dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func selectCall(_ sender: Any) {
        tfPhone.resignFirstResponder()
        let btn = sender as! UIButton
        if btn == btnAll {
            if btnAll.isSelected {
                return
            }else{
                nCall = 0
                btnAll.isSelected = true
                btnUnCall.isSelected = false
                btnCall.isSelected = false
                
                btnAll.layer.borderColor = UIColor.colorWithHexString(hex: "3B93EC").cgColor
                btnUnCall.layer.borderColor = UIColor.lightGray.cgColor
                btnCall.layer.borderColor = UIColor.lightGray.cgColor
            }
        }else if btn == btnUnCall {
            if btnUnCall.isSelected {
                return
            }else{
                nCall = 1
                btnAll.isSelected = false
                btnUnCall.isSelected = true
                btnCall.isSelected = false
                
                btnAll.layer.borderColor = UIColor.lightGray.cgColor
                btnUnCall.layer.borderColor = UIColor.colorWithHexString(hex: "3B93EC").cgColor
                btnCall.layer.borderColor = UIColor.lightGray.cgColor
            }
        }else{
            if btnCall.isSelected {
                return
            }else{
                nCall = 2
                btnAll.isSelected = false
                btnUnCall.isSelected = false
                btnCall.isSelected = true
                
                btnAll.layer.borderColor = UIColor.lightGray.cgColor
                btnUnCall.layer.borderColor = UIColor.lightGray.cgColor
                btnCall.layer.borderColor = UIColor.colorWithHexString(hex: "3B93EC").cgColor
            }
        }
    }
    
    func handleTap(sender : UITapGestureRecognizer) {
        tfPhone.resignFirstResponder()
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

}

protocol NewTaskSearchTableViewControllerDelegate {
    func getSearchCondition(mobile: String?, status : Int)
}
