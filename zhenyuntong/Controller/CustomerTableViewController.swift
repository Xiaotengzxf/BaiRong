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

class CustomerTableViewController: UITableViewController ,DZNEmptyDataSetDelegate , DZNEmptyDataSetSource, CustomerSearchViewControllerDelegate {
    
    var page = 0
    var data : [JSON] = []
    var nShowEmpty = 2 // 1 无数据 2 加载中 3 无网络
    var nCall = -1
    var nHandle = -1
    var mobile = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        NotificationCenter.default.addObserver(self, selector: #selector(CustomerTableViewController.handleNotification(notification:)), name: Notification.Name("CustomerTableViewController"), object: nil)
        
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
        var params : [String : Any] = ["rows" : 20 , "page" : page]
        if nCall >= 0 {
            params["seachstu"] = nCall
        }
        if nHandle >= 0 {
            params["seachhandle"] = nHandle
        }
        if mobile.characters.count > 0 {
            params["mobile"] = mobile
        }
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appCustList, params: params ){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            if let object = json {
                if let total = object["total"].int {
                    if total > 0 {
                        if total > self!.page * 20 {
                            if self!.page == 0 {
                                self?.data.removeAll()
                            }
                            if let records = object["rows"].array?.count {
                                if records < 20 {
                                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                                }
                            }
                            if let arr = object["rows"].array {
                                self!.data += arr
                            }
                            if self?.data.count == 0 {
                                self?.nShowEmpty = 1
                                self?.tableView.mj_footer.isHidden = true
                            }else{
                                self?.tableView.mj_footer.isHidden = false
                            }
                            self?.tableView.reloadData()
                        }
                    }else{
                        self?.data.removeAll()
                        self?.nShowEmpty = 3
                        self?.tableView.mj_footer.isHidden = true
                        self?.tableView.reloadData()
                        
                    }
                    
                }else{
                    if let status = object["status"].int, status == 0 {
                        if let info = object["info"].string {
                            Toast(text: info).show()
                        }
                        if self?.page == 0 && self?.data.count ?? 0 == 0{
                            self?.nShowEmpty = 3
                            self?.tableView.reloadData()
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
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "CustomerSearch") as? CustomerSearchViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            controller.modalPresentationStyle = .overFullScreen
            controller.delegate = self
            self.present(controller, animated: true, completion: {
                
            })
        }
        
    }
    
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : Any] {
                    print(userInfo)
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
        
        if let label = cell.viewWithTag(10) as? UILabel {
            label.text = data[indexPath.row]["customer"].string
        }
        if let label = cell.viewWithTag(11) as? UILabel {
            label.text = data[indexPath.row]["project_id"].string
        }
        if let label = cell.viewWithTag(12) as? UILabel {
            label.text = data[indexPath.row]["adduser"].string
        }
        if let label = cell.viewWithTag(13) as? UILabel {
            label.text = ""
        }
        if let label = cell.viewWithTag(14) as? UILabel {
            label.text = data[indexPath.row]["mobile"].string
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "CustomerDetail") as? CustomerDetailTableViewController {
            controller.json = data[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
    
    func customerSearch(nCall : Int , nHandle : Int ,mobile : String?) {
        self.nCall = nCall
        self.nHandle = nHandle
        self.mobile = mobile ?? ""
        self.tableView.mj_header.beginRefreshing()
    }
    
}
