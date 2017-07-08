//
//  WaitWorkTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/25.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import MJRefresh
import Toaster
import SwiftyJSON
import DZNEmptyDataSet

class WaitWorkTableViewController: UITableViewController ,DZNEmptyDataSetDelegate , DZNEmptyDataSetSource {
    
    var page = 0
    var data : [JSON] = []
    var nShowEmpty = 2 // 1 无数据 2 加载中 3 无网络
    var row = 0
    var search = ""
    var bSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.page = 0
            self?.loadData()
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            [weak self] in
            self!.page += 1
            self?.loadData()
        })
        tableView.mj_footer.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(WaitWorkTableViewController.handleNotification(notification:)), name: Notification.Name("waitwork"), object: nil)
        
        if bSearch {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if nShowEmpty == 2 {
            self.loadData()
        }else{
            self.tableView.mj_header.beginRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWorkFlow, params: ["search" : search , "page" : page]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    if self!.page == 0 {
                        self?.data.removeAll()
                    }
                    if let records = object["records"].int {
                        if records < 20 {
                            self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                    if let arr = object["data"].array {
                        self!.data += arr
                    }
                    if self?.data.count == 0 {
                        self?.nShowEmpty = 3
                        self?.tableView.mj_footer.isHidden = true
                    }else{
                        self?.tableView.mj_footer.isHidden = false
                    }
                    self?.tableView.reloadData()
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                if self?.page == 0 && self?.data.count ?? 0 == 0{
                    self?.nShowEmpty = 1
                    self?.tableView.reloadData()
                }else{
                    Toast(text: "网络异常，请稍后重试").show()
                }
                
            }
        }
    }
    
    @IBAction func search(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "search") as? SearchViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            controller.modalPresentationStyle = .overFullScreen
            controller.searchName = "waitwork"
            self.present(controller, animated: true, completion: {
                
            })
        }
        
    }
    
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : Any] {
                    if let message = userInfo["message"] as? String {
                        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "order") as? OrderTableViewController {
                            controller.title = "搜索结果"
                            controller.search = message
                            controller.bSearch = true
                            controller.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = data[indexPath.row]["wf_name"].string
        }
        if let label = cell.viewWithTag(3) as? UILabel {
            label.text = "编号：\(data[indexPath.row]["wf_number"].stringValue) 类型：\(data[indexPath.row]["wf_type"].stringValue)"
        }
        if let label = cell.viewWithTag(4) as? UILabel {
            label.text = "进度：\(data[indexPath.row]["wf_rate"].stringValue) 来源人：\(data[indexPath.row]["wf_from"].stringValue) 待办人：\(data[indexPath.row]["wf_to"].stringValue)"
        }
        if let label = cell.viewWithTag(5) as? UILabel {
            label.text = "创建人：\(data[indexPath.row]["wf_adduser"].stringValue) 创建时间：\(data[indexPath.row]["wf_addtime"].stringValue)"
        }
        if let label = cell.viewWithTag(6) as? UILabel {
            let wf_ok = data[indexPath.row]["wf_ok"].stringValue
            if wf_ok == "0" {
                label.text = "进行中"
                
                if let dict = UserDefaults.standard.object(forKey: "mine") as? [String : Any] {
                    let uid = dict["id"] as? String ?? "0"
                    let wf_to_id = "\(data[indexPath.row]["wf_to_id"].intValue)"
                    if uid == wf_to_id {
                        label.textColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1)
                    }else{
                        label.textColor = UIColor(red: 30/255.0, green: 160/255.0, blue: 20/255.0, alpha: 1)
                    }
                }else{
                    label.textColor = UIColor(red: 30/255.0, green: 160/255.0, blue: 20/255.0, alpha: 1)
                }
            }else if wf_ok == "1" {
                label.text = "已完成"
                label.textColor = UIColor.blue
            }else{
                label.text = "销毁"
                label.textColor = UIColor.red
            }
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        row = indexPath.row
        self.performSegue(withIdentifier: "waitworkdetail", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? WaitWorkDetailTableViewController {
            controller.wfId = data[row]["id"].intValue
            controller.detail = data[row]
        }
    }
    
    // MARK: - 空数据
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        var name = ""
        if nShowEmpty == 1 {
            name = "empty"
        }else if nShowEmpty == 2 {
            name = "jiazaizhong"
        }else if nShowEmpty == 3 {
            name = "empty"
        }
        return UIImage(named: name)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var message = ""
        if nShowEmpty == 1 {
            message = "世界上最遥远的距离就是没有WIFI...\n请点击屏幕重新加载！"
        }else if nShowEmpty == 2 {
            message = "加载是件正经事儿，走心加载中..."
        }else if nShowEmpty == 3 {
            message = "空空如也，啥子都没有噢！"
        }
        let att = NSMutableAttributedString(string: message)
        att.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, att.length))
        return att
    }
    
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty == 2
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        if nShowEmpty > 0 && nShowEmpty != 2 {
            nShowEmpty = 2
            tableView.reloadData()
            loadData()
        }
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty > 0
    }
    
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0))
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0.0, 0.0, 1.0))
        animation.duration = 0.5
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
    
}
