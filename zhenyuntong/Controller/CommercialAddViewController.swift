//
//  CommercialAddViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/7/4.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster
import TabPageViewController
import ALCameraViewController
import Photos

class CommercialAddViewController: UIViewController, ProductListTableViewControllerDelegate, ProductViewDelegate, IQDropDownTextFieldDataSource, IQDropDownTextFieldDelegate , CommercialSettingViewControllerDelegate {

    @IBOutlet var btnRadio: [radioButton]!
    @IBOutlet weak var ddtfType: IQDropDownTextField!
    @IBOutlet weak var tfFrom: UITextField! // 商机名称
    @IBOutlet weak var tvRemark: PlaceholderTextView!
    @IBOutlet weak var vOther: UIView!
    @IBOutlet weak var lcHeight: NSLayoutConstraint!
    @IBOutlet weak var btnAddProduct: UIButton!
    @IBOutlet weak var svMain: UIScrollView!
    @IBOutlet weak var lcBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var idtfStep: IQDropDownTextField!
    @IBOutlet weak var idtfTo: IQDropDownTextField!
    @IBOutlet weak var vAccessory: UIView!
    @IBOutlet weak var lblAccessory: UILabel!
    @IBOutlet weak var ivAccessory: UIImageView!
    @IBOutlet weak var lcImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lcAddProductBottom: NSLayoutConstraint!
    var lcBottom : NSLayoutConstraint?
    @IBOutlet weak var vPic: UIView!
    @IBOutlet weak var vContent: UIView!
    var oid = 0
    var tType = ""
    var height : CGFloat = 0
    var other : [JSON] = [] // 商机类型数组
    var content : [String : String] = [:]
    var y : CGFloat = 0
    var arrSelectedProducts : [JSON] = []
    var arrSelectedProductView : [ProductView] = []
    var arrAppOppoActbus : [JSON] = []
    var arrTo : [JSON] = []
    var cust_id = "" // 客户id
    var priceCH : JSON!
    var image : UIImage?
    var wf_step = 0
    var wf_to = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ddtfType.rightView = rightView(name: "icon_arrow_right", size: CGSize(width: 20, height: 20))
        ddtfType.rightViewMode = .always
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(CommercialAddViewController.handleNotification(notification:)), name: Notification.Name("commercialadd"), object: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(CommercialAddViewController.saveCommercial))
        
        vAccessory.isHidden = true
        lcAddProductBottom.constant = -273
        
        idtfStep.rightView = rightView(name: "icon_arrow_right", size: CGSize(width: 20, height: 20))
        idtfStep.rightViewMode = .always
        idtfTo.rightView = rightView(name: "icon_arrow_right", size: CGSize(width: 20, height: 20))
        idtfTo.rightViewMode = .always
        vPic.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1).cgColor
        vPic.layer.borderWidth = 0.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(CommercialAddViewController.tap(recognizer:)))
        vPic.addGestureRecognizer(tap)
        idtfStep.isUserInteractionEnabled = false
        idtfTo.isUserInteractionEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 处理通知
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : Any] {
                    //let json = JSON(userInfo)
                }
            }else if tag == 2 {
                if let userInfo = notification.userInfo as? [String : String] {
                    content[userInfo["fname"]!] = userInfo["value"]!
                }
            }else if tag == 3 {
                if let userInfo = notification.userInfo as? [String : String] {
                    if userInfo["select"] == "0" {
                        let value = content[userInfo["fname"]!]!
                        let val = userInfo["value"]!
                        if value.hasPrefix(val) {
                            if value.contains(",") {
                                let v = value.replacingOccurrences(of: "\(val),", with: "")
                                content[userInfo["fname"]!] = v
                            }else{
                                content[userInfo["fname"]!] = ""
                            }
                        }else{
                            let v = value.replacingOccurrences(of: ",\(val)", with: "")
                            content[userInfo["fname"]!] = v
                        }
                    }else{
                        if content[userInfo["fname"]!] != nil {
                            let value = content[userInfo["fname"]!]!
                            content[userInfo["fname"]!] = "\(value),\(userInfo["value"]!)"
                        }else{
                            content[userInfo["fname"]!] = userInfo["value"]!
                        }
                        
                    }
                    
                }
            }
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
    
    @IBAction func selectIfAdd(_ sender: Any) {
        if oid == 0 {
            Toast(text: "请先选择商机类型").show()
            return
        }
        if let button = sender as? UIButton {
            for (index, btn) in btnRadio.enumerated() {
                if button == btn {
                    btn.isSelected = true
                    if index == 0 {
                        vAccessory.isHidden = true
                        lcAddProductBottom.constant = -(273+lcImageViewHeight.constant)
                    }else{
                        vAccessory.isHidden = false
                        lcAddProductBottom.constant = 10
                    }
                }else{
                    btn.isSelected = false
                }
            }
        }
        
    }
    
    @IBAction func addProduct(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "productlist") as? ProductListTableViewController {
            controller.title = "商品列表"
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // 保存
    func saveCommercial() {
        self.view.endEditing(true)
        if oid == 0 {
            Toast(text: "请选择商机类型").show()
            return
        }
        if !btnRadio.first!.isSelected {
            if wf_step == 0 {
                Toast(text: "请选择步骤").show()
                return
            }
            if wf_to == 0 {
                Toast(text: "请选择商机指派人").show()
                return
            }
        }
        guard let name = tfFrom.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            Toast(text: "请输入商机名称").show()
            return
        }
        let remark = tvRemark.text.trimmingCharacters(in: .whitespacesAndNewlines)
        var params : [String : String] = ["cust_id" : cust_id, "actbus" : (btnRadio.first!.isSelected ? "n" : "y"), "step" : (btnRadio.first!.isSelected ? "" :"\(wf_step)"), "name" : name, "remark" : remark, "r_to" : (btnRadio.first!.isSelected ? "" :"\(wf_to)") , "type" : "\(oid)"]
        var arrComm : [[String : Any]] = []
        for (index, product) in arrSelectedProducts.enumerated() {
            let productView = arrSelectedProductView[index]
            var comm : [String : Any] = [:]
            let price = productView.price
            comm["amount"] = productView.discount * price * Double(productView.number)
            comm["price"] = price
            comm["company"] = product["company"].string ?? ""
            comm["count"] = productView.number
            comm["discount"] = productView.discount
            comm["id"] = product["id"].string
            comm["model"] = product["model"].string
            comm["name"] = product["name"].string
            comm["number"] = product["number"].string
            arrComm.append(comm)
        }
        if arrComm.count > 0 {
            params["commList"] = JSON(arrComm).rawString() ?? ""
        }
        let hud = showHUD(text: "提交中...")
        NetworkManager.installshared.upload(url: NetworkManager.installshared.appAddOppo, params: params, data: self.image != nil ? UIImageJPEGRepresentation(image!, 0.2) : nil) {[weak self] (json, error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].string , result == "1000" {
                    Toast(text: "发起商机成功").show()
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
    
    func tap(recognizer : UITapGestureRecognizer) {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            self?.dismiss(animated: true, completion: nil)
            self?.image = image
            if image != nil {
                self?.ivAccessory.image = image
                let height = (image!.size.width > SCREENWIDTH - 32) ? (image!.size.height * ((SCREENWIDTH - 32) / image!.size.width)) : (image!.size.height * (image!.size.width / (SCREENWIDTH - 32)))
                self?.lcImageViewHeight.constant = height
                
                let manager = PHImageManager.default()
                manager.requestImageData(for: asset!, options: nil, resultHandler: {[weak self] (data, path, orientation, other) in
                    self?.lblAccessory.text = path
                })
            }
        }
        self.present(cameraViewController, animated: true, completion: nil)
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
            oid = other[index]["id"].intValue
            
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appOppoActbus, params: ["type" : oid]){
                [weak self] (json , error) in
                if let object = json {
                    if let result = object["result"].int , result == 1000 {
                        self?.arrAppOppoActbus += object["data"].arrayValue
                        self?.idtfStep.isUserInteractionEnabled = true
                        self?.idtfStep.itemList = self!.arrAppOppoActbus.map{$0["process_name"].stringValue}
                    }else{
                        if let message = object["msg"].string , message.characters.count > 0 {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    Toast(text: "网络异常，请稍后重试").show()
                }
            }
        }else if textField == idtfStep {
            let index = arrAppOppoActbus.map{$0["process_name"].stringValue}.index(of: item!) ?? 0
            wf_step = arrAppOppoActbus[index]["id"].intValue
            
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appOppoAllot, params: ["setpid" : wf_step]){
                [weak self] (json , error) in
                if let object = json {
                    if let result = object["result"].int {
                        if result == 1000 || result == 1004 {
                            self?.arrTo += object["data"].arrayValue
                            if self!.arrTo.count > 0 {
                                self?.idtfTo.isUserInteractionEnabled = true
                                self?.idtfTo.itemList = self!.arrTo.map{$0["name"].stringValue}
                            }
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
        }else{
            let index = arrTo.map{$0["name"].stringValue}.index(of: item!) ?? 0
            wf_to = arrTo[index]["id"].intValue
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    // MARK: - ProductListTableViewControllerDelegate
    func callbackWithSelectedProducts(products: [JSON], priceCH: JSON) {
        self.priceCH = priceCH
        if lcBtnBottom != nil {
            vContent.removeConstraint(lcBtnBottom)
            lcBtnBottom = nil
        }
        if lcBottom != nil {
            vContent.removeConstraint(lcBottom!)
            lcBottom = nil
        }
        for (index, product) in products.enumerated() {
            if let productView = Bundle.main.loadNibNamed("ProductView", owner: nil, options: nil)?.first as? ProductView {
                
                productView.translatesAutoresizingMaskIntoConstraints = false
                vContent.addSubview(productView)
                productView.delegate = self
                productView.product = product
                productView.assignValue()
                productView.tag = arrSelectedProductView.count
                arrSelectedProductView.append(productView)
                arrSelectedProducts.append(product)
                
                vContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[productView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["productView" : productView]))
                vContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[btnAddProduct]-(top)-[productView(130)]", options: .directionLeadingToTrailing, metrics: ["top" : y], views: ["btnAddProduct" : btnAddProduct,"productView" : productView]))
                
                y += 130
                
                if index == products.count - 1 {
                    lcBottom = NSLayoutConstraint(item: productView, attribute: .bottom, relatedBy: .equal, toItem: vContent, attribute: .bottom, multiplier: 1, constant: 0)
                    vContent.addConstraint(lcBottom!)
                }
            }
        }
        
    }

    // MARK: - ProductViewDelegate
    func deleteProduct(row : Int) {
        let count = arrSelectedProductView.count
        if row > 0 && row < count - 1 {
            let productView0 = arrSelectedProductView[row - 1]
            let productView1 = arrSelectedProductView[row + 1]
            vContent.addConstraint(NSLayoutConstraint(item: productView1, attribute: .top, relatedBy: .equal, toItem: productView0, attribute: .bottom, multiplier: 1, constant: 0))
        }else if row == 0{
            let productView = arrSelectedProductView[1]
            vContent.addConstraint(NSLayoutConstraint(item: productView, attribute: .top, relatedBy: .equal, toItem: btnAddProduct, attribute: .bottom, multiplier: 1, constant: 0))
        }else{
            let productView = arrSelectedProductView[count - 1]
            lcBottom = NSLayoutConstraint(item: productView, attribute: .bottom, relatedBy: .equal, toItem: vContent, attribute: .bottom, multiplier: 1, constant: 0)
            vContent.addConstraint(lcBottom!)
        }
        var productView : ProductView? = arrSelectedProductView[row]
        productView?.removeFromSuperview()
        arrSelectedProductView.remove(at: row)
        arrSelectedProducts.remove(at: row)
        productView = nil
    }
    
    func showProductInfo(row: Int) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "commercialsetting") as? CommercialSettingViewController {
            let productView = arrSelectedProductView[row]
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .overFullScreen
            controller.product = arrSelectedProducts[row]
            controller.price = productView.price
            controller.num = productView.number
            controller.discount = productView.discount
            controller.priceCH = priceCH
            controller.delegate = self
            controller.row = row
            controller.remark = productView.remark
            self.present(controller, animated: true, completion: {
                
            })
        }
    }
    
    // MARK: - CommercialSettingViewControllerDelegate
    func callbackWithParam(num: Int, price: Double, discount: Double, remark: String, row : Int) {
        let productView = arrSelectedProductView[row]
        productView.price = price
        productView.number = num
        productView.discount = discount
        productView.remark = remark
        productView.assignValue()
    }
}
