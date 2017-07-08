//
//  DialogViewController.swift
//  AntService
//
//  Created by 张晓飞 on 2017/3/21.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import CVCalendar
import Toaster
import SwiftyJSON

class DialogViewController: UIViewController , CVCalendarViewDelegate , CVCalendarMenuViewDelegate , CVCalendarViewAppearanceDelegate {

    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var lblMonth: UILabel!
    var data: [JSON] = []
    var currentCalendar: Calendar?
    var selectedDay:DayView!
    var currentMonth = 0
    var start: TimeInterval = 0
    var end : TimeInterval = 0
    var personId = ""
    var bSwitch = false
    
    override func awakeFromNib() {
        let timeZoneBias = 480 // (UTC+08:00)
        currentCalendar = Calendar.init(identifier: .gregorian)
        if let timeZone = TimeZone.init(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if personId.characters.count == 0 {
            let userinfo = UserDefaults.standard.object(forKey: "mine") as? [String : Any]
            personId = userinfo?["id"] as? String ?? ""
        }
        
        if let currentCalendar = currentCalendar {
            let date = CVDate(date: Date(), calendar: currentCalendar)
            lblMonth.text = date.globalDescription
            let d = CVDate(day: 0, month: date.month, week: 0, year: date.year, calendar: currentCalendar)
            let start = d.convertedDate(calendar: currentCalendar)
            currentMonth = d.month
            self.start = startOfCurrentMonth(date: start!)!
            self.end = endOfCurrentMonth(date: start!)!
            loadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(DialogViewController.handleNotification(notificaiton:)), name: Notification.Name("dialog\(personId)"), object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleNotification(notificaiton : Notification) {
        if let tag = notificaiton.object as? Int {
            if tag == 1 {
                self.loadData()
            }
        }
    }
    
    func loadData() {
        
        let hud = self.showHUD(text: "努力加载中...")
        
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.appWorkLog, params: ["start" : start , "end" : end , "personId" : personId]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.data.removeAll()
                    if let array = object["data"].array {
                        self?.data += array
                    }
                    self?.calendarView.contentController.refreshPresentedMonth()
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                Toast(text: "网络异常，请稍后重试").show()
                
            }
        }
    }
    
    @IBAction func next(_ sender: Any) {
        calendarView.loadNextView()
    }

    @IBAction func before(_ sender: Any) {
        calendarView.loadPreviousView()
    }
    
    @IBAction func look(_ sender: Any) {
        self.performSegue(withIdentifier: "dialogdep", sender: self)
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? DialogNewViewController {
            controller.personId = personId
            if data.count > 0 {
                for json in data {
                    if let start = json["start"].string {
                        let date = Date(timeIntervalSince1970: Double(start)!)
                        let calendar = NSCalendar.current
                        let component = calendar.dateComponents([.year , .month , .day], from: date)
                        if component.year! == selectedDay.date.year && component.month! == selectedDay.date.month && component.day! == selectedDay.date.day {
                            if selectedDay.date.month == currentMonth {
                                controller.json = json
                                return
                            }
                            
                        }
                    }
                }
            }
            let date = selectedDay.date.convertedDate(calendar: currentCalendar!)
            controller.date = date
        }
    }
    
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .short
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return UIColor.white
    }
    
    func dayOfWeekFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        if bSwitch {
            bSwitch = false
        }else{
            lblMonth.text = date.globalDescription
            let d = CVDate(day: 0, month: date.month, week: 0, year: date.year, calendar: currentCalendar!)
            currentMonth = d.month
            let start = d.convertedDate(calendar: currentCalendar!)
            self.start = startOfCurrentMonth(date: start!)!
            self.end = endOfCurrentMonth(date: start!)!
            loadData()
        }
        
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        bSwitch = true
        if dayView.isCurrentDay {
            selectedDay = dayView
            self.performSegue(withIdentifier: "dialognew", sender: self)
        }else{
            if dayView.date.convertedDate(calendar: currentCalendar!)?.compare(Date()) == .orderedDescending {
                
            }else{
                selectedDay = dayView
                self.performSegue(withIdentifier: "dialognew", sender: self)
            }
        }
        
    }
    
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        if present == .present {
            return UIColor.blue
        }else{
            return UIColor.black
        }
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        if present == .present {
            return UIColor.clear
        }else{
            return UIColor.clear
        }
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        let imageView = UIImageView(image: UIImage(named: "ic_bg_course_optional"))
        imageView.center = dayView.center
        if dayView.isCurrentDay {
        }else{
            if checkoutSameDay(dayView: dayView) {
                imageView.image = UIImage(named: "ic_bg_course_not_optional")
            }else if checkoutCommTalg(dayView: dayView){
                imageView.image = UIImage(named: "ic_record_smiling_face")
            }else{
                //ic_record_smiling_face
            }
        }
        return imageView
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if dayView.isCurrentDay {
            return true
        }else{
            if checkoutSameDay(dayView: dayView) {
                return true
            }else if checkoutCommTalg(dayView: dayView){
                return true
            }else{
                return false
            }
        }
        
    }
    
    // 判断是否为同一天
    func checkoutSameDay(dayView : DayView) -> Bool {
        if data.count > 0 {
            for json in data {
                if let start = json["start"].string {
                    let date = Date(timeIntervalSince1970: Double(start)!)
                    let calendar = NSCalendar.current
                    let component = calendar.dateComponents([.year , .month , .day], from: date)
                    print("\(component.year!)-\(component.month!)-\(component.day!) \(dayView.date.year)-\(dayView.date.month)-\(dayView.date.day)")
                    if component.year! == dayView.date.year && component.month! == dayView.date.month && component.day! == dayView.date.day {
                        if dayView.date.month == currentMonth {
                            if let commTalg = json["commTalg"].string {
                                let comm = Int(commTalg)
                                if comm == 0 {
                                    return true
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        return false
    }
    
    func checkoutCommTalg(dayView : DayView) -> Bool {
        if data.count > 0 {
            for json in data {
                if let start = json["start"].string {
                    let date = Date(timeIntervalSince1970: Double(start)!)
                    let calendar = NSCalendar.current
                    let component = calendar.dateComponents([.year , .month , .day], from: date)
                    print("\(component.year!)-\(component.month!)-\(component.day!) \(dayView.date.year)-\(dayView.date.month)-\(dayView.date.day)")
                    if component.year! == dayView.date.year && component.month! == dayView.date.month && component.day! == dayView.date.day {
                        if dayView.date.month == currentMonth {
                            if let commTalg = json["commTalg"].string {
                                let comm = Int(commTalg) ?? 0
                                if comm > 0 {
                                    return true
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        return false
    }
    
    
//    func selectionAnimation() -> ((DayView, @escaping ((Bool) -> ())) -> ()) {
//        
//    }
//    
//    func deselectionAnimation() -> ((DayView, @escaping ((Bool) -> ())) -> ()) {
//        
//    }
    
    // 本月开始日期
    func startOfCurrentMonth(date : Date) -> TimeInterval? {
        let components = currentCalendar?.dateComponents([.year, .month], from: date)
        let startOfMonth = currentCalendar?.date(from: components!)
        return startOfMonth?.timeIntervalSince1970
    }
    
    //本月结束日期
    func endOfCurrentMonth(date : Date) -> TimeInterval? {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        let endOfMonth =  currentCalendar?.date(byAdding: components, to: date)
        return endOfMonth?.timeIntervalSince1970
    }

}
