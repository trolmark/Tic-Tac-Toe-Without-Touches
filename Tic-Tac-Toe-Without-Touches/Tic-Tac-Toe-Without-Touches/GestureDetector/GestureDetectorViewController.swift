//
//  GestureDetectorViewController.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 29.04.2020.
//

import UIKit
import Foundation
import Vision
import CoreMedia

protocol GestureDetectorControllerDelegate: class {
    func gestureControllerDetectTap(atPoint point: CGPoint, gestureDetector: GestureDetectorViewController)
}

final class GestureDetectorViewController: UIViewController {
    
    public weak var delegate: GestureDetectorControllerDelegate?
    
    private var request: VNCoreMLRequest?
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var isInferencing = false
    private var showPrediction = false
    
    private var previewPrediction: UIImageView = .init(frame: .zero)
    private var touchPointView: UIView = .init(frame: .init(x: 0, y: 0, width: 40, height: 40))
    private var videoCapture: VideoCapture!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        setUpModel()
        setUpCamera()
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
        self.view.addSubview(self.touchPointView)
        self.touchPointView.layer.cornerRadius = self.touchPointView.frame.height * 0.5
        self.touchPointView.backgroundColor = .red
        self.touchPointView.isHidden = true
        
        self.previewPrediction.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.previewPrediction)
        
        let constraints = [
            previewPrediction.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewPrediction.topAnchor.constraint(equalTo: view.topAnchor),
            previewPrediction.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewPrediction.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
        videoCapture.setUp(sessionPreset: .cif352x288) { success in
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
        if showPrediction {
            self.view.bringSubviewToFront(previewPrediction)
        }
        self.view.bringSubviewToFront(self.touchPointView)
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
            if self.showPrediction {
                self.previewPrediction.image = UIImage(ciImage: CIImage(cvPixelBuffer: observation.pixelBuffer))
            }
            guard let tipPoint = observation.pixelBuffer.topWhitePoint() else {
                self.touchPointView.isHidden = true
                return
            }
        
            let imageFingerPoint = VNImagePointForNormalizedPoint(
                tipPoint,
                Int(self.view.bounds.size.width), Int(self.view.bounds.size.height)
            )
            
            self.showTouchPoint(at: imageFingerPoint)
            self.delegate?.gestureControllerDetectTap(atPoint: imageFingerPoint, gestureDetector: self)
        }
    }
    
    func showTouchPoint(at point: CGPoint) {
        self.touchPointView.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.touchPointView.center = point
        }
    }
}
