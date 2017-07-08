//
//  BaseRequest.swift
//  AntService
//
//  Created by 张晓飞 on 2017/6/30.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import Foundation

class BaseRequest {
    internal var domain = "default"
    internal var account = ""
    internal var password = ""
    internal var token = ""
    init() {
        
    }
    func joinToParams( params : inout [String : String]) {
        params["domain"] = domain
        params["account"] = account
        params["password"] = password
        params["token"] = token
    }
}
