//
//  CapturedImageViewController.swift
//  empathy-ios
//
//  Created by GwakDoyoung on 05/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import Toaster

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
        guard let image = capturedImage else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
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
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "저장 실패", message: error.localizedDescription)
        } else {
            dismiss(animated: false, completion: {
                Toast(text: "저장 성공!").show()
            })
        }
    }

    func showAlertWith(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
