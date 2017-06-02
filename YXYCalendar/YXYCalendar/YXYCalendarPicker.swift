//
//  YXYCalendarPicker.swift
//  YXYCalendar
//
//  Created by 袁向阳 on 16/11/30.
//  Copyright © 2016年 YXY.cn. All rights reserved.
//

import UIKit

@objc public protocol YXYCalendarPickerDelegate{
    optional    func yxyCalendarPicker(_: YXYCalendarPicker, didCancel error : NSError)
    optional    func yxyCalendarPicker(_: YXYCalendarPicker, didSelectDate date : NSDate)
    optional    func yxyCalendarPicker(_: YXYCalendarPicker, didSelectMultipleDate dates : [NSDate])
}

public class YXYCalendarPicker: UICollectionViewController {
    
    public var calendarDelegate : YXYCalendarPickerDelegate?
    public var multiSelectEnabled: Bool
    public var showsTodaysButton: Bool = true
    private var arrSelectedDates = [NSDate]()
    private var arrSelectedCell = [YXYCalendarCell]()
    // 选择的日期是否大于天数限制
    private var selectDatesGreaterThanRange = false
    // 天数限制
    private var daysRange = 7
    public var tintColor: UIColor
    // 置灰前面 (全部)
    private var setGrayFront = false
    // 置灰后面 (全部)
    private var setGrayBack = false
    // 距离最近的不可选日期 (前面)
    private var frontCannotDate : NSDate!
    // 距离最近的不可选日期 (后面)
    private var backCannotDate : NSDate!
    
    //public var maxCanSelectDate = 2    // 最多可选日期个数
    private var canSelectNow = true    // 是否可以继续添加日期
    private var newHoldDatesArray = [NSDate]()  // 2016-12-22      新   不可选日期
    
    public var dayDisabledTintColor: UIColor
    public var weekdayTintColor: UIColor
    public var weekendTintColor: UIColor
    public var todayTintColor: UIColor
    public var dateSelectionColor: UIColor
    public var monthTitleColor: UIColor
    
    // new options
    public var startDate: NSDate?
    public var hightlightsToday: Bool = true
    public var hideDaysFromOtherMonth: Bool = false
    public var barTintColor: UIColor
    
    public var backgroundImage: UIImage?
    public var backgroundColor: UIColor?
    
    private(set) public var startYear: Int
    private(set) public var endYear: Int
    
    private var layout : UICollectionViewFlowLayout!
    private var saveButton : UIButton = {
        let button = UIButton(type: UIButtonType.Custom)
        button.layer.cornerRadius = 17.5
        button.clipsToBounds = true
        button.alpha = 0.5
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setTitle("保存>", forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(16)
        button.backgroundColor = UIColor(red: 1/255.0, green: 190/255.0, blue: 148/255.0, alpha: 1.0)
        return button
    }()
    private var selectTimeLabel : UILabel!
    private var dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyy-MM-dd"
        return formatter
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // setup Navigationbar
        self.navigationController?.navigationBar.tintColor = self.tintColor
        self.navigationController?.navigationBar.barTintColor = self.barTintColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:self.tintColor]
        
        // setup collectionview
        self.collectionView?.delegate = self
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.showsVerticalScrollIndicator = false
        
        // Register cell classes
        self.collectionView!.registerClass(YXYCalendarCell.self, forCellWithReuseIdentifier: YXYCalendarCell.reuseIdentifier())
        self.collectionView!.registerClass(YXYCalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: YXYCalendarHeaderView.reuseIdentifier())
        self.collectionView?.registerClass(YXYCalendarFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: YXYCalendarFooterView.reuseIdentifier())
        self.collectionView?.registerClass(YXYCalendarSelectTimeHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: YXYCalendarSelectTimeHeaderView.reuseIdentifier())
        
        inititlizeBarButtons()
        
//        dispatch_async(dispatch_get_main_queue()) { () -> Void in
//            self.scrollToToday()
//        }
        
