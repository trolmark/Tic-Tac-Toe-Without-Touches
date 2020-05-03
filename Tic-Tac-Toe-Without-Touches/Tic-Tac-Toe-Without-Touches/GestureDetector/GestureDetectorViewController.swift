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

protocol GestureDetectorControllerDelegate: class {
    func gestureControllerDetectTap(atPosition position: CGPoint, gestureDetector: GestureDetectorViewController)
}

final class GestureDetectorViewController: UIViewController {
    
    
    public weak var delegate: GestureDetectorControllerDelegate?
    
    private var request: VNCoreMLRequest?
    private var isInferencing = false
    private let semaphore = DispatchSemaphore(value: 1)
    private var previewPrediction: UIImageView = .init(frame: .zero)
    
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
        self.view.backgroundColor = .white
        self.previewPrediction.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.previewPrediction)
        
        let constraints = [
            previewPrediction.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewPrediction.topAnchor.constraint(equalTo: view.topAnchor),
            previewPrediction.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewPrediction.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
        
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: HandModel().model) {
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError("fail to create vision model")
        }
    }
    
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .vga640x480) { success in
            if success {
                if let previewLayer = self.videoCapture.previewLayer {
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
        self.view.bringSubviewToFront(previewPrediction)
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
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored)
        try? handler.perform([request])
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        guard let observation = request.results?.first as? VNPixelBufferObservation else {
            fatalError("Unexpected result type from VNCoreMLRequest")
        }
        
        defer {
            self.isInferencing = false
            self.semaphore.signal()
        }

        DispatchQueue.main.async {
            self.previewPrediction.image = UIImage(ciImage: CIImage(cvPixelBuffer: observation.pixelBuffer))
            guard let tipPoint = observation.pixelBuffer.topWhitePoint() else { return }
        
            let imageFingerPoint = VNImagePointForNormalizedPoint(
                tipPoint,
                Int(self.view.bounds.size.width), Int(self.view.bounds.size.height)
            )
            
            self.delegate?.gestureControllerDetectTap(atPosition: imageFingerPoint, gestureDetector: self)
        }
    }
}
