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
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    
    @IBOutlet weak var topBlurView: UIVisualEffectView!
    @IBOutlet weak var bottomBlurView: UIVisualEffectView!
    @IBOutlet weak var filterCollectionview: FilterCollectionView!
    
    
    let cameraManager = CameraManager()
    var latestPhotoAssetsFetched: PHFetchResult<PHAsset>? = nil
    lazy var imagePicker = UIImagePickerController()
    
    var currentFilterInfos: [[String:String]] = []
    
    var filterController: FilterController = FilterController()
    
    // filter data
    var timeFilterInfos = [
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "b\(Int(arc4random_uniform(5) + 1))"],
    ]
    
    // filter data
    var humanFilterInfos = [
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ["imageName": "h\(Int(arc4random_uniform(5) + 1))"],
        ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        topBlurView.alpha = 0;
        bottomBlurView.alpha = 0;
        filterController.superView = previewView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup your camera here...
        cameraManager.addPreviewLayerToView(self.previewView)
        cameraManager.writeFilesToPhoneLibrary = false
//        cameraManager.shouldEnableTapToFocus = false
//        cameraManager.shouldEnablePinchToZoom = false
        
        libraryButton.layer.cornerRadius = libraryButton.frame.size.width/2
        libraryButton.layer.masksToBounds = true
        libraryButton.imageView?.contentMode = .scaleAspectFill
        
        self.latestPhotoAssetsFetched = self.fetchLatestPhotos(forCount: 1)
        if let asset = self.latestPhotoAssetsFetched?.firstObject {
            // Request the image.
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: self.libraryButton.frame.size,
                                                  contentMode: .aspectFit,
                                                  options: nil) { (image, _) in
                self.libraryButton.setImage(image, for: .normal)
            }
        }
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
    
    @IBAction func tapOpenScale(_ sender: Any) {
        if topBlurView.alpha == 0 {
            topBlurView.alpha = 1
        } else {
            topBlurView.alpha = 0
        }
    }
    
    @IBAction func tapBackFront(_ sender: Any) {
        if cameraManager.cameraDevice == .front {
            cameraManager.cameraDevice = .back
        } else {
            cameraManager.cameraDevice = .front
        }
    }
    
    @IBAction func tapLibrary(_ sender: Any) {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func tapConfiguration(_ sender: Any) {
        // undefined feature yet
    }
    
    @IBAction func tapTimeFilter(_ sender: Any) {
        appearTimeFilterView()
    }
    
    @IBAction func tapHumanFilter(_ sender: Any) {
        appearHumanFilterView()
    }
    
    @IBAction func tapCapture(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        guard let capturedImageViewController: CapturedImageViewController = storyboard.instantiateViewController(withIdentifier: "CapturedImageViewController") as? CapturedImageViewController else { return }
        
        //capturedImageViewController.capturedImage = image
        self.present(capturedImageViewController, animated: false, completion: nil)
        
        cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
            capturedImageViewController.capturedImage = image
        })
    }
    
    func fetchLatestPhotos(forCount count: Int?) -> PHFetchResult<PHAsset> {
        
        // Create fetch options.
        let options = PHFetchOptions()
        
        // If count limit is specified.
        if let count = count { options.fetchLimit = count }
        
        // Add sortDescriptor so the lastest photos will be returned.
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        
        // Fetch the photos.
        return PHAsset.fetchAssets(with: .image, options: options)
        
    }
    
    
    
    @IBAction func tapScale(_ sender: Any) {
        topBlurView.alpha = 0
    }
    
    @IBAction func tapFilterClose(_ sender: Any) {
        disappearFilterView()
    }
    
    @IBAction func tapFilterCategory(_ sender: Any) {
        
    }
    
    
    func appearTimeFilterView() {
        self.currentFilterInfos = self.timeFilterInfos
        self.filterCollectionview.reloadData()
        
        self.bottomBlurView.alpha = 1
    }
    
    func appearHumanFilterView() {
        self.currentFilterInfos = self.humanFilterInfos
        self.filterCollectionview.reloadData()
        
        self.bottomBlurView.alpha = 1
    }
    
    
    func disappearFilterView() {
        self.bottomBlurView.alpha = 0
    }
}

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated:  true, completion: nil)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select \(indexPath.row)")
        filterController.putPoseFilter(with: FilterInfo(imageName: currentFilterInfos[indexPath.row]["imageName"]))
        disappearFilterView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselect \(indexPath.row)")
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentFilterInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionCell", for: indexPath)
        if let cell = cell as? FilterCollectionCell {
            let imageName = currentFilterInfos[indexPath.row]["imageName"]
            cell.info = FilterInfo(imageName: imageName)
        }
        
        return cell
    }
}
