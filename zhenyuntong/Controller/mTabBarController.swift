//
//  mTabBarController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/12.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON

class mTabBarController: UITabBarController {

    var timer : DispatchSourceTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
//        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(60))
//        timer?.setEventHandler(handler: { 
//            [weak self] in
//            self?.requestPullTag()
//        })
//        timer?.resume()
    }
    
    func requestPullTag() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appPullTag, params: nil){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int {
                    if result == 1000 {
                        var count = 0
                        if let workOrderCount = object["data" , "WorkorderCount"].int {
                            count += workOrderCount
                            if workOrderCount > 0 {
                                self?.tabBar.items?[2].badgeValue = "\(workOrderCount)"
                            }else{
                                self?.tabBar.items?[2].badgeValue = nil
                            }
                            NotificationCenter.default.post(name: Notification.Name(NotificationName.Index.rawValue), object: 1, userInfo: ["badge" : workOrderCount])
                        }
                        if let WorkflowCount = object["data" , "WorkflowCount"].int {
                            count += WorkflowCount
                            NotificationCenter.default.post(name: Notification.Name(NotificationName.Index.rawValue), object: 2, userInfo: ["badge" : WorkflowCount])
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.cancel()
        timer = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
