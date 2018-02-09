//
//  ViewController.swift
//  testDemo
//
//  Created by 高诚 on 2018/2/2.
//  Copyright © 2018年 高诚. All rights reserved.
//

import UIKit
import WebKit

class ViewController: BaseWebViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        let testBtn = UIButton(type: .system)
        testBtn.frame = CGRect(origin: self.view.center, size: CGSize(width: 100, height: 100))
        testBtn.setTitle("测试", for: .normal)
        testBtn.backgroundColor = UIColor.red
        testBtn.addTarget(self, action: #selector(click), for: .touchUpInside)
        self.view.addSubview(testBtn)
        
        // Do any additional setup after loading the view.
    }
    @objc func click(){
        let vc = NewWebViewViewController()
        vc.urlHttp = Bundle.main.url(forResource: "test", withExtension: "html")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

