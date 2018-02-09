//
//  ScanView.swift
//  SmartAED
//
//  Created by 高诚 on 2018/1/5.
//  Copyright © 2018年 高诚. All rights reserved.
//

import UIKit

class ScanView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let conext = UIGraphicsGetCurrentContext()!
        conext.setLineWidth(5.0);
        conext.setStrokeColor(UIColor.orange.cgColor)
        //创建并设置路径
        let path = CGMutablePath()
        path.move(to: CGPoint(x:  20, y:  2.5))
        path.addLine(to: CGPoint(x:  2.5, y: 2.5))
        path.addLine(to: CGPoint(x:  2.5, y: 20))
        
        path.move(to: CGPoint(x:  2.5, y:  self.bounds.height - 20))
        path.addLine(to: CGPoint(x:  2.5, y: self.bounds.height - 2.5))
        path.addLine(to: CGPoint(x:  20, y: self.bounds.height - 2.5))
        
        path.move(to: CGPoint(x:  self.bounds.width - 20, y:  self.bounds.height - 2.5))
        path.addLine(to: CGPoint(x:  self.bounds.width - 2.5, y: self.bounds.height - 2.5))
        path.addLine(to: CGPoint(x:  self.bounds.width - 2.5, y: self.bounds.height - 20))

        path.move(to: CGPoint(x:  self.bounds.width - 2.5, y:  20))
        path.addLine(to: CGPoint(x:  self.bounds.width - 2.5, y: 2.5))
        path.addLine(to: CGPoint(x:  self.bounds.width - 20, y: 2.5))
        conext.addPath(path)
        conext.strokePath()
    }
    

}
