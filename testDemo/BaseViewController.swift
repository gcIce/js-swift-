//
//  BaseViewController.swift
//  SmartAED
//
//  Created by 高诚 on 2017/12/19.
//  Copyright © 2017年 高诚. All rights reserved.
//

import UIKit
protocol navProtocol:class {
    func backItem()
    func rightBtnClick(isWebCreat:Bool)
}

class BaseViewController: UIViewController,UIGestureRecognizerDelegate {
    weak var delegate: navProtocol?
    var  isWebCreat:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        //关闭导航栏半透明效果
        self.navigationController?.navigationBar.isTranslucent = false
        
        //侧滑返回
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = true
        // Do any additional setup after loading the view.
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer) {
            //只有二级以及以下的页面允许手势返回
            return self.navigationController!.viewControllers.count > 1
        }
        return true
    }
  
    
    //添加左边按钮
    func addLeftBtn(image:UIImage?,title:String){
        let leftBtn = UIButton(type:.system)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        if image != nil {
            //创建左边按钮
            leftBtn.setImage(image, for: .normal)
        } else {
            //创建左边按钮
            leftBtn.setTitle(title, for: .normal)
            leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15*scanleText)
        }
        leftBtn.addTarget(self, action: #selector(leftClick), for: .touchUpInside)
        let btn = UIBarButtonItem(customView: leftBtn)
        //设置导航项左边的按钮
        navigationItem.setLeftBarButton(btn, animated: true)
    }
    
    @objc private func leftClick(){
        delegate?.backItem()
    }
    
    //添加右边按钮
    func addRightBtn(image:UIImage?,title:String,isWebCreat:Bool){
        self.isWebCreat = isWebCreat
        let rightBtn = UIButton(type:.system)
        if image != nil {
            //创建右边按钮
            rightBtn.setImage(image, for: .normal)
        } else {
            //创建右边按钮
            rightBtn.setTitle(title, for: .normal)
            rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15*scanleText)
        }
        rightBtn.addTarget(self, action: #selector(rightClick), for: .touchUpInside)
        let btn = UIBarButtonItem(customView: rightBtn)
        //设置导航项右边的按钮
        navigationItem.setRightBarButton(btn, animated: true)
    }
    
    @objc private func rightClick(){
        delegate?.rightBtnClick(isWebCreat: self.isWebCreat!)
    }
    
    //点击空白处收起键盘
    func clickEmptyHiddenKeyboard(view:UIView){
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewClick(tap:)))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func viewClick(tap:UITapGestureRecognizer){
        tap.view?.endEditing(true)
    }
    
}


extension UINavigationBar {
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(view: self)
        navigationBarImageView!.isHidden = true
    }
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(view: self)
        navigationBarImageView!.isHidden = false
    }
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(view: subview) {
                return imageView
            }
        }
        return nil
    }
}
