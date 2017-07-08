//
//  SearchTableViewController.swift
//  Test
//
//  Created by 张晓飞 on 2016/12/21.
//  Copyright © 2016年 gemdale. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON
import IQKeyboardManagerSwift

class SearchViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reasonTextField: UITextField! // 事项名称
    @IBOutlet weak var vHead: UIView!
    @IBOutlet weak var vHeader: UIView!
    var tableData : [String] = []
    var dateString : String?
    var searchName : String!  // 搜索保存的关键词
    @IBOutlet weak var btnClear: UIButton!
    var x : CGFloat = 16
    var y : CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isHidden = true
        reasonTextField.leftView = leftView(name: "icn_search", size: CGSize(width: 20, height: 20))
        reasonTextField.leftViewMode = .always
        
    }
    
    func loadLabel() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appCustLabel, params: nil){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int {
                    if result == 1000 {
                        if let array = object["data"].array {
                            for json in array {
                                let button = UIButton()
                                let name = json["name"].string
                                let size = NSString(string: name!).size(attributes: [UIFontDescriptorNameAttribute : UIFont.systemFont(ofSize: 16)])
                                button.setTitle(name, for: .normal)
                                button.layer.cornerRadius = 15.0
                                button.clipsToBounds = true
                                button.tag = Int(json["id"].stringValue)!
                                button.addTarget(self, action: #selector(SearchViewController.doLabelSearch(button:)), for: .touchUpInside)
                                button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                                button.setTitleColor(UIColor.white, for: .normal)
                                button.backgroundColor = UIColor.colorWithHexString(hex: json["color"].stringValue)
                                button.translatesAutoresizingMaskIntoConstraints = false
                                self?.vHeader?.addSubview(button)
                                
                                if (self!.x + size.width + 40 + 16) > SCREENWIDTH {
                                    self!.x = 16
                                    self!.y += 40
                                }
                                self?.vHeader?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(x)-[button(w)]", options: .directionLeadingToTrailing, metrics: ["x" : self!.x , "w" : size.width + 40], views: ["button" : button]))
                                self?.vHeader?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(y)-[button(30)]", options: .directionLeadingToTrailing, metrics: ["y" : self!.y], views: ["button" : button]))
                                self!.x += size.width + 40 + 16
                            }
                            let label = UILabel()
                            label.text = "搜索记录"
                            label.textColor = UIColor.darkGray
                            label.font = UIFont.systemFont(ofSize: 16)
                            label.translatesAutoresizingMaskIntoConstraints = false
                            self?.vHeader.addSubview(label)
                            self?.vHeader?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[label(100)]", options: .directionLeadingToTrailing, metrics: nil, views: ["label" : label]))
                            self?.vHeader?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(y)-[label(20)]", options: .directionLeadingToTrailing, metrics: ["y" : self!.y + 60], views: ["label" : label]))
                            
                            let button = UIButton()
                            button.setTitle("清空历史", for: .normal)
                            button.setTitleColor(UIColor.green, for: .normal)
                            button.addTarget(self, action: #selector(SearchViewController.clear(_:)), for: .touchUpInside)
                            button.translatesAutoresizingMaskIntoConstraints = false
                            self?.vHeader.addSubview(button)
                            self?.vHeader?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[button(80)]-(16)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["button" : button]))
                            self?.vHeader?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(y)-[button(20)]", options: .directionLeadingToTrailing, metrics: ["y" : self!.y + 60], views: ["button" : button]))
                            
                            self?.tableView.tableHeaderView?.bounds = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: self!.y + 100)
                            self?.tableView.tableHeaderView?.backgroundColor = UIColor.white
                            self?.tableView.tableFooterView = nil
                            self?.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        if let array = UserDefaults.standard.object(forKey: searchName) as? [String] {
            tableData += array
            if array.count > 0 {
                tableView.tableFooterView?.isHidden = false
            }else{
                tableView.tableFooterView?.isHidden = true
            }
        }else{
            tableView.tableFooterView?.isHidden = true
        }
        if searchName == "customer" { // 如果是客户管理
            self.loadLabel()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.transform = CGAffineTransform(translationX: SCREENWIDTH, y: 0)
        self.translation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func translation() {
        self.tableView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            [weak self] in
            self?.tableView.transform = CGAffineTransform.identity
        }) {[weak self] (finish) in
            self?.reasonTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.reasonTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            [weak self] in
            self?.tableView.transform = CGAffineTransform(translationX: SCREENWIDTH, y: 0)
        }) {[weak self] (finished) in
            self?.dismiss(animated: true, completion: { 
                
            })
        }
    }

    @IBAction func clear(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: searchName)
        tableData.removeAll()
        tableView.reloadData()
        tableView.tableFooterView?.isHidden = true
    }
    
    func leftView(name : String, size : CGSize) -> UIView {
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
    
    func doLabelSearch(button : UIButton) {
        let tag = button.tag
        self.dismiss(animated: false) {
            [weak self] in
            NotificationCenter.default.post(name: Notification.Name(self!.searchName), object: 10, userInfo: ["connLabel" : "\(tag)"])
        }
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            label.text = tableData[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        reasonTextField.resignFirstResponder()
        let reason = tableData[indexPath.row]
        self.dismiss(animated: false) {
            [weak self] in
            NotificationCenter.default.post(name: Notification.Name(self!.searchName), object: (self!.searchName == "customer" ? 10 : 1), userInfo: ["message" : reason])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        reasonTextField.resignFirstResponder()
        let reason = reasonTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if reason?.characters.count ?? 0 > 0 {
            if tableData.contains(reason!) == false {
                if var array = UserDefaults.standard.object(forKey: searchName) as? [String] {
                    array.append(reason!)
                    UserDefaults.standard.set(array, forKey: searchName)
                    UserDefaults.standard.synchronize()
                }else{
                    UserDefaults.standard.set([reason!], forKey: searchName)
                    UserDefaults.standard.synchronize()
                }
            }
        }
        self.dismiss(animated: false) {
            [weak self] in
            NotificationCenter.default.post(name: Notification.Name(self!.searchName), object: (self!.searchName == "customer" ? 10 : 1), userInfo: ["message" : reason ?? ""])
        }
        return true
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
