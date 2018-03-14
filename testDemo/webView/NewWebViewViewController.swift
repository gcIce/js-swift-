//
//  NewWebViewViewController.swift
//  AEDAdministrator
//
//  Created by 高诚 on 2018/2/8.
//  Copyright © 2018年 高诚. All rights reserved.
//

import UIKit

class NewWebViewViewController: BaseWebViewController,webViewDelegate,navProtocol {

    var urlHttp:URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        guard (urlHttp != nil) else {
            print("url无效")
            return
        }
        addLeftBtn(image: nil, title: "返回")
        creatWebView(url: urlHttp!, isJS: true)
        webview?.webDelegate = self
        self.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("newWebview释放")
    }
    
    func backItem() {
           print(getCurrentVC().getCurrentViewController1())
        self.navigationController?.popViewController(animated: true)
    }
    
    func rightBtnClick(isWebCreat: Bool) {
        if isWebCreat {
            //调用JS方法
                webview?.bridge?.callHandler(methodArr[0])
           
        }
    }
    
    
    func setTitle(title: String?) {
        self.title = title
    }
    
    func alterShow(message: String?,type: alterType) {
        switch type {
        case .alter:
            let alertController = UIAlertController(title: "提示",
                                                    message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: {
                action in
                
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            break
        case .comfirm:
            break
        }
       
    }
    
}
