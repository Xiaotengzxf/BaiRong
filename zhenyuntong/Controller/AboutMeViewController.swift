//
//  AboutMeViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/7.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit

class AboutMeViewController: UIViewController {

    @IBOutlet weak var lblCompanyInfo: UILabel!
    @IBOutlet weak var companyIntroLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        companyIntroLabel.text = "深圳长鑫多年来专注于企业呼叫中心系统和云通信应用平台的研发与设计，致力为企业提供更智能、更便利、更高效的一站式信息化解决方案。公司拥有多项软件著作权，是“双软认证企业”和“国家高新企业”，并具有增值电信业务经营许可证。目前公司接近百人，其中60%以上从事核心技术研发。长鑫致力于为每一个终端客户和代理商提供至臻至善的产品和服务体系，目前在全国四十多个主要城市有代理商或合作伙伴，共同打造呼叫中心行业生态圈。至2016年初在国内已拥有近5200家优质客户，累计达20万坐席。"
        lblCompanyInfo.text = "深圳市长鑫盛通科技有限公司\n电话：400-0088-005\n地址：广东省深圳市福田区车公庙泰然工贸园210栋东座5C\n邮编：518000\n邮箱：liutc@uncallcc.com"
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
