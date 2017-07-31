//
//  IndexCollectionViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2017/3/14.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON
import TabPageViewController

private let reuseIdentifier = "Cell"

class IndexCollectionViewController: UICollectionViewController , UICollectionViewDelegateFlowLayout  {
    let titles = ["我的任务" , "画像查询" , "查得明细" ,
                  "我的预约" , "统计数据" , "系统设置"]
    let imageNames = ["icon_my_task" , "icon_portrait_eye" , "icon_query_detail" ,
                      "icon_appointment" , "icon_statistics" , "icon_settings"]
    var bViewShow = false
    var workOrderCount = 0
    var workFlowCount = 0
    @IBOutlet weak var modelItem: UIBarButtonItem!
    var page : TabPageViewController!
    var currentRow = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(IndexCollectionViewController.handleNotification(notification:)), name: Notification.Name(NotificationName.Index.rawValue), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bViewShow = true
        requestFormodel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bViewShow = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 读取是否为外出模式、办公模式
    func requestFormodel() {
        if bViewShow {
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appGetUserModel, params: nil){
                [weak self] (json , error) in
                if let object = json {
                    if let result = object["result"].int {
                        if result == 1011 {
                            
                        }else if result == 1000 {
                            if let data = object["msg"].string {
                                if data == "0" {
                                    self?.modelItem.title = "办公模式"
                                    MODELITEM = "办公模式"
                                }else if data == "1" {
                                    self?.modelItem.title = "外出模式"
                                    MODELITEM = "外出模式"
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    @IBAction func updateModel(_ sender: Any) {
        let model = self.navigationItem.rightBarButtonItem?.title == "外出模式" ? "办公模式" : "外出模式"
        let hud = showHUD(text: "设置\(model)")
        NetworkManager.installshared.request(type: .post, url: model == "办公模式" ? NetworkManager.installshared.appDelCFPhone : NetworkManager.installshared.appCFPhone, params: nil){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int {
                    if result == 1011 {
                        Toast(text: "设置\(model)失败：" + object["msg"].stringValue).show()
                    }else if result == 1000 {
                        Toast(text: "设置\(model)成功").show()
                        self?.modelItem.title = model
                    }
                    
                }
            }
        }
    }
    // 通知
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : Int] {
                    workOrderCount = userInfo["badge"] ?? 0
                    collectionView?.reloadData()
                }
            }else if tag == 2 {
                if let userInfo = notification.userInfo as? [String : Int] {
                    workFlowCount = userInfo["badge"] ?? 0
                    collectionView?.reloadData()
                }
            }else if tag >= 10 {
                if tag - 10 > 0 {
                    if page != nil {
                        page.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(IndexCollectionViewController.handleBarButtonEvent))
                    }
                }else{
                    if page != nil {
                        page.navigationItem.rightBarButtonItem = nil
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = titles[indexPath.item]
        }
        
        if let imageView = cell.viewWithTag(2) as? UIImageView {
            imageView.image = UIImage(named: imageNames[indexPath.item])
        }
        
        if let view = cell.viewWithTag(3) {
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor(colorLiteralRed: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
        }
        
//        if let label = cell.viewWithTag(4) as? UILabel {
//            if indexPath.row == 0 {
//                if workOrderCount > 0 {
//                    label.isHidden = false
//                    label.text = "\(workOrderCount)"
//                }else{
//                    label.isHidden = true
//                }
//            }else if indexPath.row == 2 {
//                if workFlowCount > 0 {
//                    label.isHidden = false
//                    label.text = "\(workFlowCount)"
//                }else{
//                    label.isHidden = true
//                }
//            }else{
//                label.isHidden = true
//            }
//        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: SCREENWIDTH / 3, height: SCREENWIDTH / 3 * 136 / 180.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        currentRow = indexPath.row
        if indexPath.row == 0 {
            NotificationCenter.default.post(name: Notification.Name("tabbar"), object: 1, userInfo: nil)
        }else if indexPath.row == 1 {
            NotificationCenter.default.post(name: Notification.Name("tabbar"), object: 2, userInfo: nil)
        }else if indexPath.row == 2 {
            NotificationCenter.default.post(name: Notification.Name("tabbar"), object: 3, userInfo: nil)
        }else if indexPath.row == 3 {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Reservation") as? ReservationTableViewController {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }else if indexPath.row == 4 {
            NotificationCenter.default.post(name: Notification.Name("tabbar"), object: 4, userInfo: nil)
        }else if indexPath.row == 5 {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Setting") {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func handleBarButtonEvent() {
        
    }
}
