//
//  CallTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/25.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import MJRefresh
import Toaster
import SwiftyJSON
import DZNEmptyDataSet
import AVFoundation

class CallTableViewController: UITableViewController ,DZNEmptyDataSetDelegate , DZNEmptyDataSetSource , IQDropDownTextFieldDelegate , CallTableViewCellDelegate , AVAudioPlayerDelegate {
    
    @IBOutlet weak var idtfStart: IQDropDownTextField!
    @IBOutlet weak var idtfEnd: IQDropDownTextField!
    var stime = ""
    var data : [JSON] = []
    var nShowEmpty = 2 // 1 无数据 2 加载中 3 无网络
    //var row = 0
    var etime = ""
    var bSearch = false
    var bCust = false
    var mobile = ""
    var player : AVAudioPlayer? // 播放器
    var isPlaying = false
    var nTag = -1
    var bState = 0   // 1 下载音频路径 2 播放 3 暂停
    var audio : [Int : Data] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        if bSearch {
            self.navigationItem.rightBarButtonItem = nil
            idtfStart.dropDownMode = .datePicker
            idtfEnd.dropDownMode = .datePicker
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            idtfStart.dateFormatter = formatter
            idtfEnd.dateFormatter = formatter
            nShowEmpty = 0
        }else {
            tableView.tableHeaderView = nil
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let time = formatter.string(from: date)
            stime = time + " 00:00:00"
            etime = time + " 23:59:59"
            loadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.player != nil {
            if self.player!.isPlaying || isPlaying {
                self.player?.pause()
                self.player?.delegate = nil
                self.player = nil
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: bCust ? NetworkManager.installshared.appCustCallRecords :  NetworkManager.installshared.appCallRecords, params:bCust ? ["stime" : stime , "etime" : etime , "mobile" : mobile] : ["stime" : stime , "etime" : etime]){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int{
                    if result == 1000 {
                        self?.data.removeAll()
                        if let arr = object["data"].array {
                            self!.data += arr
                        }
                        if self?.data.count == 0 {
                            self?.nShowEmpty = 3
                        }
                        self?.tableView.reloadData()
                    }else if result == 1004 {
                        self?.nShowEmpty = 3
                        self?.tableView.reloadData()
                    }else{
                        if let message = object["msg"].string , message.characters.count > 0 {
                            Toast(text: message).show()
                        }
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
            }
        }
    }
    
    @IBAction func search(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "call") as? CallTableViewController {
            controller.bSearch = true
            controller.hidesBottomBarWhenPushed = true
            controller.title = "搜索通话记录"
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    @IBAction func doSearch(_ sender: Any) {
        idtfStart.resignFirstResponder()
        idtfEnd.resignFirstResponder()
        stime = idtfStart.selectedItem ?? ""
        etime = idtfEnd.selectedItem ?? ""
        if stime.characters.count == 0 {
            Toast(text: "请选择开始时间").show()
            return
        }
        if etime.characters.count == 0 {
            Toast(text: "请选择结束时间").show()
            return
        }
        if stime > etime {
            Toast(text: "开始时间不能晚于结束时间").show()
            return
        }
        stime += " 00:00:00"
        etime += " 23:59:59"
        loadData()
    }
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : Any] {
                    if let message = userInfo["message"] as? String {
                        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "order") as? OrderTableViewController {
                            controller.title = "搜索结果"
                            controller.search = message
                            controller.bSearch = true
                            controller.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CallTableViewCell
        cell.delegate = self
        cell.tag = indexPath.row
        cell.bState = bState
        cell.btnCall.isHidden = !(data[indexPath.row]["disposition"].stringValue == "ANSWERED")
        cell.lcBtnWidth.constant = (data[indexPath.row]["disposition"].stringValue == "ANSWERED") ? 40 : 1
        cell.lbl1.text = "主叫：\(data[indexPath.row]["src"].string ?? "") 被叫：\(data[indexPath.row]["dst"].string ?? "")"
        cell.lbl2.text = "通话时长：\(data[indexPath.row]["billsec"].stringValue)"
        cell.lbl3.text = "\(data[indexPath.row]["disposition"].stringValue == "ANSWERED" ? "已接听" : "未接听")"
        cell.lbl3.textColor = (data[indexPath.row]["disposition"].stringValue == "ANSWERED") ?  (UIColor(red: 30/255.0, green: 160/255.0, blue: 20/255.0, alpha: 1)) : (UIColor.red)
        cell.lbl4.text = "通话时间：\(data[indexPath.row]["calldate"].stringValue)"
        if indexPath.row == nTag {
            if cell.bState == 0 {
                cell.btnCall.setImage(UIImage(named: "chat_audio_pause"), for: .normal)
                cell.ivLoading.layer.removeAllAnimations()
                cell.ivLoading.isHidden = true
            }else if cell.bState == 1 {
                cell.btnCall.setImage(UIImage(named: "chat_audio_pause"), for: .normal)
                cell.ivLoading.isHidden = false
                cell.rotate()
            }else if cell.bState == 2 {
                cell.ivLoading.layer.removeAllAnimations()
                cell.ivLoading.isHidden = true
                cell.changeImage()
            }else if cell.bState == 3 {
                cell.btnCall.setImage(UIImage(named: "chat_audio_pause"), for: .normal)
                cell.ivLoading.layer.removeAllAnimations()
                cell.ivLoading.isHidden = true
            }
        }else{
            cell.btnCall.setImage(UIImage(named: "chat_audio_pause"), for: .normal)
            cell.ivLoading.isHidden = true
            cell.ivLoading.layer.removeAllAnimations()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == idtfStart {
            if textField.tag == 0 {
                let date = Date().addingTimeInterval(-60 * 60 * 24)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                idtfStart.selectedItem = formatter.string(from: date)
                textField.tag = 1
            }
            
        }else if textField == idtfEnd {
            if textField.tag == 0 {
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                idtfEnd.selectedItem = formatter.string(from: date)
                textField.tag = 1
            }
        }
    }
    
    // MARK: - 空数据
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        var name = ""
        if nShowEmpty == 1 {
            name = "empty"
        }else if nShowEmpty == 2 {
            name = "jiazaizhong"
        }else if nShowEmpty == 3 {
            name = "empty"
        }
        return UIImage(named: name)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var message = ""
        if nShowEmpty == 1 {
            message = "世界上最遥远的距离就是没有WIFI...\n请点击屏幕重新加载！"
        }else if nShowEmpty == 2 {
            message = "加载是件正经事儿，走心加载中..."
        }else if nShowEmpty == 3 {
            message = "空空如也，啥子都没有噢！"
        }
        let att = NSMutableAttributedString(string: message)
        att.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, att.length))
        return att
    }
    
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty == 2
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        if nShowEmpty > 0 && nShowEmpty != 2 {
            nShowEmpty = 2
            tableView.reloadData()
            loadData()
        }
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty > 0
    }
    
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0))
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0.0, 0.0, 1.0))
        animation.duration = 0.5
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
    
    
    func playMedia(tag: Int) {
        if nTag >= 0 {
            if  tag != nTag {
                if isPlaying {
                    isPlaying = false
                    self.player?.pause()
                }
                self.bState = 0
                self.player = nil
                self.tableView.reloadData()
            }
        }
        nTag = tag
        if self.player != nil {
            if isPlaying {
                self.player?.pause()
                isPlaying = false
                self.bState = 3
                self.tableView.reloadData()
            }else {
                self.player?.play()
                isPlaying = true
                self.bState = 2
                self.tableView.reloadData()
            }
            return
        }
        if let data = audio[nTag] {
            do{
                self.player = try AVAudioPlayer(data: data)
                self.player?.delegate = self
                self.player?.prepareToPlay()
                self.player?.play()
                self.isPlaying = true
                self.bState = 2
                self.tableView.reloadData()
            }catch{
                Toast(text: "音频播放失败").show()
            }
        }else{
            bState = 1
            self.tableView.reloadData()
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appDownloadCF, params: ["userfield" : data[tag]["userfield"].string ?? ""] ){
                [weak self] (json , error) in
                if let rows = self!.tableView.indexPathsForVisibleRows {
                    for index in rows {
                        if index.row == self!.nTag {
                            if let object = json {
                                if let result = object["result"].int{
                                    if result == 1000 {
                                        if let url = object["data" , "url"].string {
                                            NetworkManager.installshared.download(url: url, callback: {[weak self]  (data, error) in
                                                if data != nil {
                                                    self?.audio[self!.nTag] = data!
                                                    if self?.player == nil {
                                                        do{
                                                            self?.player = try AVAudioPlayer(data: data!)
                                                            self?.player?.delegate = self
                                                            self?.player?.prepareToPlay()
                                                            self?.player?.play()
                                                            
                                                            self?.isPlaying = true
                                                            self?.bState = 2
                                                            self?.tableView.reloadData()
                                                        }catch{
                                                            Toast(text: "音频播放失败").show()
                                                        }
                                                    }
                                                }
                                            })
                                            
                                        }
                                    }else{
                                        if let message = object["msg"].string , message.characters.count > 0 {
                                            Toast(text: message).show()
                                        }
                                    }
                                }
                            }else{
                                Toast(text: "网络异常，请稍后重试").show()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        nTag = -1
        bState = 0
        self.player?.delegate = nil
        self.player = nil
        self.isPlaying = false
        self.tableView.reloadData()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        nTag = -1
        bState = 0
        self.player?.delegate = nil
        self.player = nil
        self.isPlaying = false
        self.tableView.reloadData()
    }
    
    
}
