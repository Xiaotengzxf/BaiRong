//
//  ProductView.swift
//  AntService
//
//  Created by 张晓飞 on 2017/7/4.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProductView: UIView {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblNum: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblAccount: UILabel!
    @IBOutlet weak var lblPlus: UILabel!
    @IBOutlet weak var lblSubtract: UILabel!
    var delegate : ProductViewDelegate?
    var number = 1
    var price : Double = 0
    var discount = 1.0
    var product : JSON!
    var remark : String = ""
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            var plusFrame = lblPlus.frame
            plusFrame.origin.x -= 5
            plusFrame.origin.y -= 5
            plusFrame.size.width += 10
            plusFrame.size.height += 10
            var subtractFrame = lblSubtract.frame
            subtractFrame.origin.x -= 5
            subtractFrame.origin.y -= 5
            subtractFrame.size.width += 10
            subtractFrame.size.height += 10
            if location.x < 50 {
                delegate?.deleteProduct(row: tag)
            }else if plusFrame.contains(location) {
                number += 1
                assignValue()
            }else if subtractFrame.contains(location) {
                if number > 1 {
                    number -= 1
                    assignValue()
                }
            }else {
                delegate?.showProductInfo(row: tag)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func assignValue() {
        lblName.text = product["name"].string
        lblNo.text = "商品编号：\(product["number"].string ?? "")"
        let price = product["price1"].string ?? ""
        self.price = Double(price)!
        lblType.text = "商品类型：\(product["typename"].string ?? "") 商品型号：\(product["model"].string ?? "") 单位：\(product["company"].string ?? "")"
        lblNum.attributedText = NSAttributedString(string: "\(number)", attributes: [NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue])
        lblPrice.attributedText = NSAttributedString(string: price, attributes: [NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue])
        lblDiscount.attributedText = NSAttributedString(string: "\(discount)", attributes: [NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue])
        lblAccount.attributedText = NSAttributedString(string: "\(discount * Double(price)! * Double(number))", attributes: [NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue])
    }
    
    

}

protocol ProductViewDelegate {
    func deleteProduct(row : Int)
    func showProductInfo(row : Int)
}
