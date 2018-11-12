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
    @IBOutlet weak var filterTypeStackView: UIStackView!
    @IBOutlet weak var filterCollectionview: FilterCollectionView!
    
    
    let cameraManager = CameraManager()
    var latestPhotoAssetsFetched: PHFetchResult<PHAsset>? = nil
    lazy var imagePicker = UIImagePickerController()
    
    //var currentFilterInfos: [[String:String]] = []
    
    var filterController: FilterController = FilterController()
    
    // time filter
    var humanFilters: [Filter] = []
    var textFilters: [Filter] = []
    var funnyFilters: [Filter] = []
    var backgroundFilters: [Filter] = []
    
    // pose filter
    var poseFilters: [Filter] = []
    
    enum SelectedFilterType {
        case human(filters: [Filter])
        case text(filters: [Filter])
        case funny(filters: [Filter])
        case background(filters: [Filter])
        case pose(filters: [Filter])
        case none
    }
    
    var filterType: SelectedFilterType = .none
    var filters: [Filter] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        topBlurView.alpha = 0;
        bottomBlurView.alpha = 0;
        filterController.superView = previewView
        
        
        // parsing temp
        if let path = Bundle.main.path(forResource: "temp-camera-filter", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let filterGroups = jsonResult as? Array<Dictionary<String, AnyObject>> {
                    print(filterGroups.count)
                    let decoder = JSONDecoder()

                    for filterGroup in filterGroups {
                        guard let groupType: String = filterGroup["type"] as? String else {continue}
                        if groupType == "time-filter" {
                            if let filterDictionarys = filterGroup["filters"] as? Array<Dictionary<String, AnyObject>> {
                                let data = try! JSONSerialization.data(withJSONObject: filterDictionarys,     options: .prettyPrinted)
                                let filters = try decoder.decode([Filter].self, from: data)
                                for filter: Filter in filters {
                                    if filter.type == "human" {
                                        humanFilters.append(filter)
                                    } else if filter.type == "text" {
                                        textFilters.append(filter)
                                    } else if filter.type == "funny" {
                                        funnyFilters.append(filter)
                                    } else if filter.type == "background" {
                                        backgroundFilters.append(filter)
                                    } else {
                                        
                                    }
                                }
                            }
                        } else if groupType == "pose-filter" {
                            if let filterDictionarys = filterGroup["filters"] as? Array<Dictionary<String, AnyObject>> {
                                let data = try! JSONSerialization.data(withJSONObject: filterDictionarys,     options: .prettyPrinted)
                                let filters = try decoder.decode([Filter].self, from: data)
                                for filter: Filter in filters {
                                    poseFilters.append(filter)
                                }
                            }
                        }
                    }
                }
            } catch let error {
                // handle error
                print(error.localizedDescription)
            }
        }
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
        
        prepareTimeFilterView()
        appearTimeFilterView()
    }
    
    @IBAction func tapHumanFilter(_ sender: Any) {
        self.filterType = .pose(filters: self.poseFilters)
        self.filters = self.poseFilters
        preparePoseFilterView()
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
        if let button: UIButton = sender as? UIButton {
            print(button.tag)
            if button.tag == 1 {
                self.filterType = .human(filters: self.humanFilters)
                self.filters = self.humanFilters
            } else if button.tag == 2 {
                self.filterType = .text(filters: self.textFilters)
                self.filters = self.textFilters
            } else if button.tag == 3 {
                self.filterType = .funny(filters: self.funnyFilters)
                self.filters = self.funnyFilters
            } else if button.tag == 4 {
                self.filterType = .background(filters: self.backgroundFilters)
                self.filters = self.backgroundFilters
            } else {
                self.filterType = .none
                self.filters = []
            }
        }
        
        self.filterCollectionview.reloadData()
    }
    
    func setFilterGroup(filters: [Filter]) {
        
    }
    
    func prepareTimeFilterView() {
        filterTypeStackView.subviews.forEach({ if $0.tag != 0 { $0.alpha = 1 } })
    }
    
    func preparePoseFilterView() {
        filterTypeStackView.subviews.forEach({ if $0.tag != 0 { $0.alpha = 0 } })
    }
    
    func appearTimeFilterView() {
        //self.currentFilterInfos = self.timeFilterInfos
        self.filterCollectionview.reloadData()
        
        self.bottomBlurView.alpha = 1
    }
    
    func appearHumanFilterView() {
        //self.currentFilterInfos = self.humanFilterInfos
        self.filterCollectionview.reloadData()
        
        self.bottomBlurView.alpha = 1
    }
    
    
    func disappearFilterView() {
        self.bottomBlurView.alpha = 0
        self.filterType = .none
        self.filters = []
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
        switch self.filterType {
        case .pose(filters: _):
            filterController.putPoseFilter(with: filters[indexPath.row])
        case .none:
            break;
        default:
            filterController.putTimeFilter(with: filters[indexPath.row])
        }
        
        disappearFilterView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselect \(indexPath.row)")
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionCell", for: indexPath)
        if let cell = cell as? FilterCollectionCell {
            let imageName = filters[indexPath.row].imageURL
            cell.info = FilterInfo(imageName: imageName)
        }
        
        return cell
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
    }
}
