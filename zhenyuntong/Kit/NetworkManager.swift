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
    let urlPrefix = "http://api.mayikf.com/"
    let null = ""
    let login = "appLogin.html" // 登录接口
    let appGetUserModel = "appGetUserModel.html"
    let appPullTag = "appPullTag.html"
    let appUntreatedWO = "appUntreatedWO.html"
    let appCustList = "appCustList.html"
    let appAddCust = "appAddCust.html"
    let appModifySelf = "appModifySelf.html"
    let appModifyAvatar = "appModifyAvatar.html"
    let appWODetail = "appWODetail.html"
    let appUserList = "appUserList.html"
    let appWOAssign = "appWOAssign.html"
    let appTreatedWO = "appTreatedWO.html"
    let appDepartment = "appDepartment.html"
    let appCommondity = "appCommondity.html"
    let appContract = "appContract.html"
    let appContractDetail = "appContractDetail.html"
    let appWorkLog = "appWorkLog.html"
    let appAddWorkLog = "appAddWorkLog.html"
    let appCFPhone = "appCFPhone.html"
    let appDelCFPhone = "appDelCFPhone.html"
    let appOfferList = "appOfferList.html"
    let appOfferDetail = "appOfferDetail.html"
    let appCallRecords = "appCallRecords.html"
    let appWorkFlow = "appWorkFlow.html"
    let appWFDetail = "appWFDetail.html"
    let appWFT = "appWFT.html"
    let appWFTDetail = "appWFTDetail.html"
    let appWFSelectTo = "appWFSelectTo.html"
    let appWFAdd = "appWFAdd.html"
    let appWOTempList = "appWOTempList.html"
    let appWOTempDetail = "appWOTempDetail.html"
    let appAddCustTicket = "appAddCustTicket.html"
    let appCustTicket = "appCustTicket.html"
    let appCustCallRecords = "appCustCallRecords.html"
    let appCustFollow = "appCustFollow.html"
    let appDownloadCF = "appDownloadCF.html"
    let appWFDo = "appWFDo.html"
    let appWFDesig = "appWFDesig.html"
    let appWFSaveHandle = "appWFSaveHandle.html"
    let appWFGetEntrust = "appWFGetEntrust.html"
    let appWFEntrust = "appWFEntrust.html"
    let appWFClose = "appWFClose.html"
    let appCustLabel = "appCustLabel.html"
    let appUpdateWorkLog = "appUpdateWorkLog.html"
    let appDelWorkLog = "appDelWorkLog.html"
    let appDepWorkLog = "appDepWorkLog.html"
    let appWOAppoint = "appWOAppoint.html"
    let appWOClose = "appWOClose.html"
    let appCallBack = "appCallBack.html"
    let appCommentList = "appCommentList.html"
    let appSaveComm = "appSaveComm.html"
    let appOppoList = "appOppoList.html"
    let appOppoDetail = "appOppoDetail.html"
    let appOppoTP = "appOppoTP.html"
    let appAddOppo = "appAddOppo.html"
    let appOppoActbus = "appOppoActbus.html"
    let appOppoAllot = "appOppoAllot.html"
    
    func macAddress() -> String {
        if let mac = UserDefaults.standard.string(forKey: "domain") {
            return mac
        }else{
            return "cxst"
        }
    }
    
    func request(type : HTTPMethod , url : String , params : Parameters? , callback : @escaping (JSON? , Error?)->())  {
        let username = UserDefaults.standard.string(forKey: "username")!
        let pwd = UserDefaults.standard.string(forKey: "pwd")!
        var str = username + pwd
        str = String(str.characters.reversed()) + url + "\(Int(NSDate().timeIntervalSince1970))"
        str = Invalidate.randomMD5(identifierString: str)
        var paramters = params
        if paramters == nil {
            paramters = [:]
        }
        var p = "\(urlPrefix + url)?"
        for (key , value) in paramters! {
            p += "\(key)=\(value)&"
        }
        print(p)
        paramters?["account"] = username
        paramters?["passwd"] = pwd
        paramters?["token"] = str.lowercased()
        paramters?["domain"] = macAddress()
        
        Alamofire.request(urlPrefix + url, method: type, parameters: paramters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let json = response.result.value {
                print(json)
                let object = JSON(json)
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

