//
//  ProductDetailTableViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/20.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProductDetailTableViewController: UITableViewController {
    
    let titles = ["商品名称：" , "商品编号：" , "商品类型：" , "商品型号：" , "商品单位：" , "单 价 一：" , "单 价 二：" , "单 价 三：" , "单 价 四：" , "商品描述："]
    var data : JSON!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDefaultValue(value : String?) -> String {
        if value == nil || value!.characters.count == 0 {
            return " "
        }
        return value ?? " "
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = titles[indexPath.row]
        }
        
        if let label = cell.viewWithTag(3) as? UILabel {
            switch indexPath.row {
            case 0:
                label.text = setDefaultValue(value: data["name"].string)
            case 1:
                label.text = setDefaultValue(value: data["number"].string)
            case 2:
                label.text = setDefaultValue(value: data["typename"].string)
            case 3:
                label.text = setDefaultValue(value: data["model"].string)
            case 4:
                label.text = setDefaultValue(value: data["company"].string)
            case 5:
                label.text = setDefaultValue(value: data["price1"].string)
            case 6:
                label.text = setDefaultValue(value: data["price2"].string)
            case 7:
                label.text = setDefaultValue(value: data["price3"].string)
            case 8:
                label.text = setDefaultValue(value: data["price4"].string)
            case 9:
                label.text = setDefaultValue(value: data["describe"].string)
            default:
                fatalError()
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
