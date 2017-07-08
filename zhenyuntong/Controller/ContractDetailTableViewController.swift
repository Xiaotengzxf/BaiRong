//
//  ContractDetailTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/20.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster
import WebKit

class ContractDetailTableViewController: UITableViewController , WKUIDelegate , WKNavigationDelegate {

    let titles = ["合同名称：" , "合同模板：" , "合同备注：" , "添 加 人：" , "添加时间：" , "合同附件："]
    var data : JSON!
    var data2 : JSON?
    var webView : WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.rowHeight = UITableViewAutomaticDimension
        let jsScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jsScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: SCREENWIDTH, height: 100), configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appContractDetail, params: ["conId" : data["id"].intValue]){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.data2 = object["data"]
                    _ = self?.webView.loadHTMLString(self!.data2!["contents"].stringValue, baseURL: nil)
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
    
    func setDefaultValue(value : String?) -> String {
        if value == nil || value!.characters.count == 0 {
            return " "
        }
        return value ?? " "
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = titles[indexPath.row]
        }
        
        if let label = cell.viewWithTag(3) as? UILabel {
            switch indexPath.row {
            case 0:
                label.text = setDefaultValue(value: data["name"].string)
            case 1:
                label.text = setDefaultValue(value: data["cmid"].string)
            case 2:
                label.text = setDefaultValue(value: data["remarks"].string)
            case 3:
                label.text = setDefaultValue(value: data["adduser"].string)
            case 4:
                label.text = setDefaultValue(value: data["addtime"].string)
            case 5:
                label.text = setDefaultValue(value: data2?["annexesname"].string)
            default:
                fatalError()
            }
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.offsetHeight;", completionHandler:{[weak self] (result , error) in
            print("高度\(result)")
            if var height = result as? CGFloat {
                let scrollHeight = webView.scrollView.contentSize.height
                if scrollHeight > height {
                    height = scrollHeight
                }
                webView.frame = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: height)
                self?.tableView.tableFooterView = webView
                self?.tableView.tableFooterView?.frame = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: height )
                self?.tableView.reloadData()
            }
            
        })
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
