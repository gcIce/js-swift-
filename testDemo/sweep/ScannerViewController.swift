//
//  ScannerViewController.swift
//  QRCode
//
//  Created by Erwin on 16/5/5.
//  Copyright © 2016年 Erwin. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: BaseViewController,AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //相机显示视图
    var cameraView:ScannerBackgroundView!
    
    
    let captureSession = AVCaptureSession()
    
    var isSweep = true
    
    var valueClosure:((String)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
       
        
        cameraView = ScannerBackgroundView(frame: self.view.bounds)
        self.view.addSubview(cameraView)
        
        //初始化捕捉设备（AVCaptureDevice），类型AVMdeiaTypeVideo
        let captureDevice = AVCaptureDevice.default(for:AVMediaType.video)
        guard captureDevice != nil else {
            return
        }
        
        let input :AVCaptureDeviceInput
        
        //创建媒体数据输出流
        let output = AVCaptureMetadataOutput()
        
        //捕捉异常
        do{
            //创建输入流
            input = try AVCaptureDeviceInput(device: captureDevice!)
            
            //把输入流添加到会话
            captureSession.addInput(input)
            
            //把输出流添加到会话
            captureSession.addOutput(output)
        }catch {
            print("异常")
        }
        
        //创建串行队列
        let dispatchQueue = DispatchQueue(label: "queue", attributes: [])
        
        //设置输出流的代理
        output.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        
        //设置输出媒体的数据类型
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,AVMetadataObject.ObjectType.ean13,AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.code128]
        
        //创建预览图层
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        //设置预览图层的填充方式
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        //设置预览图层的frame
        videoPreviewLayer.frame = cameraView.bounds
        
        //将预览图层添加到预览视图上
        cameraView.layer.insertSublayer(videoPreviewLayer, at: 0)
        
        //设置扫描范围
        output.rectOfInterest = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        
    }
    deinit {
        print("sweep释放")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 0.1, alpha: 0.5)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.scannerStart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         self.navigationController?.navigationBar.barTintColor = navBackground
        self.navigationController?.navigationBar.tintColor = navItemColor
        self.scannerStop()
    }
    
    func scannerStart(){
        captureSession.startRunning()
        cameraView.scanning = "start"
        cameraView.startTime()
    }
    
    func scannerStop() {
        captureSession.stopRunning()
        cameraView.scanning = "stop"
        cameraView.timer.invalidate()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if  metadataObjects.count > 0 {
            let metaData : AVMetadataMachineReadableCodeObject = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            DispatchQueue.main.async(execute: {
                if self.isSweep {
                    self.isSweep = false
                    if let valueStr = metaData.stringValue {
                        if valueStr.lengthOfBytes(using: .utf8) > 0 {
                            self.scannerStop()

                            self.valueClosure!(valueStr)
                            self.navigationController?.popViewController(animated: true)

                        }
                    }
                }
            })
        }
    }
    
    
    
    
}


