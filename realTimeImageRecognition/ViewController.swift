//
//  ViewController.swift
//  realTimeImageRecognition
//
//  Created by Gan on 28/4/19.
//  Copyright © 2019 Gan. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareCamera()
    }
    
    @IBOutlet weak var imageItemName: UILabel!
    
    @IBOutlet weak var previewView: UIView!
    func prepareCamera() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(captureDeviceInput)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspect
        previewLayer.frame = previewView.bounds
        previewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(previewLayer)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let cvPixel = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {return}
        let request = VNCoreMLRequest(model: model) { (request, err) in
            if let results = request.results as? [VNClassificationObservation] {
                if let firstObservation = results.first {
                     print(firstObservation.confidence)
                     print(firstObservation.identifier)
                    DispatchQueue.main.async {
                        self.imageItemName.text = firstObservation.identifier
                    }
                }
               
            }
            
        }
        
        do {
            try VNImageRequestHandler(cvPixelBuffer: cvPixel, options: [:]).perform([request])
        } catch {
            print("error")
        }
    }


}

