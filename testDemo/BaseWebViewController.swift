//
//  BaseWebViewController.swift
//  AEDAdministrator
//
//  Created by 高诚 on 2018/2/7.
//  Copyright © 2018年 高诚. All rights reserved.
//

import UIKit

class BaseWebViewController: BaseViewController {
    var webview:MyWebView?
    var methodArr = Array<String>()
    var imageID:Int = 0
    lazy private var choseImgDic = {
        return Dictionary<String,Data>()
    }()
    private var JScallBack:WVJBResponseCallback?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func creatWebView(url:URL,isJS:Bool){
        // 加载本地Html页面
        let urlStr = url.absoluteString
        webview = MyWebView(frame: .zero, url: urlStr)
        self.view.addSubview(webview!)
        webview?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        if isJS {
            webview?.jsExchange()
            webview?.VCClosure = {[unowned self] (type, data, callBack) in
                switch type {
                case .getPic:
                    self.getPic(callBack: callBack)
                    break
                case .scan:
                    self.pushToSweep(callback: callBack)
                    break
                case .openWindow:
                    guard let value = data as? Dictionary<String,Any> else{
                        callBack(["status":false])
                        return
                    }
                    if (value["name"] as! String).contains("browser") {
                        guard let obj = value["extras"] as? Dictionary<String,String> else {
                            callBack(["status":false])
                            return
                        }
                        guard let pushUrl = obj["url"] else{
                            callBack(["status":false])
                            return
                        }
                        let token = obj["token"]
                        let newWebVC = NewWebViewViewController()
                        //                                newWebVC.urlHttp = URL(string: pushUrl)
                        newWebVC.urlHttp = Bundle.main.url(forResource: "test", withExtension: "html")
                        self.navigationController?.pushViewController(newWebVC, animated: true)
                        callBack(["status":true])
                    } else {
                        callBack(["status":false])
                    }
                    break
                case .showBtn:
                    guard let value = data as? Array<Any> else{
                        callBack(["status":false])
                        return
                    }
                    //                        if value.count == 1 {
                    guard let dict = value[0] as? Dictionary<String,Any> else{
                        callBack(["status":false])
                        return
                    }
                    if self.methodArr.count > 0{
                        self.methodArr.removeAll()
                    }
                    self.addRightBtn(image: nil, title: dict["name"] as! String, isWebCreat: true)
                    self.methodArr.append(dict["action"] as! String)
                    print("\(self.methodArr[0]) count:\(self.methodArr.count)")
                    callBack(["status":true])
                    //                        }
                    
                    break
                case .hidenBtn:
                    self.methodArr.removeAll()
                    self.navigationItem.rightBarButtonItem = nil
                    break
                case .setTitle:
                    if let value = data as? String{
                        self.webview?.webTitle = value
                    }
                    break
                case .closeWindow:
                    let nav = getCurrentVC().getCurrentViewController1() as? UINavigationController
                    nav?.popViewController(animated: true)
                    break
                case .upLoadImg:
                    if let dict = data as? Dictionary<String,Any> {
                        guard self.imageID != 0 else {
                            callBack(["error":"103","status":false])
                            return
                        }
                        print(dict["localId"] as! String)
                        if let imgurl = dict["url"] as? String,let id = dict["localId"] as? String{
                            guard let data = self.choseImgDic[id] else{
                               return
                            }
                            MyHttpsRequest.upLoadImg(urlString: imgurl, parameters: nil, imageData: data, success: { (response) in
                              callBack(["data":response.result.value,"status":true])
                            }, failBlock: { (error) in
                                
                            }, comProgress: { (progress) in
                             
                            })
                        }
                    }
                    break
                }
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//选择照片
extension BaseWebViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    func getPic(callBack:@escaping WVJBResponseCallback){
        JScallBack = callBack
        var alert: UIAlertController!
        alert = UIAlertController(title: "提示", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cleanAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel,handler:nil)
        let photoAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.default){ (action:UIAlertAction)in
            self.camera()
        }
        let choseAction = UIAlertAction(title: "从手机相册选择", style: UIAlertActionStyle.default){ (action:UIAlertAction)in
            self.photo()
        }
        
        alert.addAction(cleanAction)
        alert.addAction(photoAction)
        alert.addAction(choseAction)
        self.present(alert, animated: true, completion: nil)
    }
    func camera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picController = UIImagePickerController()
            picController.sourceType = .camera
            picController.delegate = self
            picController.allowsEditing = false
            self.present(picController, animated: true, completion: nil)
        } else {
            print("相机不可用")
        }
        
    }
    
    func photo(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picController = UIImagePickerController()
            picController.delegate = self
            picController.sourceType = .photoLibrary
            picController.allowsEditing = false
            self.present(picController, animated: true, completion: nil)
        } else {
            print("相册不可用")
        }
    }
    //MARK:UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let resultImg = info["UIImagePickerControllerOriginalImage"] as! UIImage
        let imgData = UIImageJPEGRepresentation(resultImg, 0.3)
        let encodedImageStr = imgData?.base64EncodedString()
        let imageString = removeSpaceAndNewline(str: encodedImageStr!)
        self.dismiss(animated: true) {
            
        }
        imageID = Int(Date().timeIntervalSince1970*1000)
        choseImgDic[String(imageID)] = imgData
        JScallBack!(["data":"data:image/jpeg;base64," + imageString,"localId":imageID])
    }
    
    //修改分辨率
    func changeImage(image:UIImage)->UIImage{
        let maxImageSize:CGFloat = 1024.0
        //先调整分辨率
        var newSize = CGSize(width: image.size.width, height: image.size.height)
        let tempHeight = newSize.height / maxImageSize
        let tempWidth = newSize.width / maxImageSize
        if tempWidth > 1.0 && tempWidth > tempHeight {
            newSize = CGSize(width: image.size.width / tempWidth, height: image.size.height / tempWidth)
        } else if tempHeight > 1.0 && tempWidth < tempHeight {
            newSize = CGSize(width:image.size.width / tempHeight, height:image.size.height / tempHeight)
        }
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    // 图片转成base64字符串需要先取出所有空格和换行符
    func removeSpaceAndNewline(str:String)->String{
        var temp = str.replacingOccurrences(of: " ", with: "")
        temp = temp.replacingOccurrences(of: "\r", with: "")
        temp = temp.replacingOccurrences(of: "\n", with: "")
        return temp
    }
    
    //MARK 扫描
    func pushToSweep(callback:@escaping WVJBResponseCallback){
        let scanVC = ScannerViewController()
        self.navigationController?.pushViewController(scanVC, animated: true)
        scanVC.valueClosure = { value in
            callback(["resultStr":value])
        }
    }
    
}

