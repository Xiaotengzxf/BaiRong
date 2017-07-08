//
//  OrderTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/15.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import MJRefresh
import Toaster
import SwiftyJSON
import DZNEmptyDataSet

class OrderTableViewController: UITableViewController ,DZNEmptyDataSetDelegate , DZNEmptyDataSetSource {
    
    var page = 0
    var data : [JSON] = []
    var nShowEmpty = 2 // 1 无数据 2 加载中 3 无网络
    var row = 0
    var search = ""
    var bSearch = false
    var bHandled = false // f 待处理  t 已处理
    var bCustomer = false
    var custId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = bSearch ? "搜索结果" : (bHandled ? "已处理工单" : "待处理工单")
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
        NotificationCenter.default.addObserver(self, selector: #selector(OrderTableViewController.handleNotification(notification:)), name: Notification.Name(bHandled ? "finishedOrder" : "unfinishedOrder"), object: nil)
        
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
        NetworkManager.installshared.request(type: .post, url: bCustomer ? NetworkManager.installshared.appCustTicket : (bHandled ? NetworkManager.installshared.appTreatedWO : NetworkManager.installshared.appUntreatedWO), params: bCustomer ? ["custId" : custId , "page" : page] : ["search" : search , "page" : page]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            if let object = json {
                if let result = object["result"].int {
                    if result == 1000 {
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
                            self?.nShowEmpty = 1
                            self?.tableView.mj_footer.isHidden = true
                        }else{
                            self?.tableView.mj_footer.isHidden = false
                        }
                        self?.tableView.reloadData()
                    }else if result == 1004 {
                        self?.nShowEmpty = 3
                        self?.tableView.reloadData()
                    }else{
                        if let message = object["msg"].string , message.characters.count > 0 {
                            Toast(text: message).show()
                        }
                    }
                    
                }
            }else{
                if self?.page == 0 && self?.data.count ?? 0 == 0{
                    self?.nShowEmpty = 3
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
            controller.searchName = bHandled ? "finishedOrder" : "unfinishedOrder"
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
                            controller.search = message
                            controller.bSearch = true
                            controller.bHandled = bHandled
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
            label.text = data[indexPath.row]["work_title"].string
        }
        if let label = cell.viewWithTag(3) as? UILabel {
            label.text = "工单号：\(data[indexPath.row]["order_num"].stringValue) 工单类型：\(data[indexPath.row]["ordertype"].stringValue)"
        }
        if let label = cell.viewWithTag(4) as? UILabel {
            label.text = "当前处理人：\(data[indexPath.row]["current_user"].stringValue)"
        }
        if let label = cell.viewWithTag(5) as? UILabel {
            label.text = "下单人：\(data[indexPath.row]["add_user"].stringValue) 下单时间：\(data[indexPath.row]["add_time"].stringValue)"
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        row = indexPath.row
        self.performSegue(withIdentifier: "orderdetail", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? OrderDetailTableViewController {
            controller.woId = data[row]["id"].intValue
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
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0))
        animation.duration = 0.5
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }

}
