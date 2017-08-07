//
//  NetworkManager.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/7.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    
    static let installshared = NetworkManager()
    let urlPrefix = "http://119.23.124.249/cloud-app/"
    let null = ""
    let appSendNews = "appSendNews.html"
    let appCheckPhone = "appCheckPhone.html"
    let login = "appLogin.html" // 登录接口
    let appGetUserModel = "appGetUserModel.html"
    let appSelFighistory = "appSelFighistory.html" // 查得明细
    let appReportFigure = "appReportFigure.html" // 统计数据
    let appFigureList = "appFigureList.html"  // 画像查询结果
    let appProjectType = "appProjectType.html" // 画像查询结果
    let appProjectList = "appProjectList.html" // 画像查询结果
    let appSelMyAppoint = "appSelMyAppoint.html" // 预约登记
    let appCustList = "appCustList.html" // 客户列表
    let appMyTask = "appMyTask.html" // 新的任务
    let appCustDetail = "appCustDetail.html" // 客户详情
    let appSetOutIn = "appSetOutIn.html" // 室外办公模式
    let appFigure = "appFigure.html" // 画像查询
    let appClickCall = "appClickCall.html" // 点击拨号
    let appSetStatus = "appSetStatus.html" //
    let appMyAppoint = "appMyAppoint.html" // 添加预约
    let appGetOut = "appGetOut.html" //
    let appCallResultConfig = "appCallResultConfig.html"
    let appFigureUpdate = "appFigureUpdate.html" // 刷新
    let appPopWindow = "appPopWindow.html" // 弹幕
    let appCustfollow = "appCustfollow.html" //
    let appCustfollowDetail = "appCustfollowDetail.html"
    
    func macAddress() -> String {
        if let mac = UserDefaults.standard.string(forKey: "domain") {
            return mac
        }else{
            return "cxst"
        }
    }
    
    /*"rows": {
     "companyid": "6",
     "extension": "8002",
     "phone": "18038004820",
     "code": "415622"
     }*/
    func request(type : HTTPMethod , url : String , params : Parameters? , callback : @escaping (JSON? , Error?)->())  {
        var paramters = params
        if paramters == nil {
            paramters = [:]
        }
        if let mine = UserDefaults.standard.object(forKey: "mine") as? [String : Any] {
            paramters?["companyid"] = mine["companyid"] as? String ?? ""
            paramters?["myexten"] = mine["extension"] as? String ?? ""
            paramters?["phone"] = mine["phone"] as? String ?? ""
            paramters?["code"] = mine["code"] as? String ?? ""
            paramters?["cacheDirName"] = "cache"
            paramters?["URL"] = "http://"
        }
        if paramters?.count ?? 0 > 0 {
            print("url:\(urlPrefix + url)")
            print(paramters!)
        }
        Alamofire.request(urlPrefix + url, method: type, parameters: paramters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let json = response.result.value {
                print(json)
                let object = JSON(json)
                if let status = object["status"].int, status == 0 {
                    if let info = object["info"].string, info == "你还没有登录app" {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.setRootControllerWithLogin()
                        }
                        UserDefaults.standard.removeObject(forKey: "mine")
                        return
                    }
                }
                callback(object, nil)
            }else{
                callback(nil , response.result.error)
            }
        }
    }
    
    func upload(url : String , params : [String : String] , data : Data? , callback : @escaping (JSON? , Error?)->()) {
        Alamofire.upload(
            multipartFormData: {[weak self] multipartFormData in
                let username = UserDefaults.standard.string(forKey: "username")!
                let pwd = UserDefaults.standard.string(forKey: "pwd")!
                var str = username + pwd
                str = String(str.characters.reversed()) + url + "\(Int(NSDate().timeIntervalSince1970))"
                str = Invalidate.randomMD5(identifierString: str)
                if data != nil {
                    multipartFormData.append(data!, withName: "filepath", fileName: (params["filepath"] ?? ""), mimeType: "image/jpeg")
                }
                multipartFormData.append(username.data(using: .utf8)!, withName: "account")
                multipartFormData.append(pwd.data(using: .utf8)!, withName: "passwd")
                multipartFormData.append(str.lowercased().data(using: .utf8)!, withName: "token")
                multipartFormData.append(self!.macAddress().data(using: .utf8)!, withName: "domain")
                for (key , value) in params {
                    if key != "filepath" {
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
                    }
                }
        },
            to: urlPrefix + url,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        callback(JSON(data: response.data!), nil)
                    }
                case .failure(let encodingError):
                    callback(nil , encodingError)
                }
        }
        )
    }
    
    func download(url: String , callback : @escaping (Data? , Error?)->())  {
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(NSString(string: url).lastPathComponent)")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(url, to: destination).responseData { response in
            
            if let data = response.result.value {
                callback(data , nil)
            }else{
                callback(nil , response.result.error)
            }
        }
    }
    
    func requestWithSession(callback : @escaping (_ data : Data?) -> ()) {
        let request = URLRequest(url: URL(string : "http://img3.imgtn.bdimg.com/it/u=3946772086,3737738661&fm=21&gp=0.jpg")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 30)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            callback(data)
        }
        task.resume()
    }
}

