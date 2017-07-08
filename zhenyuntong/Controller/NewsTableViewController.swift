//
//  NewsTableViewController.swift
//  Test
//
//  Created by 张晓飞 on 2016/12/19.
//  Copyright © 2016年 gemdale. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh
import Toaster

class NewsTableViewController: UITableViewController {
    
    var data : JSON?
    var news : [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            [weak self] in
            self?.loadData()
        })
        tableView.mj_header.beginRefreshing()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.null, params: ["maxSysMsgId" : 0 , "sysSessionId" : data!["sessionId"].intValue]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    let array = object["data"].arrayValue
                    self?.news = array
                    self?.tableView.reloadData()
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                Toast(text: "网络出错，请检查网络").show()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = news[indexPath.row]
        if let label = cell.contentView.viewWithTag(3) as? UILabel {
            label.text = item["title"].string
        }
        
        if let label = cell.contentView.viewWithTag(5) as? UILabel {
            label.text = item["content"].string
        }
        
        
        if let imageView = cell.contentView.viewWithTag(4) as? UIImageView {
            imageView.sd_setImage(with: URL(string: item["imgUrl"].stringValue), placeholderImage: UIImage(named: "img_default_big"))
        }
        
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            label.text = DateManager.installShared.dateFromDefaultToLocalString(dateString: item["sendTime"].stringValue)
        }
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = news[indexPath.row]
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "webview") as? WebViewController {
            controller.linkUrl = item["linkUrl"].string
            controller.title = item["title"].string
            self.navigationController?.pushViewController(controller, animated: true)
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
