//
//  CapturedImageViewController.swift
//  empathy-ios
//
//  Created by GwakDoyoung on 05/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class CapturedImageViewController: UIViewController {
    
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var capturedImage: UIImage? {
        didSet {
            if let capturedImage = capturedImage {
                capturedImageView.image = capturedImage
                loadingIndicator.stopAnimating()
                loadingIndicator.alpha = 0
            } else {
                loadingIndicator.startAnimating()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let capturedImage = capturedImage {
            capturedImageView.image = capturedImage
            loadingIndicator.stopAnimating()
            loadingIndicator.alpha = 0
        } else {
            loadingIndicator.startAnimating()
        }
    }
    
    @IBAction func tapSave(_ sender: Any) {
        
    }
    
    @IBAction func tapBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tapScale(_ sender: Any) {
        
    }
    
    @IBAction func tapFlag(_ sender: Any) {
        
    }
    
    @IBAction func tapExport(_ sender: Any) {
        // image to share
        guard let image = capturedImage else {
            return
        }
        
        // set up activity view controller
        let imageToShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
