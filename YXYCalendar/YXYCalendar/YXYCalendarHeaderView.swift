//
//  YXYCalendarHeaderView.swift
//  YXYCalendar
//
//  Created by 袁向阳 on 16/11/30.
//  Copyright © 2016年 YXY.cn. All rights reserved.
//

import UIKit

class YXYCalendarHeaderView: UICollectionReusableView {
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.text = "2016 年 11 月"
        label.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(12)
        return label
    }()
    
    var sepatorLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0)
        return view
    }()
    
    var sepatorLineView2 : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0)
        return view
    }()
    
    var lblSixth: UILabel!
    var lblSeventh: UILabel!
    var lblArray = [UILabel]()
    let weeksDayList = ["日","一","二","三","四","五","六"] //NSCalendar.currentCalendar().shortWeekdaySymbols
    
    func creatWeekDaysLabel() -> UILabel {
        
        let label = UILabel()
        label.text = "日"
        label.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(14)
        return label

    }
    
    func setUpSubviews() {
        
        for i in 0..<weeksDayList.count {
            let label = creatWeekDaysLabel()
            lblArray.append(label)
            addSubview(label)
            label.text = weeksDayList[i]
            if i == weeksDayList.count - 1 {
                lblSixth = label
            } else if i == weeksDayList.count {
                lblSeventh = label
            }
        }
        
        let labelW = UIScreen.mainScreen().bounds.size.width / 7
        let labelH = (lblSixth.text! as NSString).sizeWithAttributes([NSFontAttributeName:lblSixth.font]).height
        var labelX : CGFloat = 10
        let labelY : CGFloat = 40
        var index : CGFloat = 0
        for label in lblArray {
            labelX = (index % 7) * labelW
            label.frame = CGRectMake(labelX, labelY, labelW, labelH)
            if index == 0 || index == 6 {
                label.textColor = UIColor(red: 64/255.0, green: 176/255.0, blue: 153/255.0, alpha: 1.0)
            }
            index += 1
        }
        
        addSubview(titleLabel)
        addSubview(sepatorLineView)
        //addSubview(sepatorLineView2)
        let kScreenWidth = UIScreen.mainScreen().bounds.size.width
        let weekStrSize = (lblSixth.text ?? "日" as NSString).sizeWithAttributes([NSFontAttributeName:lblSixth.font])
        sepatorLineView.frame = CGRectMake(0, weekStrSize.height + 50, kScreenWidth, 1)
        let titleStrSize = (titleLabel.text! as NSString).sizeWithAttributes([NSFontAttributeName:titleLabel.font])
        titleLabel.frame = CGRectMake(0, weekStrSize.height + 65 + 1, kScreenWidth, titleStrSize.height)
        //sepatorLineView2.frame = CGRectMake(0, weekStrSize.height + titleStrSize.height + 40 + 1, kScreenWidth, 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
}
