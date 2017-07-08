//
//  CommercialSearchViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/7/7.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class CommercialSearchViewController: UIViewController, IQDropDownTextFieldDataSource, IQDropDownTextFieldDelegate {

    @IBOutlet weak var tfAppName: UITextField!
    @IBOutlet weak var ddtfState: IQDropDownTextField!
    @IBOutlet weak var ddtfType: IQDropDownTextField!
    @IBOutlet weak var btnMe: UIButton!
    var other : [JSON] = []
    var items = ["全部", "跟进中", "确认中", "已完成", "已销毁"]
    var stateId = 0
    var type = ""
    var includeMy = "n"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ddtfType.isUserInteractionEnabled = false
        ddtfState.itemList = ["全部", "跟进中", "确认中", "已完成", "已销毁"]
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectIsOwn(_ sender: Any) {
        btnMe.isSelected = !btnMe.isSelected
    }

    @IBAction func search(_ sender: Any) {
        guard let name = tfAppName.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            Toast(text: "请输入商机名称或备注").show()
            return
        }
        if stateId == 0 || type == "" {
            Toast(text: "请至少选择一个查询条件").show()
            return
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "commerciallist") as? ZXFCommercialListTableViewController {
            controller.search = name
            controller.state = stateId
            controller.bSearch = true
            controller.type = type
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // 加载数据
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appOppoTP, params: nil){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    if let array = object["data"].array {
                        self?.other += array
                        self?.ddtfType.itemList = self!.other.map{$0["o_name"].stringValue}
                        self?.ddtfType.isUserInteractionEnabled = true
                    }
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
    
    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?) {
        if textField == ddtfType {
            let index = other.map{$0["o_name"].stringValue}.index(of: item!) ?? 0
            type = "\(other[index]["id"].intValue)"
        }else{
            stateId = items.index(of: item!) ?? 0
        }
    }

}
