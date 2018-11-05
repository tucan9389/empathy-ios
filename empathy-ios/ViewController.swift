//
//  ViewController.swift
//  empathy-ios
//
//  Created by GwakDoyoung on 24/10/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import AVFoundation
import CameraManager

class ViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    
    
    
    let cameraManager = CameraManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup your camera here...
        cameraManager.addPreviewLayerToView(self.previewView)
        cameraManager.writeFilesToPhoneLibrary = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func tapFlash(_ sender: Any) {
        if cameraManager.flashMode == .off {
            cameraManager.flashMode = .on
            flashButton.isSelected = true
        } else {
            cameraManager.flashMode = .off
            flashButton.isSelected = false
        }
    }
    @IBAction func tapScale(_ sender: Any) {
        
    }
    @IBAction func tapBackFront(_ sender: Any) {
        if cameraManager.cameraDevice == .front {
            cameraManager.cameraDevice = .back
        } else {
            cameraManager.cameraDevice = .front
        }
        
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
        let storyboard: UIStoryboard = self.storyboard!
        guard let capturedImageViewController: CapturedImageViewController = storyboard.instantiateViewController(withIdentifier: "CapturedImageViewController") as? CapturedImageViewController else { return }
        
        //capturedImageViewController.capturedImage = image
        self.present(capturedImageViewController, animated: true, completion: nil)
        
        cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
            capturedImageViewController.capturedImage = image
        })
    }
    
    
}
