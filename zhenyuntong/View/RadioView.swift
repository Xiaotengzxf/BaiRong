//
//  RadioView.swift
//  BaiRong
//
//  Created by 张晓飞 on 2017/7/30.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit

class RadioView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var tableData : [String] = []
    var tableView : UITableView?
    var delegate : RadioViewDelegate?
    var type = 0
    var bTouch = false

    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.backgroundColor = UIColor.white
        tableView?.layer.cornerRadius = 5
        tableView?.clipsToBounds = true
        self.addSubview(tableView!)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(40)-[tableView]-(40)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["tableView" : tableView!]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[tableView(height)]", options: .directionLeadingToTrailing, metrics: ["height" : min(300, tableData.count * 44)], views: ["tableView" : tableView!]))
        self.addConstraint(NSLayoutConstraint(item: self.tableView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if bTouch {
            return
        }
        for touch in touches {
            if touch.location(in: tableView!).x < 0 || touch.location(in: tableView!).y < 0{
                continue
            }else{
                delegate?.removeRadioView()
            }
        }
    }
    
    // mark: - Table view datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = tableData[indexPath.row]
        return cell!
    }
    
    // mark: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.getSelected(title: tableData[indexPath.row], row: indexPath.row, type: type)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

@objc protocol RadioViewDelegate {
    func getSelected(title : String, row : Int, type : Int)
     func removeRadioView()
}
