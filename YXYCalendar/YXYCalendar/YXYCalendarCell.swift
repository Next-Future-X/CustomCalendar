//
//  YXYCalendarCell.swift
//  YXYCalendar
//
//  Created by 袁向阳 on 16/11/30.
//  Copyright © 2016年 YXY.cn. All rights reserved.
//

import UIKit

class YXYCalendarCell: UICollectionViewCell {
    
    var currentDate:NSDate!
    var isCellSelectable: Bool?
    var indexPath : NSIndexPath!
    var selectDate : NSDate!
    
    var lblDay: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = .Center
        label.layer.backgroundColor = UIColor.whiteColor().CGColor
        label.text = "11"
        return label
    }()
    
    var sepatorLine : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
        view.hidden = true
        return view
    }()
    func selectedForLabelColor(color: UIColor) {
        self.lblDay.layer.cornerRadius = self.lblDay.frame.size.width/2
        self.lblDay.layer.backgroundColor = color.CGColor
        self.lblDay.textColor = UIColor.whiteColor()
    }
    
    func deSelectedForLabelColor(color: UIColor) {
        self.lblDay.layer.backgroundColor = UIColor.clearColor().CGColor
        self.lblDay.textColor = color
    }
    
    
    func setTodayCellColor(backgroundColor: UIColor) {
        
        self.lblDay.layer.cornerRadius = self.lblDay.frame.size.width/2
        self.lblDay.layer.backgroundColor = backgroundColor.CGColor
        self.lblDay.textColor  = UIColor.whiteColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(lblDay)
        contentView.addSubview(sepatorLine)
        lblDay.frame = contentView.bounds
        let sizeWidth = (lblDay.text! as NSString).sizeWithAttributes([NSFontAttributeName:lblDay.font])
        let sepX = (contentView.bounds.size.width - sizeWidth.width) * 0.5
        let sepY = contentView.bounds.size.height * 0.5 + 1
        sepatorLine.frame = CGRectMake(sepX, sepY, sizeWidth.width, 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
}
