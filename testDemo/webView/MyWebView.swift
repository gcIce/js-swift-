//
//  MyWebView.swift
//  SmartAED
//
//  Created by 高诚 on 2017/12/22.
//  Copyright © 2017年 高诚. All rights reserved.
//

import UIKit
import WebKit
import MJRefresh
import SnapKit

protocol webViewDelegate:class {
    func setTitle(title:String?)
    func alterShow(message:String?,type:alterType)
}
enum alterType:Int {
    case alter,comfirm
}
enum backType:Int {
    case getPic,showBtn,scan,openWindow,hidenBtn,setTitle,closeWindow,upLoadImg
}


class MyWebView: UIView,WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate{
    weak var webDelegate:webViewDelegate?
    var webView:WKWebView!
    var isFail:Bool?
    var webTitle:String? {
        willSet{
            guard webDelegate != nil else {
                return
            }
            webDelegate?.setTitle(title: newValue)
        }
    }
    // 顶部刷新
    private let header = MJRefreshNormalHeader()
    private var myRequest:URLRequest?
    var bridge:WebViewJavascriptBridge?
    var VCClosure:((backType,Any?,@escaping WVJBResponseCallback)->Void)?
    lazy private var progressView: UIProgressView = {
        self.progressView = UIProgressView.init(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: UIScreen.main.bounds.width, height: 2))
        self.progressView.tintColor = UIColor.blue      // 进度条颜色
        self.progressView.trackTintColor = UIColor.white // 进度条背景色
        return self.progressView
    }()
    init(frame: CGRect,url:String) {
        super.init(frame: frame)
        let webConfiguration = WKWebViewConfiguration()
        let myURL = URL(string: url)
        webView = WKWebView(frame: frame, configuration: webConfiguration)
        if let url = myURL {
            myRequest = URLRequest(url: url)
            webView.load(myRequest!)
        } else {
            print("错误")
        }
       
        self.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.addSubview(progressView)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.webView.addObserver(self,forKeyPath:"title" ,options:.new, context:nil)
        isFail = true
        header.setRefreshingTarget(self, refreshingAction: #selector(MyWebView.headerRefresh))
        webView.scrollView.mj_header = header
    }
    // 顶部刷新
    @objc func headerRefresh(){
        if isFail! {
            webView.load(myRequest!)
        } else {
        webView.reload()
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //  加载进度条
        if keyPath == "estimatedProgress"{
            progressView.alpha = 1.0
            progressView.setProgress(Float((self.webView?.estimatedProgress) ?? 0), animated: true)
            if (self.webView?.estimatedProgress ?? 0.0)  >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        } else if keyPath == "title"{
            webTitle = self.webView.title
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (webView.url?.scheme?.contains("file"))! {
            isFail = true
        } else {
            isFail = false
        }
        webView.scrollView.mj_header.endRefreshing()
        let jsFunctStr = "yw.onBridgeLoaded();"
        webView.evaluateJavaScript(jsFunctStr) { (value, error) in
            if (error != nil) {
                print("写入成功")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isFail = true
        webView.scrollView.mj_header.endRefreshing()
        webView.load(URLRequest.init(url: URL(fileURLWithPath: Bundle.main.path(forResource: "error", ofType: "html")!)))
    }
    

    
    //弹框
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        webDelegate?.alterShow(message: message, type: .alter)
        completionHandler()
    }
    
    deinit {
        print("webview释放")
        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView?.removeObserver(self, forKeyPath: "title")
        self.webView?.uiDelegate = nil
        self.webView?.navigationDelegate = nil
    }
}

//JS交互
extension MyWebView {
    func jsExchange(){
        bridge = WebViewJavascriptBridge.init(forWebView: webView)
        bridge?.setWebViewDelegate(self)
        //扫一扫
        bridge?.registerHandler("QRScan", handler: {[unowned self] (data, callBack) in
            self.VCClosure!(.scan, nil,callBack!)
        })
        //调用相机，相册
        bridge?.registerHandler("getImage", handler: {[unowned self] (data, callBack) in
            self.VCClosure!(.getPic, nil,callBack!)
        })
        //上传图片
        bridge?.registerHandler("uploadImage", handler: {[unowned self] (data, callBack) in
            self.VCClosure!(.upLoadImg, data ,callBack!)
        })
        //显示选择按钮
        bridge?.registerHandler("showOptionMenu", handler: {[unowned self] (data, callBack) in
            self.VCClosure!(.showBtn, data,callBack!)
        })
        //隐藏选择按钮
        bridge?.registerHandler("hideOptionMenu", handler: {[unowned self] (data, callBack) in
            self.VCClosure!(.hidenBtn, nil,callBack!)
        })
        //打开窗口
        bridge?.registerHandler("openWindow", handler: {[unowned self] (data, callBack) in
            self.VCClosure!(.openWindow, data,callBack!)
        })
        //设置title
        bridge?.registerHandler("setTitle", handler: {[unowned self] (data, callBack) in
            self.VCClosure!(.setTitle, data,callBack!)
        })
        //关闭窗口
        bridge?.registerHandler("_closePage", handler: {[unowned self] (data, callBack) in
            self.VCClosure!(.closeWindow, nil,callBack!)
        })
      
        
    }
}