        if backgroundImage != nil {
            self.collectionView!.backgroundView =  UIImageView(image: backgroundImage)
        } else if backgroundColor != nil {
            self.collectionView?.backgroundColor = backgroundColor
        } else {
            self.collectionView?.backgroundColor = UIColor.whiteColor()
        }
        
        view.addSubview(saveButton)
        let saveButtonX = UIScreen.mainScreen().bounds.size.width - 95
        let saveButtonY = UIScreen.mainScreen().bounds.size.height - 55
        let saveButtonW : CGFloat = 70
        let saveButtonH : CGFloat = 35
        saveButton.frame = CGRectMake(saveButtonX, saveButtonY, saveButtonW, saveButtonH)
        saveButton.addTarget(self, action: #selector(YXYCalendarPicker.saveAction), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 测试不可选日期
        setConnotSelectDatesFunc()
    }
    
    @objc private func saveAction() {
        
        if arrSelectedDates.count < 1 {
            let alertView = UIAlertView(title: "请选择正确的时间", message: "", delegate: self, cancelButtonTitle: "确定")
            alertView.show()
            return
        }
        
        if arrSelectedDates.count > 1 {
            if selectDatesGreaterThanRange {
                let alertView = UIAlertView(title: "置顶日期不能超过7天", message: "", delegate: self, cancelButtonTitle: "确定")
                alertView.show()
                return
            }
        }
        
        onTouchDoneButton()
    }
    
    
    func inititlizeBarButtons(){
        
        
//        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(YXYCalendarPicker.onTouchCancelButton))
//        self.navigationItem.leftBarButtonItem = cancelButton
//        
//        var arrayBarButtons  = [UIBarButtonItem]()
//        
//        if multiSelectEnabled {
//            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(YXYCalendarPicker.onTouchDoneButton))
//            arrayBarButtons.append(doneButton)
//        }
//        
//        if showsTodaysButton {
//            let todayButton = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(YXYCalendarPicker.onTouchTodayButton))
//            arrayBarButtons.append(todayButton)
//            todayButton.tintColor = todayTintColor
//        }
//        
//        self.navigationItem.rightBarButtonItems = arrayBarButtons
        
        let cancelButton = UIButton(type: UIButtonType.Custom)
        cancelButton.setImage(UIImage(named: "calendar_close"), forState: UIControlState.Normal)
        cancelButton.frame = CGRectMake(0, 15, 40, 40)
        cancelButton.addTarget(self, action: #selector(YXYCalendarPicker.onTouchCancelButton), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public convenience init(){
        self.init(startYear: EPDefaults.startYear, endYear: EPDefaults.endYear, multiSelection: EPDefaults.multiSelection, selectedDates: nil);
    }
    
    public convenience init(startYear: Int, endYear: Int) {
        self.init(startYear:startYear, endYear:endYear, multiSelection: EPDefaults.multiSelection, selectedDates: nil)
    }
    
    public convenience init(multiSelection: Bool) {
        self.init(startYear: EPDefaults.startYear, endYear: EPDefaults.endYear, multiSelection: multiSelection, selectedDates: nil)
    }
    
    public convenience init(startYear: Int, endYear: Int, multiSelection: Bool) {
        self.init(startYear: EPDefaults.startYear, endYear: EPDefaults.endYear, multiSelection: multiSelection, selectedDates: nil)
    }
    
    public init(startYear: Int, endYear: Int, multiSelection: Bool, selectedDates: [NSDate]?) {
        
        self.startYear = startYear
        self.endYear = endYear
        
        self.multiSelectEnabled = multiSelection
        
        //Text color initializations
        self.tintColor = EPDefaults.tintColor
        self.barTintColor = EPDefaults.barTintColor
        self.dayDisabledTintColor = EPDefaults.dayDisabledTintColor
        self.weekdayTintColor = EPDefaults.weekdayTintColor
        self.weekendTintColor = EPDefaults.weekendTintColor
        self.dateSelectionColor = EPDefaults.dateSelectionColor
        self.monthTitleColor = EPDefaults.monthTitleColor
        self.todayTintColor = EPDefaults.todayTintColor
        
        //Layout creation
        layout = UICollectionViewFlowLayout()
        //layout.sectionHeadersPinToVisibleBounds = true  // If you want make a floating header enable this property(Avaialble after iOS9)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.headerReferenceSize = CGSizeMake(100, 100)
        layout.footerReferenceSize = CGSizeMake(100, 10)
        if let _ = selectedDates  {
            self.arrSelectedDates.appendContentsOf(selectedDates!)
        }
        super.init(collectionViewLayout: layout)
        // 测试不可选日期
        self.setConnotSelectDatesFunc()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UICollectionViewDataSource
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if startYear > endYear {
            return 0
        }
        
        let numberOfMonths = 12 * (endYear - startYear)
        return numberOfMonths
    }
    
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let startDate = NSDate(year: startYear, month: NSDate().month(), day: 1)
        let firstDayOfMonth = startDate.dateByAddingMonths(section)
        let addingPrefixDaysWithMonthDyas = ( firstDayOfMonth.numberOfDaysInMonth() + firstDayOfMonth.weekday() - NSCalendar.currentCalendar().firstWeekday )
        let addingSuffixDays = addingPrefixDaysWithMonthDyas%7
        var totalNumber  = addingPrefixDaysWithMonthDyas
        if addingSuffixDays != 0 {
            totalNumber = totalNumber + (7 - addingSuffixDays)
        }
        
        return totalNumber
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(YXYCalendarCell.reuseIdentifier(), forIndexPath: indexPath) as! YXYCalendarCell
        cell.lblDay.hidden = false
        cell.sepatorLine.hidden = true
        let calendarStartDate = NSDate(year:startYear, month: NSDate().month(), day: 1)
        let firstDayOfThisMonth = calendarStartDate.dateByAddingMonths(indexPath.section)
        let prefixDays = ( firstDayOfThisMonth.weekday() - NSCalendar.currentCalendar().firstWeekday)
        
        if indexPath.row >= prefixDays {
            cell.isCellSelectable = true
            let currentDate = firstDayOfThisMonth.dateByAddingDays(indexPath.row-prefixDays)
            let nextMonthFirstDay = firstDayOfThisMonth.dateByAddingDays(firstDayOfThisMonth.numberOfDaysInMonth()-1)
            
            cell.currentDate = currentDate
            cell.lblDay.text = "\(currentDate.day())"
            
            if arrSelectedDates.filter({ $0.isDateSameDay(currentDate)
            }).count > 0 && (firstDayOfThisMonth.month() == currentDate.month()) {
                
                cell.selectedForLabelColor(dateSelectionColor)
            }
            else{
                cell.deSelectedForLabelColor(weekdayTintColor)
                
                if cell.currentDate.isSaturday() || cell.currentDate.isSunday() {
                    cell.lblDay.textColor = weekendTintColor
                }
                if (currentDate > nextMonthFirstDay) {
                    cell.isCellSelectable = false
                    if hideDaysFromOtherMonth {
                        cell.lblDay.textColor = UIColor.clearColor()
                        cell.lblDay.text = ""
                        cell.lblDay.hidden = true
                    } else {
                        cell.lblDay.textColor = self.dayDisabledTintColor
                        cell.lblDay.hidden = false
                    }
                }
                if currentDate.isToday() && hightlightsToday {
                    cell.isCellSelectable = false
                    cell.setTodayCellColor(todayTintColor)
                }
                
                // 自定义设置不可选日期
                setCollectionItemStatus(cell, collectionView: collectionView, cellForItemAtIndexPath: indexPath)
                
                if startDate != nil {
                    if #available(iOS 8.0, *) {
                        if NSCalendar.currentCalendar().startOfDayForDate(cell.currentDate) < NSCalendar.currentCalendar().startOfDayForDate(startDate!) {
                            cell.isCellSelectable = false
                            cell.lblDay.textColor = self.dayDisabledTintColor
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                // 不超过天数限制
                if let start : NSDate = arrSelectedDates.first {
                    if (cell.currentDate - start >= daysRange) {
                        cell.isCellSelectable = false
                        cell.lblDay.textColor = self.dayDisabledTintColor
                    } else if (cell.currentDate - start <= -daysRange) {
                        cell.isCellSelectable = false
                        cell.lblDay.textColor = self.dayDisabledTintColor
                    }
                }
                
                // 置灰
                if setGrayFront {
                    if let start : NSDate = frontCannotDate {
                        if cell.currentDate < start && cell.isCellSelectable! {
                            cell.isCellSelectable = false
                            cell.lblDay.textColor = self.dayDisabledTintColor
                        }
                    }
                }
                if setGrayBack {
                    if let start : NSDate = backCannotDate {
                        if cell.currentDate > start && cell.isCellSelectable! {
                            cell.isCellSelectable = false
                            cell.lblDay.textColor = self.dayDisabledTintColor
                        }
                    }
                }
            }
        }
        else {
            cell.deSelectedForLabelColor(weekdayTintColor)
            cell.isCellSelectable = false
            let previousDay = firstDayOfThisMonth.dateByAddingDays(-( prefixDays - indexPath.row))
            cell.currentDate = previousDay
            cell.lblDay.text = "\(previousDay.day())"
            if hideDaysFromOtherMonth {
                cell.lblDay.textColor = UIColor.clearColor()
                cell.lblDay.text = ""
                //cell.lblDay.layer.backgroundColor = UIColor.whiteColor().CGColor
            } else {
                cell.lblDay.textColor = self.dayDisabledTintColor
            }
        }
        
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        
        let rect = UIScreen.mainScreen().bounds
        let screenWidth = rect.size.width - 7
        return CGSizeMake(screenWidth/7, screenWidth/7);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(5, 0, 5, 0); //top,left,bottom,right
    }
    
    override public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: YXYCalendarSelectTimeHeaderView.reuseIdentifier(), forIndexPath: indexPath) as! YXYCalendarSelectTimeHeaderView
                self.selectTimeLabel = header.selectTimeText
                let startDate = NSDate(year: startYear, month: NSDate().month(), day: 1)
                let firstDayOfMonth = startDate.dateByAddingMonths(indexPath.section)
                
                header.titleLabel.text = firstDayOfMonth.monthNameFull()
                header.titleLabel.textColor = monthTitleColor
                header.backgroundColor = UIColor.clearColor()
                
                return header;
            } else {
                let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: YXYCalendarHeaderView.reuseIdentifier(), forIndexPath: indexPath) as! YXYCalendarHeaderView
                
