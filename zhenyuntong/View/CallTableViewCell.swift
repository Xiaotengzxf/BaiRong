//
//  CallTableViewCell.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/29.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class CallTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var ivLoading: UIImageView!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    var delegate : CallTableViewCellDelegate?
    var flag = 0
    var bState = 0   // 1 下载音频路径 2 播放 3 暂停
    @IBOutlet weak var lcBtnWidth: NSLayoutConstraint!
   

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func call(_ sender : Any)  {
        delegate?.playMedia(tag: tag)
    }
    
    deinit {
        ivLoading.layer.removeAllAnimations()
    }
    
    func rotate() {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0))
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0))
        animation.duration = 0.5
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        ivLoading.layer.add(animation, forKey: "1")
    }
    
    func changeImage() {
        btnCall.setImage(UIImage(named: "chat_audio_from_\(flag % 3 + 1)"), for: .normal)
        flag += 1
        if bState == 2  {
            self.perform(#selector(CallTableViewCell.changeImage), with: nil, afterDelay: 0.4)
        }
    }
    
}

protocol CallTableViewCellDelegate {
    func playMedia(tag : Int)
}
