//
//  WaitWorkDetailTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/25.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh
import Toaster
import SKPhotoBrowser

class WaitWorkDetailTableViewController: UITableViewController , WaitWorkTableViewCellDelegate {
    
    var data : JSON?
    var detail : JSON!
    var wfId = 0
    let titles = ["编        号：" , "名        称：" , "类        型：" , "状        态：" , "来  源  于：" , "待  办  人：" , "内        容：" , "备        注：" , "创  建  人：" , "创建时间："]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.loadData()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(WaitWorkDetailTableViewController.handleNotification(notification:)), name: Notification.Name("waitworkdetail"), object: nil)
        
        if let wf_ok = detail?["wf_ok"].stringValue, wf_ok == "0" {
            if let dict = UserDefaults.standard.object(forKey: "mine") as? [String : Any] {
                let uid = dict["id"] as? String ?? "0"
                let wf_to_id = "\(detail!["wf_to_id"].intValue)"
                if uid == wf_to_id {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "操作", style: .plain, target: self, action: #selector(WaitWorkDetailTableViewController.operation(_:)))
                }else{
                    navigationItem.rightBarButtonItem = nil
                }
            }else{
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.mj_header.beginRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWFDetail, params: ["wfId" : wfId]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.data = object["data"]
                    self?.tableView.reloadData()
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
    
    func loadNext() {
        let hud = showHUD(text: "加载中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWFDo, params: ["wf_id" : wfId , "step_id" : data?["flowInfo" , "wf_template"].string ?? ""]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    if let array = object["data"].array {
                        if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "orderhandle") as? OrderHandleViewController {
                            controller.modalTransitionStyle = .crossDissolve
                            controller.modalPresentationStyle = .overFullScreen
                            controller.arrayStep = array
                            controller.wfId = self!.wfId
                            self?.present(controller, animated: true, completion: {
                                
                            })
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
    }
    
    func loadEntrust() {
        let hud = showHUD(text: "加载中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWFGetEntrust, params: ["wf_id" : wfId , "step_id" : data?["flowInfo" , "wf_template"].string ?? ""]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    if let array = object["data"].array {
                        if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "waitworkhandle") as? WaitWorkHandleViewController {
                            controller.modalTransitionStyle = .crossDissolve
                            controller.modalPresentationStyle = .overFullScreen
                            controller.arrayUser = array
                            controller.wfId = self!.wfId
                            self?.present(controller, animated: true, completion: {
                                
                            })
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
    }
    
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : Any] {
                    let alert = UIAlertController(title: "指派给\(userInfo["nickname"] as? String ?? "")", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] (action) in
                        if let desc = alert.textFields?.first?.text {
                            self?.assign(userInfo: userInfo, desc: desc)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        
                    }))
                    alert.addTextField(configurationHandler: { (textField) in
                        textField.placeholder = "请输入指派说明"
                    })
                }
            }else if tag == 2 {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func assign(userInfo: [String : Any] , desc : String)  {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWOAssign, params: ["tomove" : userInfo["id"] as? String ?? "" , "wfId" : wfId , "remarks" : desc]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.tableView.mj_header.beginRefreshing()
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
    
    func operation(_ sender: Any) {
        
        let sheet = UIAlertController(title: "操作", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "处理", style: .default, handler: {[weak self] (action) in
            self?.loadNext()
        }))
        sheet.addAction(UIAlertAction(title: "委托", style: .default, handler: {[weak self] (action) in
            self?.loadEntrust()
        }))
        sheet.addAction(UIAlertAction(title: "销毁", style: .default, handler: {[weak self] (action) in
            if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "waitworkclear") as? WaitWorkClearViewController {
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .overFullScreen
                controller.wfId = self!.wfId
                self?.present(controller, animated: true, completion: {
                    
                })
            }
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        self.present(sheet, animated: true) { 
            
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return titles.count
        }else{
            return data?["dealRecord"].array?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            if let label = cell.viewWithTag(2) as? UILabel {
                label.text = titles[indexPath.row]
            }
            if let label = cell.viewWithTag(3) as? UILabel {
                switch indexPath.row {
                case 0:
                    label.text = detail["wf_number"].string
                case 1:
                    label.text = detail["wf_name"].string
                case 2:
                    label.text = detail["wf_type"].string
                case 3:
                    let wf_ok = detail["wf_ok"].stringValue
                    if wf_ok == "0" {
                        label.text = "进行中"
                    }else if wf_ok == "1" {
                        label.text = "已完成"
                    }else{
                        label.text = "销毁"
                    }
                case 4:
                    label.text = detail["wf_from"].string
                case 5:
                    label.text = detail["wf_to"].string
                case 6:
                    label.text = detail["wf_content"].string
                case 7:
                    label.text = data?["flowInfo" , "wf_remark"].string
                case 8:
                    label.text = detail["wf_adduser"].string
                case 9:
                    label.text = detail["wf_addtime"].string
                default:
                    fatalError()
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! WaitWorkTableViewCell
            cell.delegate = self
            if let file = data?["dealRecord" , indexPath.row , "file"].string , file.characters.count > 0 {
                cell.btnFile.isHidden = false
                cell.lcBottom.constant = 10
                cell.file = file
            }else{
                cell.btnFile.isHidden = true
                cell.lcBottom.constant = -25
                cell.file = ""
            }
            let attributeString = NSAttributedString(string: "附件信息", attributes: [NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue , NSForegroundColorAttributeName : UIColor.blue , NSFontAttributeName : UIFont.systemFont(ofSize: 15)])
            cell.btnFile.setAttributedTitle(attributeString, for: .normal)
            if let imageView = cell.viewWithTag(2) as? UIImageView {
                let image = UIImage(named: "bg_diggle_white")?.resizableImage(withCapInsets: UIEdgeInsetsMake(40, 30, 22, 20))
                imageView.image = image
            }
            if let label = cell.viewWithTag(3) as? UILabel {
                label.text = data?["dealRecord" , indexPath.row , "r_from"].string
            }
            if let label = cell.viewWithTag(4) as? UILabel {
                let type = data?["dealRecord" , indexPath.row , "result"].string
                label.text = type == "4" ? "" : data?["dealRecord" , indexPath.row , "r_to"].string
            }
            if let label = cell.viewWithTag(5) as? UILabel {
                label.text = data?["dealRecord" , indexPath.row , "opinion"].string
            }
            if let label = cell.viewWithTag(6) as? UILabel {
                label.text = data?["dealRecord" , indexPath.row , "time"].string
            }
            if let label = cell.viewWithTag(7) as? UILabel {
                // 0不通过1通过2销毁3新增4完成5委托
                if let type = data?["dealRecord" , indexPath.row , "result"].string {
                    if type == "0" {
                        label.text = "审核不通过指派给"
                    }else if type == "1" {
                        label.text = "审核通过指派给"
                    }else if type == "2" {
                        label.text = "销毁"
                    }else if type == "3" {
                        label.text = "新建流程指派给"
                    }else if type == "4" {
                        label.text = "完成流程"
                    }else if type == "5" {
                        label.text = "审核委托指派给"
                    }
                }
                
            }
            if let imageView = cell.viewWithTag(10) as? UIImageView {
                let count = data?["dealRecord"].array?.count ?? 0
                imageView.isHidden = indexPath.row == count - 1
            }
            if let imageView = cell.viewWithTag(11) as? UIImageView {
                imageView.isHidden = indexPath.row == 0
            }
            if let label = cell.viewWithTag(12) as? UILabel {
                label.text = data?["dealRecord" , indexPath.row , "rate"].string
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }else{
            return 150
        }
    }
    
    func showFile(file: String) {
        if file.characters.count > 0 && file.hasPrefix("http://") {
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImageURL(file)
            photo.shouldCachePhotoURLImage = false
            images.append(photo)
            SKPhotoBrowserOptions.displayAction = false
            let browser = SKPhotoBrowser(photos: images)
            present(browser, animated: true, completion: {})
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
