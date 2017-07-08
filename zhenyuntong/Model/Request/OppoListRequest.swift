//
//  OppoListRequest.swift
//  AntService
//
//  Created by 张晓飞 on 2017/6/30.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit

class OppoListRequest: BaseRequest {
    var type = 0
    var state = 0
    var page = 0
    var searchdata = ""
    
    override func joinToParams(params: inout [String : String]) {
        super.joinToParams(params: &params)
        params["type"] = "\(type)"
        params["state"] = "\(state)"
        params["page"] = "\(page)"
        params["searchdata"] = searchdata
    }
}
