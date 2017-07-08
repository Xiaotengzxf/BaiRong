//
//  MineTableViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/5.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import ALCameraViewController
import Alamofire
import Toaster

class MineTableViewController: UITableViewController {
    
    private var titles : [[String]] = []
    var image : UIImage?
    var row = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        titles = [["头像" , "账号" ,"昵称", "手机" , "分机" , "角色" , "部门" , "签名"] , ["密码修改"]]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 8
        }else{
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.section == 0 && indexPath.row == 0 ? "Cell1" : "Cell2", for: indexPath)

        let userinfo = UserDefaults.standard.object(forKey: "mine") as? [String : Any]
        let username = UserDefaults.standard.string(forKey: "username")
        // Configure the cell...
        if indexPath.section == 0 && indexPath.row == 0 {
            if let label = cell.viewWithTag(2) as? UILabel {
                label.text = titles[0][0]
            }
            if let imageView = cell.viewWithTag(1) as? UIImageView {
                if image != nil {
                    imageView.image = image
                }else {
                    imageView.sd_setImage(with: URL(string: userinfo?["img"] as? String ?? ""), placeholderImage: UIImage(named: "header_default"))
                }
            }
            
        }else{
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = titles[indexPath.section][indexPath.row]
            }
            if let label = cell.viewWithTag(2) as? UILabel {
                if indexPath.row == 1 {
                    label.text = username
                }else if indexPath.row == 2 {
                    label.text = userinfo?["nickname"] as? String
                }else if indexPath.row == 3 {
                    label.text = userinfo?["mobile"] as? String
                }else if indexPath.row == 4 {
                    label.text = userinfo?["exten"] as? String
                }else if indexPath.row == 5 {
                    label.text = userinfo?["role"] as? String
                }else if indexPath.row == 6 {
                    label.text = userinfo?["department"] as? String
                }else if indexPath.row == 7 {
                    label.text = userinfo?["sign"] as? String
                }
            }
            if indexPath.row == 1 || indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6 {
                cell.accessoryType = .none
            }else{
                cell.accessoryType = .disclosureIndicator
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }else{
            return max(44, 55 * SCREENWIDTH / 414.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // 修改头像
                changeHeadImage()
            }else if indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 7 {
                row = indexPath.row
                self.performSegue(withIdentifier: "toNick", sender: self)
            }
            
        }else{
            self.performSegue(withIdentifier: "modifypwd", sender: self)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ModifyNickViewController {
            controller.row = row
        }
    }
    
    
    func changeHeadImage()  {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            // Do something with your image here.
            // If cropping is enabled this image will be the cropped version
            self?.dismiss(animated: true, completion: nil)
            if image != nil {
                self?.image = image
                self?.tableView.reloadData()
                self?.modifyHeader()
            }
        }
        self.present(cameraViewController, animated: true, completion: nil)
    }
    
    func modifyHeader() {
        let hud = showHUD(text: "加载中...")
        Alamofire.upload(multipartFormData: {[weak self] (data) in
            data.append(UIImagePNGRepresentation(self!.image!)!, withName: "img", fileName: "\(Date().timeIntervalSince1970)crop.png", mimeType: "image/png")
            let username = UserDefaults.standard.string(forKey: "username")!
            let pwd = UserDefaults.standard.string(forKey: "pwd")!
            var str = username + pwd
            str = String(str.characters.reversed()) + NetworkManager.installshared.appModifyAvatar + "\(Int(NSDate().timeIntervalSince1970))"
            str = Invalidate.randomMD5(identifierString: str)
            data.append("\(username)".data(using: .utf8)!, withName: "account")
            data.append("\(pwd)".data(using: .utf8)!, withName: "passwd")
            data.append("\(str.lowercased())".data(using: .utf8)!, withName: "token")
            data.append("\(NetworkManager.installshared.macAddress())".data(using: .utf8)!, withName: "domain")
        }, to: NetworkManager.installshared.urlPrefix + NetworkManager.installshared.appModifyAvatar) {[weak self] (result) in
            hud.hide(animated: true)
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {[weak self] response in
                    if let value = response.result.value {
                        let json = JSON(value)
                        if let result = json["result"].int , result == 1000 {
                            if var mine = UserDefaults.standard.object(forKey: "mine") as? [String : Any] {
                                mine["img"] = json["img"].stringValue
                                UserDefaults.standard.set(mine, forKey: "mine")
                                UserDefaults.standard.synchronize()
                            }
                        }else{
                            if let msg = json["msg"].string , msg.characters.count > 0 {
                                Toast(text: msg).show()
                            }
                            self?.image = nil
                            self?.tableView.reloadData()
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                self?.image = nil
                self?.tableView.reloadData()
            }
        }
    }

}
