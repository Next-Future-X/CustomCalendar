//
//  ViewController.swift
//  YXYCalendar
//
//  Created by 袁向阳 on 16/11/30.
//  Copyright © 2016年 YXY.cn. All rights reserved.
//

import UIKit

class ViewController: UIViewController , YXYCalendarPickerDelegate {

    private var showCalendarButton : UIButton = {
        let button = UIButton(type: UIButtonType.Custom)
        button.setTitle("点击这里打开日历", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(13)
        button.layer.borderColor = UIColor.redColor().CGColor
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor.whiteColor()
        return button
    }()
    
    private var txtViewDetail : UITextView = {
        let label = UITextView()
        label.textColor = UIColor.blackColor()
        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(showCalendarButton)
        let buttonW : CGFloat = 200
        let buttonH : CGFloat = 50
        let buttonX = (UIScreen.mainScreen().bounds.size.width - buttonW) * 0.5
        let buttonY = (UIScreen.mainScreen().bounds.size.height - buttonH) * 0.5
        showCalendarButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH)
        
        view.addSubview(txtViewDetail)
        let labelW : CGFloat = 300
        let labelH : CGFloat = 200
        let labelX = (UIScreen.mainScreen().bounds.size.width - labelW) * 0.5
        let labelY : CGFloat = 400
        txtViewDetail.frame = CGRectMake(labelX, labelY, labelW, labelH)
        showCalendarButton.addTarget(self, action: #selector(ViewController.showCalendarAction), forControlEvents: UIControlEvents.TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func showCalendarAction() {
        let startYear = NSDate().year()
        let endYear = startYear + 1
        let calendarPicker = YXYCalendarPicker(startYear: startYear, endYear: endYear, multiSelection: true, selectedDates: [])
        
        calendarPicker.calendarDelegate = self
        calendarPicker.startDate = NSDate()
        calendarPicker.hightlightsToday = true
        calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = true
        calendarPicker.tintColor = UIColor.orangeColor()
        calendarPicker.dayDisabledTintColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
        calendarPicker.title = "Date Picker"
        
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func yxyCalendarPicker(_: YXYCalendarPicker, didCancel error : NSError) {
        txtViewDetail.text = "User cancelled selection"
        
    }
    func yxyCalendarPicker(_: YXYCalendarPicker, didSelectDate date : NSDate) {
        txtViewDetail.text = "User selected date: \n\(date)"
        
    }
    func yxyCalendarPicker(_: YXYCalendarPicker, didSelectMultipleDate dates : [NSDate]) {
        txtViewDetail.text = "User selected dates: \n\(dates)"
    }
    
}

