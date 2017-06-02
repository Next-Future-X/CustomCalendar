//
//  YXYCalendarFooterView.swift
//  YXYCalendar
//
//  Created by 袁向阳 on 16/11/30.
//  Copyright © 2016年 YXY.cn. All rights reserved.
//

import UIKit

class YXYCalendarFooterView: UICollectionReusableView {
    
    private var backGrayView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1.0)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backGrayView)
        backGrayView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
}
