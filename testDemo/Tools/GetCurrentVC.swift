//
//  GetCurrentVC.swift
//  SmartAED
//
//  Created by 高诚 on 2018/1/4.
//  Copyright © 2018年 高诚. All rights reserved.
//

import Foundation
import UIKit
struct getCurrentVC {
    func getCurrentViewController1() -> UIViewController? {
        
        // 1.声明UIViewController类型的指针
        var viewController: UIViewController?
        
        // 2.找到当前显示的UIWindow
        let window: UIWindow? = self.getCurrentWindow()
        
        // 3.获得当前显示的UIWindow展示在最上面的view
        let frontView = window?.subviews.first
        
        // 4.找到这个view的nextResponder
        let nextResponder = frontView?.next
        
        if nextResponder?.isKind(of: UIViewController.classForCoder()) == true {
            
            viewController = nextResponder as? UIViewController
        }
        else {
            
            viewController = window?.rootViewController
        }
        
        return viewController
    }
    
    // 找到当前显示的window
    func getCurrentWindow() -> UIWindow? {
        
        // 找到当前显示的UIWindow
        var window: UIWindow? = UIApplication.shared.keyWindow
        /**
         7          window有一个属性：windowLevel
         8          当 windowLevel == UIWindowLevelNormal 的时候，表示这个window是当前屏幕正在显示的window
         9          */
        if window?.windowLevel != UIWindowLevelNormal {
            
            for tempWindow in UIApplication.shared.windows {
                
                if tempWindow.windowLevel == UIWindowLevelNormal {
                    
                    window = tempWindow
                    break
                }
            }
        }
        
        return window
    }
}
