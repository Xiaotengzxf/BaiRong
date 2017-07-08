//
//  CommercialFlowTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/7/3.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import SKPhotoBrowser

class CommercialFlowTableViewController: UITableViewController, WaitWorkTableViewCellDelegate {
    
    var data : JSON!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data["dealRecord"].arrayValue.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! WaitWorkTableViewCell
        cell.delegate = self
        if let file = data["dealRecord" , indexPath.row , "file"].string , file.characters.count > 0 {
            cell.btnFile.isHidden = false
            cell.lcBottom.constant = 10
            cell.file = file
        }else{
            cell.btnFile.isHidden = true
            cell.lcBottom.constant = -25
            cell.file = ""
        }
        let attributeString = NSAttributedString(string: "附件信息", attributes: [NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue , NSForegroundColorAttributeName : UIColor.blue , NSFontAttributeName : UIFont.systemFont(ofSize: 15)])
        cell.btnFile.setAttributedTitle(attributeString, for: .normal)
        if let imageView = cell.viewWithTag(2) as? UIImageView {
            let image = UIImage(named: "bg_diggle_white")?.resizableImage(withCapInsets: UIEdgeInsetsMake(40, 30, 22, 20))
            imageView.image = image
        }
        if let label = cell.viewWithTag(3) as? UILabel {
            label.text = data["dealRecord" , indexPath.row , "r_from_nickname"].string
        }
        if let label = cell.viewWithTag(4) as? UILabel {
            let type = data["dealRecord" , indexPath.row , "result"].string
            label.text = type == "4" ? "" : data["dealRecord" , indexPath.row , "r_to_nickname"].string
        }
        if let label = cell.viewWithTag(5) as? UILabel {
            label.text = data["dealRecord" , indexPath.row , "opinion"].string
        }
        if let label = cell.viewWithTag(6) as? UILabel {
            label.text = data["dealRecord" , indexPath.row , "time"].string
        }
        if let label = cell.viewWithTag(7) as? UILabel {
            // 0不通过1通过2销毁3新增4完成5委托
            label.text = data["dealRecord" , indexPath.row , "result"].string
            
        }
        if let imageView = cell.viewWithTag(10) as? UIImageView {
            let count = data["dealRecord"].array?.count ?? 0
            imageView.isHidden = indexPath.row == count - 1
        }
        if let imageView = cell.viewWithTag(11) as? UIImageView {
            imageView.isHidden = indexPath.row == 0
        }
        if let label = cell.viewWithTag(12) as? UILabel {
            label.text = data["dealRecord" , indexPath.row , "rate"].string
        }
        return cell

    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func showFile(file: String) {
        if file.characters.count > 0 && file.hasPrefix("http://") {
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImageURL(file)
            photo.shouldCachePhotoURLImage = false
            images.append(photo)
            SKPhotoBrowserOptions.displayAction = false
            let browser = SKPhotoBrowser(photos: images)
            present(browser, animated: true, completion: {})
        }
    }


}
