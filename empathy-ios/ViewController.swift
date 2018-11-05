//
//  ViewController.swift
//  empathy-ios
//
//  Created by GwakDoyoung on 24/10/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup your camera here...
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            //Step 9
            
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }        
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        //Step12
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            //Step 13
        }
        
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.previewView.bounds
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    @IBAction func tapFlash(_ sender: Any) {
//        guard let device = CameraManager.shared.backDevice else { return }
//        guard device.isTorchAvailable else { return }
//        do {
//            try device.lockForConfiguration()
//            device.torchMode = device.torchMode ? .off : .on
//            if device.torchMode == .on {
//                try device.setTorchModeOn(level: 0.7)
//            }
//        } catch {
//            debugPrint(error)
//        }
    }
    @IBAction func tapScale(_ sender: Any) {
    }
    @IBAction func tapBackFront(_ sender: Any) {
    }
    @IBAction func tapLibrary(_ sender: Any) {
    }
    @IBAction func tapConfiguration(_ sender: Any) {
    }
    @IBAction func tapTimeFilter(_ sender: Any) {
    }
    @IBAction func tapHumanFilter(_ sender: Any) {
    }
    @IBAction func tapCapture(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        // captureImageView.image = image
        
        
        let storyboard: UIStoryboard = self.storyboard!
        if let capturedImageViewController: CapturedImageViewController = storyboard.instantiateViewController(withIdentifier: "CapturedImageViewController") as? CapturedImageViewController {
            capturedImageViewController.capturedImage = image
            present(capturedImageViewController, animated: true, completion: nil)
        }
        
    }
}

