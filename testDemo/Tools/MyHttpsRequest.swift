//
//  MyHttpsRequest.swift
//  SmartAED
//
//  Created by 高诚 on 2017/12/18.
//  Copyright © 2017年 高诚. All rights reserved.
//

import Foundation
import Alamofire

class MyHttpsRequest{
    
    static func postRequest(urlString:String,parameters:Parameters?,success:@escaping(_ value:DataResponse<Any>)->(),failBlock:@escaping (_ fail:Error)->()){
        if let params = parameters {
            Alamofire.request(urlString, method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON(completionHandler: { (response) in
                    if response.result.isSuccess {
                        success(response)
                    } else {
                        failBlock(response.error!)
                    }
                })
        } else {
            Alamofire.request(urlString,method:.post).responseJSON { (response) in
                if response.result.isSuccess {
                    success(response)
                } else {
                    failBlock(response.error!)
                }
            }
        }
        
    }
    
    static func showError(error:NSError)->String {
        switch error.code {
        case -1001,-2000:
            return "请求超时"
        case -1003,-1004,-1009:
            return "网络未连接"
        case -999:
            return "请求失败，请重试"
        default:
            return "网络错误"
        }
    }
    
    static func upLoadImg(urlString:String,parameters:Parameters?,imageData:Data,success:@escaping(_ value:DataResponse<Any>)->(),failBlock:@escaping (_ fail:Error)->(),comProgress:@escaping (_ pro:Double)->()){
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                //采用post表单上传
                // 参数解释：
                //withName:和后台服务器的name要一致 ；fileName:可以充分利用写成用户的id，但是格式要写对； mimeType：规定的，要上传其他格式可以自行百度查一下
                multipartFormData.append(imageData, withName: "file\(Int(Date().timeIntervalSince1970*1000))", fileName: "fileasdsad\(Int(Date().timeIntervalSince1970*1000)).jpg", mimeType: "image/jpeg")
                //如果需要上传多个文件,就多添加几个
                //multipartFormData.append(imageData, withName: "file", fileName: "123456.jpg", mimeType: "image/jpeg")
                //......
                
        },to: urlString,encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                //连接服务器成功后，对json的处理
                upload.responseJSON { response in
                   success(response)
                }
                //获取上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("图片上传进度: \(progress.fractionCompleted)")
                    comProgress(progress.fractionCompleted)
                }
            case .failure(let encodingError):
                //打印连接失败原因
               failBlock(encodingError)
            }
        })
       
    }
        
}