                let startDate = NSDate(year: startYear, month: NSDate().month(), day: 1)
                let firstDayOfMonth = startDate.dateByAddingMonths(indexPath.section)
                
                header.titleLabel.text = firstDayOfMonth.monthNameFull()
                header.titleLabel.textColor = monthTitleColor
                header.backgroundColor = UIColor.clearColor()
                
                return header;
            }
        } else if kind == UICollectionElementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: YXYCalendarFooterView.reuseIdentifier(), forIndexPath: indexPath) as! YXYCalendarFooterView
            footer.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1.0)
            return footer
        }
        
        return UICollectionReusableView()
    }
    
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! YXYCalendarCell
        if !multiSelectEnabled && cell.isCellSelectable! {
            calendarDelegate?.yxyCalendarPicker!(self, didSelectDate: cell.currentDate)
            cell.selectedForLabelColor(dateSelectionColor)
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        if cell.isCellSelectable! {
            cell.selectDate = cell.currentDate
            if canSelectNow {
                if arrSelectedDates.filter({ $0.isDateSameDay(cell.currentDate)
                }).count == 0 {
                    //cell.selectDate = cell.currentDate
                    arrSelectedDates.append(cell.currentDate)
                    arrSelectedCell.append(cell)
                    cell.selectedForLabelColor(dateSelectionColor)
                    
                    if cell.currentDate.isToday() {
                        cell.setTodayCellColor(dateSelectionColor)
                    }
                }
                else {
                    arrSelectedDates = arrSelectedDates.filter(){
                        return  !($0.isDateSameDay(cell.currentDate))
                    }
                    arrSelectedCell = arrSelectedCell.filter({
                        return  !($0.selectDate.isDateSameDay(cell.currentDate))
                    })
                    setCellDeSelected(cell)
                }
            } else {
                if arrSelectedDates.filter({ $0.isDateSameDay(cell.currentDate)
                }).count == 0 {
                    //cell.selectDate = cell.currentDate
                    cell.selectedForLabelColor(dateSelectionColor)
                    for selectCell in arrSelectedCell {
                        setCellDeSelected(selectCell)
                    }
                    arrSelectedDates.removeAll(keepCapacity: true)
                    arrSelectedCell.removeAll(keepCapacity: true)
                    arrSelectedDates.append(cell.currentDate)
                    arrSelectedCell.append(cell)
                    if cell.currentDate.isToday() {
                        cell.setTodayCellColor(dateSelectionColor)
                    }
                }
                else {
                    arrSelectedDates = arrSelectedDates.filter(){
                        return  !($0.isDateSameDay(cell.currentDate))
                    }
                    arrSelectedCell = arrSelectedCell.filter({
                        return  !($0.selectDate.isDateSameDay(cell.currentDate))
                    })
                    setCellDeSelected(cell)
                }
                collectionView.reloadData()
            }
            
            // 根据不可选日期和已选日期 置灰
            setCellCannotSelect(collectionView)
        }
        
        judgeStartTimeAndEndTime()
        
    }
    
    //MARK: Button Actions
    
    internal func onTouchCancelButton() {
        //TODO: Create a cancel delegate
        calendarDelegate?.yxyCalendarPicker!(self, didCancel: NSError(domain: "YXYCalendarPickerErrorDomain", code: 2, userInfo: [ NSLocalizedDescriptionKey: "User Canceled Selection"]))
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    internal func onTouchDoneButton() {
        //gathers all the selected dates and pass it to the delegate
        calendarDelegate?.yxyCalendarPicker!(self, didSelectMultipleDate: arrSelectedDates)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    internal func onTouchTodayButton() {
        scrollToToday()
    }
    
    
    public func scrollToToday () {
        let today = NSDate()
        scrollToMonthForDate(today)
    }
    
    public func scrollToMonthForDate (date: NSDate) {
        
        let month = date.month()
        let year = date.year()
        let section = ((year - startYear) * 12) + month
        let indexPath = NSIndexPath(forRow:1, inSection: section-1)
        
        self.collectionView?.scrollToIndexpathByShowingHeader(indexPath)
    }
    
    func setConnotSelectDatesFunc() {
        let calendarStartDate = NSDate(year:startYear, month: NSDate().month(), day: 1)
        let date1 = calendarStartDate.dateByAddingDays(18)
        let date2 = calendarStartDate.dateByAddingDays(19)
        let date3 = calendarStartDate.dateByAddingDays(30)
        let date4 = calendarStartDate.dateByAddingDays(35)
        let date5 = calendarStartDate.dateByAddingDays(36)
        let date6 = calendarStartDate.dateByAddingDays(23)
        let date7 = calendarStartDate.dateByAddingDays(24)
        
        newHoldDatesArray.append(date1)
        newHoldDatesArray.append(date2)
        newHoldDatesArray.append(date3)
        newHoldDatesArray.append(date4)
        newHoldDatesArray.append(date5)
        newHoldDatesArray.append(date6)
        newHoldDatesArray.append(date7)
        
        newHoldDatesArray = newHoldDatesArray.sort({ (first, last) -> Bool in
            return first < last
        })
    }
    
    // 定义不可选日期
    public func setCollectionItemStatus(cell: UICollectionViewCell, collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = cell as! YXYCalendarCell
        
        let calendarStartDate = NSDate(year:startYear, month: NSDate().month(), day: 1)
        let firstDayOfThisMonth = calendarStartDate.dateByAddingMonths(indexPath.section)
        let prefixDays = ( firstDayOfThisMonth.weekday() - NSCalendar.currentCalendar().firstWeekday)
        
        let currentDate = firstDayOfThisMonth.dateByAddingDays(indexPath.row-prefixDays)
        
        for date in self.newHoldDatesArray {
            if date == currentDate {
                if cell.lblDay.hidden == false {
                    cell.isCellSelectable = false
                    cell.lblDay.textColor = self.dayDisabledTintColor
                    cell.sepatorLine.hidden = false
                }
            }
        }
    }
    
    // 根据不可选日期和已选日期置灰
    private func setCellCannotSelect(collectionView: UICollectionView) {
        arrSelectedDates = arrSelectedDates.sort({ (first, last) -> Bool in
            return first < last
        })
        arrSelectedCell = arrSelectedCell.sort({ (first, last) -> Bool in
            return first.selectDate < last.selectDate
        })
        if let startDate : NSDate = arrSelectedDates.first {
            for cannotDate in self.newHoldDatesArray {
                if (startDate > cannotDate) && (startDate - cannotDate <= daysRange) {
                    setGrayFront = true
                    frontCannotDate = cannotDate
                }
            }
            for cannotDate in self.newHoldDatesArray {
                if (cannotDate > startDate) && (cannotDate - startDate <= daysRange) {
                    setGrayBack = true
                    backCannotDate = cannotDate
                    break
                }
            }
        } else {
            setGrayFront = false
            setGrayBack = false
            frontCannotDate = nil
            backCannotDate = nil
        }
        collectionView.reloadData()
    }
    
    // 判断是开始时间还是结束时间
    private func judgeStartTimeAndEndTime() {
        if arrSelectedDates.count > 1 {
            self.canSelectNow = false
            let startDate = arrSelectedDates.first ?? NSDate()
            let endDate = arrSelectedDates.last ?? NSDate()
            let startTimeText = dateFormatter.stringFromDate(startDate)
            let endTimeText = dateFormatter.stringFromDate(endDate)
            selectTimeLabel.text = startTimeText + " / " + endTimeText
            selectTimeLabel.textColor = UIColor(red: 64/255.0, green: 176/255.0, blue: 153/255.0, alpha: 1.0)
            
            let days = endDate.timeIntervalSinceDate(startDate) / (24 * 60 * 60)
            selectDatesGreaterThanRange = days >= Double(daysRange) ? true : false
            if selectDatesGreaterThanRange {
                let alertView = UIAlertView(title: "推广日期不能超过\(daysRange)天", message: "", delegate: self, cancelButtonTitle: "确定")
                alertView.show()
            }
            
        } else if arrSelectedDates.count > 0 {
            let startTimeText = dateFormatter.stringFromDate(arrSelectedDates.first ?? NSDate())
            selectTimeLabel.text = startTimeText + " / " + "结束"
            self.canSelectNow = true
        } else {
            selectTimeLabel.text = "开始/结束"
            selectTimeLabel.textColor = UIColor(red: 206/255.0, green: 206/255.0, blue: 206/255.0, alpha: 1.0)
            self.canSelectNow = true
        }
    }
    
    // 将选中的cell置为没有选中状态
    private func setCellDeSelected(cell:YXYCalendarCell) {
        if cell.currentDate.isSaturday() || cell.currentDate.isSunday() {
            cell.deSelectedForLabelColor(weekendTintColor)
        }
        else {
            cell.deSelectedForLabelColor(weekdayTintColor)
        }
        if cell.currentDate.isToday() && hightlightsToday{
            cell.setTodayCellColor(todayTintColor)
        }
    }
}
