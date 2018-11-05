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
    var capturedImage: UIImage? {
        didSet {
            capturedImageView.image = capturedImage
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let capturedImage = capturedImage {
            capturedImageView.image = capturedImage
        }
    }
    
    @IBAction func tapSave(_ sender: Any) {
        
    }
    
    @IBAction func tapBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapScale(_ sender: Any) {
        
    }
    
    @IBAction func tapFlag(_ sender: Any) {
        
    }
    
    @IBAction func tapExport(_ sender: Any) {
        
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
