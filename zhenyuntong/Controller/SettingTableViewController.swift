//
//  MyInfoTableViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/9.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var lblSize: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblSize.text = calculateCacheSize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            
        }else{
            let alert = UIAlertController(title: "提示", message: "需要清空缓存吗？", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
             
             }))
             alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] (action) in
                SDImageCache.shared().clearDisk()
                self?.lblSize.text = "0K"
             }))
             self.present(alert, animated: true, completion: {
             
             })
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
    
    // 退出登录
    @IBAction func loginOut(_ sender: Any) {
        let alert = UIAlertController(title: "提示", message: "确定退出吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] (action) in
            UserDefaults.standard.removeObject(forKey: "mine")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "pwd")
            UserDefaults.standard.removeObject(forKey: "domain")
            let controller = self?.storyboard?.instantiateViewController(withIdentifier: "navigation")
            self?.view.window?.rootViewController = controller
        }))
        self.present(alert, animated: true) {
            
        }
    }
    
    func calculateCacheSize() -> String {
        let size = SDImageCache.shared().getSize()
        if size < 1024 * 1024 {
            return "\(String(format: "%.2f", arguments: [Float(size) / 1024]))KB"
        }else if size < 1024 * 1024 * 1024 {
            return "\(String(format: "%.2f", arguments: [Float(size) / 1024 / 1024]))MB"
        }
        return "0.00B"
    }


}
