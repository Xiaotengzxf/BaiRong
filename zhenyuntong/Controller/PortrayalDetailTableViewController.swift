//
//  PortrayalDetailTableViewController.swift
//  BaiRong
//
//  Created by 张晓飞 on 2017/7/26.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import MJRefresh
import Toaster
import SwiftyJSON
import DZNEmptyDataSet
import MBProgressHUD

class PortrayalDetailTableViewController: UITableViewController {
    
    var json : JSON!
    var arrTableData : [[String]] = []
    var dict : [String : String] = [:]
    var arrType : [JSON] = []
    var arrProject : [JSON] = []
    var count = 0
    var hud : MBProgressHUD!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        loadData()
        loadProjectList()
        loadProjectType()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadData() {
        hud = showHUD(text: "加载中...")
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appFigureList, params: ["projectid" : json["projectid"].stringValue , "id" : json["id"].stringValue, "type" : json["type"].stringValue, "mobile" : json["phmobile"].stringValue] ){
            [weak self] (json , error) in
            self?.count += 1
            if let object = json {
                if let total = object["total"].int, total > 0 {
                    if let dict = object["rows"].dictionaryObject as? [String : String], dict.count > 0{
                        self?.dict = dict
                        
                        self?.matchShowContent()
                    }
                }else{
                    if let info = object["info"].string {
                        Toast(text: info).show()
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
                
            }
        }
    }
    
    func loadProjectType() {
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appProjectType, params: nil ){
            [weak self] (json , error) in
            self?.count += 1
            if let object = json {
                if let total = object["total"].int, total > 0 {
                    if let dict = object["rows"].array {
                        self?.arrType = dict
                        self?.matchShowContent()
                    }
                }else{
                    if let info = object["info"].string {
                        Toast(text: info).show()
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
                
            }
        }
    }
    
    func loadProjectList() {
        NetworkManager.installshared.request(type: .post, url:  NetworkManager.installshared.appProjectList, params: nil ){
            [weak self] (json , error) in
            self?.count += 1
            if let object = json {
                if let total = object["total"].int, total > 0 {
                    if let dict = object["rows"].array {
                        self?.arrProject = dict
                        
                        self?.matchShowContent()
                    }
                }else{
                    if let info = object["info"].string {
                        Toast(text: info).show()
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
                
            }
        }
    }
    
    func matchShowContent() {
        if count != 3 {
            return
        }
        hud.hide(animated: true)
        if let name = dict["name"], name.characters.count > 0 && name != "0" {
            arrTableData.append(["姓名" , name])
        }
        if let mobile = dict["mobile"], mobile.characters.count > 0 && mobile != "0" {
            arrTableData.append(["手机号码" , mobile])
        }
        if let codeid = dict["codeid"], codeid.characters.count > 0 && codeid != "0" {
            arrTableData.append(["身份证号" , codeid])
        }
        if let mail = dict["mail"], mail.characters.count > 0 && mail != "0" {
            arrTableData.append(["邮箱" , mail])
        }
        if let age = dict["age"], age.characters.count > 0 && age != "0" {
            arrTableData.append(["年龄" , age])
        }
        if let sex = dict["sex"], sex.characters.count > 0 && sex != "0" {
            arrTableData.append(["性别" , sex])
        }
        if let idProvince = dict["idProvince"], idProvince.characters.count > 0 && idProvince != "0" {
            arrTableData.append(["省份" , idProvince])
        }
        if let idCity = dict["idCity"], idCity.characters.count > 0 && idCity != "0" {
            arrTableData.append(["城市" , idCity])
        }
        if let cellProvince = dict["cellProvince"], cellProvince.characters.count > 0 && cellProvince != "0" {
            arrTableData.append(["常住地-省份" , cellProvince])
        }
        if let cellCity = dict["cellCity"], cellCity.characters.count > 0 && cellCity != "0"{
            arrTableData.append(["常住地-城市" , cellCity])
        }
        if let occupation = dict["occupation"], occupation.characters.count > 0 && occupation != "0" {
            arrTableData.append(["职业" , occupation])
        }
        if let haveBaby = dict["haveBaby"], haveBaby.characters.count > 0 && haveBaby != "0"{
            arrTableData.append(["是否有婴幼儿子女" , haveBaby])
        }
        if let customerValueRank = dict["customerValueRank"], customerValueRank.characters.count > 0 && customerValueRank != "0" {
            arrTableData.append(["客户价值等级" , customerValueRank])
        }
        if let creditOutPerYear = dict["creditOutPerYear"], creditOutPerYear.characters.count > 0 && creditOutPerYear != "0" {
            arrTableData.append(["信用卡年消费" , creditOutPerYear])
        }
        if let assetsHouse = dict["assetsHouse"], assetsHouse.characters.count > 0 && assetsHouse != "0" {
            arrTableData.append(["房产评估" , assetsHouse])
        }
        if let assetsCar = dict["assetsCar"], assetsCar.characters.count > 0 && assetsCar != "0" {
            arrTableData.append(["车主评估" , assetsCar])
        }
        if let assetsWealth = dict["assetsWealth"], assetsWealth.characters.count > 0 && assetsWealth != "0" {
            arrTableData.append(["高价值客户评估" , assetsWealth])
        }
        if let focusHwcx = dict["focusHwcx"], focusHwcx.characters.count > 0 && focusHwcx != "0" {
            arrTableData.append(["户外出行关注程度" , focusHwcx])
        }
        if let focusJk = dict["focusJk"], focusJk.characters.count > 0 && focusJk != "0" {
            arrTableData.append(["健康关注程度" , focusJk])
        }
        if let focusYl = dict["focusYl"], focusYl.characters.count > 0 && focusYl != "0" {
            arrTableData.append(["养老关注程度" , focusYl])
        }
        if let focusJy = dict["focusJy"], focusJy.characters.count > 0 && focusJy != "0" {
            arrTableData.append(["教育关注程度" , focusJy])
        }
        if let focusTzlc = dict["focusTzlc"], focusTzlc.characters.count > 0 && focusTzlc != "0" {
            arrTableData.append(["投资理财关注程度" , focusTzlc])
        }
        if let focusZn = dict["focusZn"], focusZn.characters.count > 0 && focusZn != "0" {
            arrTableData.append(["与子女相关电商品类的关注程度" , focusZn])
        }
        if let focusPo = dict["focusPo"], focusPo.characters.count > 0 && focusPo != "0"{
            arrTableData.append(["与配偶相关电商品类的关注程度" , focusPo])
        }
        if let internetPrefer = dict["internetPrefer"], internetPrefer.characters.count > 0 && internetPrefer != "0"{
            arrTableData.append(["互联网渠道偏好" , internetPrefer])
        }
        if let brandTop1 = dict["brandTop1"], brandTop1.characters.count > 0 && brandTop1 != "0"{
            arrTableData.append(["历史中第1最关注的品牌" , brandTop1])
        }
        if let brandTop2 = dict["brandTop2"], brandTop2.characters.count > 0 && brandTop2 != "0"{
            arrTableData.append(["历史中第2最关注的品牌" , brandTop2])
        }
        if let brandTop3 = dict["brandTop3"], brandTop3.characters.count > 0 && brandTop3 != "0" {
            arrTableData.append(["历史中第3最关注的品牌" , brandTop3])
        }
        if let consVistTop1 = dict["consVistTop1"], consVistTop1.characters.count > 0 && consVistTop1 != "0"{
            arrTableData.append(["排名第1的高消费次数的电商品类" , consVistTop1])
        }
        if let consVistTop2 = dict["consVistTop2"], consVistTop2.characters.count > 0 && consVistTop2 != "0" {
            arrTableData.append(["排名第2的高消费次数的电商品类" , consVistTop2])
        }
        if let consVistTop3 = dict["consVistTop3"], consVistTop3.characters.count > 0 && consVistTop3 != "0" {
            arrTableData.append(["排名第3的高消费次数的电商品类" , consVistTop3])
        }
        if let mediaTop1 = dict["mediaTop1"], mediaTop1.characters.count > 0 && mediaTop1 != "0" {
            arrTableData.append(["排名第1的最关注的媒体" , mediaTop1])
        }
        if let mediaTop2 = dict["mediaTop2"], mediaTop2.characters.count > 0 && mediaTop2 != "0" {
            arrTableData.append(["排名第2的最关注的媒体" , mediaTop2])
        }
        if let mediaTop3 = dict["mediaTop3"], mediaTop3.characters.count > 0 && mediaTop3 != "0" {
            arrTableData.append(["排名第3的最关注的媒体" , mediaTop3])
        }
        if let consNumTop1 = dict["consNumTop1"], consNumTop1.characters.count > 0 && consNumTop1 != "0" {
            arrTableData.append(["排名第1的高消费次数的电商品类" , consNumTop1])
        }
        if let consNumTop2 = dict["consNumTop2"], consNumTop2.characters.count > 0 && consNumTop2 != "0" {
            arrTableData.append(["排名第2的高消费次数的电商品类" , consNumTop2])
        }
        if let consNumTop3 = dict["consNumTop3"], consNumTop3.characters.count > 0 && consNumTop3 != "0" {
            arrTableData.append(["排名第3的高消费次数的电商品类" , consNumTop3])
        }
        if let interest = dict["interest"], interest.characters.count > 0 && interest != "0" {
            arrTableData.append(["兴趣爱好" , interest])
        }
        if let user_type = dict["user_type"], user_type.characters.count > 0 && user_type != "0" {
            arrTableData.append(["社交帐号类型" , user_type])
        }
        if let level = dict["level"], level.characters.count > 0 && level != "0" {
            arrTableData.append(["社交帐号等级" , level])
        }
        if let follow_num = dict["follow_num"], follow_num.characters.count > 0 && follow_num != "0" {
            arrTableData.append(["社交帐号关注人数" , follow_num])
        }
        if let fans_num = dict["fans_num"], fans_num.characters.count > 0 && fans_num != "0"{
            arrTableData.append(["社交帐号粉丝人数" , fans_num])
        }
        if let weibo_num = dict["weibo_num"], weibo_num.characters.count > 0 && weibo_num != "0" {
            arrTableData.append(["社交帐号发表微博数" , weibo_num])
        }
        if let blog = dict["blog"], blog.characters.count > 0 && blog != "0" {
            arrTableData.append(["社交帐号博客" , blog])
        }
        if let blackList = dict["blackList"], blackList.characters.count > 0 && blackList != "0" {
            arrTableData.append(["银行/小贷/P2P等黑名单" , blackList])
        }
        if let overdue = dict["overdue"], overdue.characters.count > 0 && overdue != "0" {
            arrTableData.append(["银行/小贷/P2P等逾期" , overdue])
        }
        if let scorebank = dict["scorebank"], scorebank.characters.count > 0 && scorebank != "0" {
            arrTableData.append(["信用评分" , scorebank])
        }
        if let type = dict["type"], type.characters.count > 0 && type != "0" {
            for item in arrType {
                if item["id"].stringValue == type {
                    arrTableData.append(["项目类型" , item["typename"].stringValue])
                    break
                }
            }
        }
        if let adduser = dict["adduser"], adduser.characters.count > 0 && adduser != "0" {
            arrTableData.append(["坐席" , adduser])
        }
        if let addtime = dict["addtime"], addtime.characters.count > 0 && addtime != "0"{
            arrTableData.append(["添加时间" , addtime])
        }
        if let projectid = dict["projectid"], projectid.characters.count > 0 && projectid != "0"{
            for project in arrProject {
                if project["id"].stringValue == projectid {
                    arrTableData.append(["项目名称" , project["project_name"].stringValue])
                    break
                }
            }
            
        }
        if let datanumber = dict["datanumber"], datanumber.characters.count > 0 && datanumber != "0"{
            arrTableData.append(["数据批次" , datanumber])
        }
        self.tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrTableData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if let label = cell.contentView.viewWithTag(1) as? UILabel {
            label.text = arrTableData[indexPath.row][0]
        }
        
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            label.text = arrTableData[indexPath.row][1]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

}
