//
//  GestureDetectorViewController.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 29.04.2020.
//  Copyright © 2020 Readdle. All rights reserved.
//

import UIKit
import Foundation
import Vision
import CoreMedia


final class GestureDetectorViewController: UIViewController {
    
    private var request: VNCoreMLRequest?
    private var visionModel: VNCoreMLModel?
    private var isInferencing = false
    private let semaphore = DispatchSemaphore(value: 1)
    private var predictions: [VNRecognizedObjectObservation] = []
    
    private var videoCapture: VideoCapture!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        setUpModel()
        setUpCamera()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
}
        
extension GestureDetectorViewController {
    
    func setUpUI() {
        
    }
        
    func setUpModel() {
//        if let visionModel = try? VNCoreMLModel(for: objectDectectionModel.model) {
//            self.visionModel = visionModel
//            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
//            request?.imageCropAndScaleOption = .scaleFill
//        } else {
//            fatalError("fail to create vision model")
//        }
    }
    
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .vga640x480) { success in
            if success {
                if let previewLayer = self.videoCapture.previewLayer {
                    self.view.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                self.videoCapture.start()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = view.bounds
    }
}


extension GestureDetectorViewController: VideoCaptureDelegate {
        
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        if !self.isInferencing, let pixelBuffer = pixelBuffer {
            self.isInferencing = true
            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
    
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = request else { fatalError() }
        self.semaphore.wait()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let predictions = request.results as? [VNRecognizedObjectObservation] {
            //            print(predictions.first?.labels.first?.identifier ?? "nil")
            //            print(predictions.first?.labels.first?.confidence ?? -1)
            self.predictions = predictions
            DispatchQueue.main.async {
                self.isInferencing = false
            }
        } else {
            self.isInferencing = false
        }
        self.semaphore.signal()
    }
}
