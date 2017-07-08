//
//  CommunityViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/8.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh
import Toaster
import DZNEmptyDataSet
import TabPageViewController

class CustomerViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , DZNEmptyDataSetSource , DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var page = 0
    var data : [JSON] = []
    var nShowEmpty = 2 // 1 无数据 2 加载中 3 无网络
    var tabPage : TabPageViewController!
    var tag = 0
    var row = -1
    var sidx = "id"
    var bSearch = false
    var connLabel = ""
    var search = ""
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(CustomerViewController.handleNotification(sender:)), name: Notification.Name("customer"), object: nil)
        
        if bSearch {
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.rightBarButtonItem = nil
        }else{
            let vTitle = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            vTitle.backgroundColor = UIColor.clear
            let button = UIButton()
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitle("客户管理", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.frame = CGRect(x: 0, y: 0, width: 88, height: 30)
            button.addTarget(self, action: #selector(CustomerViewController.tapTitle), for: .touchUpInside)
            vTitle.addSubview(button)
            let ivArrow = UIImageView(frame: CGRect(x: 88, y: 0, width: 12, height: 30))
            ivArrow.image = UIImage(named: "icon_down")
            ivArrow.contentMode = .scaleAspectFit
            vTitle.addSubview(ivArrow)
            self.navigationItem.titleView = vTitle
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if nShowEmpty == 2 {
            self.loadData()
        }else{
            tableView.mj_header.beginRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func search(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "search") as? SearchViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            controller.modalPresentationStyle = .overFullScreen
            controller.searchName = "customer"
            self.present(controller, animated: true, completion: {
                
            })
        }
    }
    
    func tapTitle() {
        let action = UIAlertController(title: "客户管理排序", message: nil, preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "默认", style: .default, handler: {[weak self] (action) in
            self?.sidx = "id"
            self?.tableView.mj_header.beginRefreshing()
        }))
        action.addAction(UIAlertAction(title: "活跃度", style: .default, handler: {[weak self] (action) in
            self?.sidx = "activity"
            self?.tableView.mj_header.beginRefreshing()
        }))
        action.addAction(UIAlertAction(title: "最近联系", style: .default, handler: {[weak self] (action) in
            self?.sidx = "updateTime"
            self?.tableView.mj_header.beginRefreshing()
        }))
        action.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        self.present(action, animated: true) {
            
        }
    }
    
    // MARK: - 自定义方法
    
    func loadData() {
        var params : [String : Any] = ["search" : search , "page" : page, "sidx" : sidx]
        if connLabel.characters.count > 0 {
            params["connLabel"] = connLabel
        }
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appCustList, params: params){
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
                        self?.tableView.mj_footer.isHidden = true
                        if let records = object["records"].int , records == 0 {
                            self?.nShowEmpty = 3
                            self?.tableView.reloadData()
                        }
                    }else{
                        if let message = object["msg"].string , message.characters.count > 0 {
                            Toast(text: message).show()
                        }
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
            }
        }
    }

    // 处理通知
    func handleNotification(sender : Notification)  {
        tag = sender.object as? Int ?? 0
        if tag == 0 || tag == 2 {
            if tabPage != nil {
                tabPage.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发起工单", style: .plain, target: self, action: #selector(CustomerViewController.handleRightBarButton))
            }
        }else if tag == 1 {
            if tabPage != nil {
                tabPage.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CustomerViewController.handleRightBarButton))
            }
        }else if tag == 10 {
            if let userInfo = sender.userInfo as? [String : Any] {
                if let connLabel = userInfo["connLabel"] as? String {
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "customer") as? CustomerViewController {
                        controller.title = "搜索结果"
                        controller.bSearch = true
                        controller.connLabel = connLabel
                        controller.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }else if let message = userInfo["message"] as? String {
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "customer") as? CustomerViewController {
                        controller.title = "搜索结果"
                        controller.bSearch = true
                        controller.search = message
                        controller.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }else{
            if tabPage != nil {
                tabPage.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(CustomerViewController.handleRightBarButton))
            }
        }
    }

// MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = data[indexPath.row]["customer"].string
        }
        if let label = cell.viewWithTag(3) as? UILabel {
            label.text = "客户分类：\(data[indexPath.row]["connType"].stringValue)"
        }
        if let label = cell.viewWithTag(4) as? UILabel {
            label.text = "手机号码：\(data[indexPath.row]["mobile"].stringValue) 归属人：\(data[indexPath.row]["adduser"].stringValue)"
        }
        if let label = cell.viewWithTag(5) as? UILabel {
            label.text = "\(data[indexPath.row]["remark"].stringValue)"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        row = indexPath.row
        tabPage = TabPageViewController.create()
        tabPage.title = "客户详情"
        guard let detail = self.storyboard?.instantiateViewController(withIdentifier: "customerdetail") as? CustomerDetailTableViewController else {
            return
        }
        guard let order = self.storyboard?.instantiateViewController(withIdentifier: "order") as? OrderTableViewController else {
            return
        }
        guard let call = self.storyboard?.instantiateViewController(withIdentifier: "call") as? CallTableViewController else {
            return
        }
        guard let follow = self.storyboard?.instantiateViewController(withIdentifier: "follow") as? FollowTableViewController else {
            return
        }
        follow.custId = data[indexPath.row]["id"].stringValue
        follow.hidesBottomBarWhenPushed = true
        follow.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        call.bCust = true
        call.mobile = data[indexPath.row]["mobile"].stringValue
        call.hidesBottomBarWhenPushed = true
        call.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        order.bCustomer = true
        order.custId = data[indexPath.row]["id"].stringValue
        order.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        tabPage.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发起工单", style: .plain, target: self, action: #selector(CustomerViewController.handleRightBarButton))
        detail.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        detail.data = data[indexPath.row]
        var option = TabPageOption()
        option.tabBackgroundColor = UIColor.white
        option.isTranslucent = false
        option.tabHeight = 44
        option.tabWidth = SCREENWIDTH / 4
        tabPage.option = option
        tabPage.tabItems = [(detail, "基本信息"), (follow, "跟进记录"), (order, "工单列表"), (call, "通话记录")]
        tabPage.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(tabPage, animated: true)
    }
    
    func handleRightBarButton() {
        if tag == 0 {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "ordermodel") as? OrderModelTableViewController {
                controller.detail = data[row]
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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



