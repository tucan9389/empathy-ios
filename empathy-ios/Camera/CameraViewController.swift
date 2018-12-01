//
//  ViewController.swift
//  empathy-ios
//
//  Created by GwakDoyoung on 24/10/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Vision
import Accelerate
import VideoToolbox

class CameraViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topScaleView: UIView!
    @IBOutlet weak var topBlurView: UIVisualEffectView!
    @IBOutlet weak var bottomBlurView: UIVisualEffectView!
    @IBOutlet weak var filterTypeStackView: UIStackView!
    @IBOutlet weak var filterCollectionview: FilterCollectionView!
    
    var cameraRatioConstraint: NSLayoutConstraint?
    @IBOutlet weak var cameraRatioView: UIView!
    @IBOutlet weak var ratioBottomView: UIVisualEffectView!
    @IBOutlet weak var libraryImageView: UIImageView!
    @IBOutlet weak var ratioTopView: UIVisualEffectView!
    @IBOutlet weak var ratioButtonStackView: UIStackView!
    @IBOutlet weak var libraryImageCloseButton: UIButton!
    
    let ssdPostProcessor = SSDPostProcessor(numAnchors: 1917, numClasses: 90)
    var visionModel: VNCoreMLModel?
    var screenHeight: Double?
    var screenWidth: Double?
    var horizonalSpace: Double?
    
    let numBoxes = 100
    var boundingBoxes: [BoundingBox] = []
    let multiClass = true
    
    // MARK: - AV Property
    private var cameraLayer: AVCaptureVideoPreviewLayer?
    private var captureSession: AVCaptureSession?
    private var cameraPosition: AVCaptureDevice.Position?

    var capturedImage: UIImage?
    var capturedRect: CGRect?
    
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
        //topBlurView.alpha = 0;
        topScaleView.alpha = 0;
        bottomBlurView.alpha = 0;
        filterController.superView = filterView//previewView
        
        
        // ===========================
        // ========= 카메라 세팅 ========
        // ===========================
        setUpCamera()
        
        // ===========================
        // ========= SSD 세팅 =========
        // ===========================
        setupVision()
        
        setupBoxes()
        
        screenWidth = Double(view.frame.width)
        screenHeight = Double(view.frame.height)
        //print(screenWidth, screenHeight)
        if let sw = screenWidth, let sh = screenHeight {
            let newScreenWidth = sw * (0.5625 / (sw/sh))
            horizonalSpace = (newScreenWidth - sw)/2
            screenWidth = newScreenWidth
        }
        //print(screenWidth, screenHeight)
        
        
        
        
        // parsing temp json
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
        
        updateCameraRatio(with: .full)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup your camera here...
//        cameraManager.addPreviewLayerToView(self.previewView)
//        cameraManager.writeFilesToPhoneLibrary = false
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func setUpCamera() {
        if let captureSession = self.captureSession {
            captureSession.stopRunning()
        }
        if let cameraLayer = self.cameraLayer {
            cameraLayer.removeFromSuperlayer()
        }
        
        let captureSession: AVCaptureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.high
            
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device) {
            captureSession.addInput(input)
        }
    
        let cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.captureSession = captureSession
        self.cameraLayer = cameraLayer
        
        self.previewView?.layer.addSublayer(cameraLayer)
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraLayer.connection?.videoOrientation = .portrait
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
        captureSession.addOutput(videoOutput)
        
        captureSession.startRunning()
    }
    
    func resizePreviewLayer() {
        self.cameraLayer?.frame = self.previewView?.bounds ?? .zero
    }
    
    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    
    
    @IBAction func tapFlash(_ sender: Any) {
//        if cameraManager.flashMode == .off {
//            cameraManager.flashMode = .on
//            flashButton.isSelected = true
//        } else {
//            cameraManager.flashMode = .off
//            flashButton.isSelected = false
//        }
    }
    
    @IBAction func tapOpenScale(_ sender: Any) {
        if topScaleView.alpha == 0 {
            topScaleView.alpha = 1
            
            if topBlurView.frame.origin.y + topBlurView.frame.height < ratioTopView.frame.origin.y + ratioTopView.frame.height {
                topBlurView.alpha = 0
            } else {
                topBlurView.alpha = 1
            }
        } else {
            topScaleView.alpha = 0
        }
    }
    
    @IBAction func tapBackFront(_ sender: Any) {
        //Change camera source
        if let session = captureSession {
            //Indicate that some changes will be made to the session
            session.beginConfiguration()
            
            //Remove existing input
            guard let currentCameraInput: AVCaptureInput = session.inputs.first else {
                return
            }
            
            session.removeInput(currentCameraInput)
            
            //Get new input
            var newCamera: AVCaptureDevice! = nil
            if let input = currentCameraInput as? AVCaptureDeviceInput {
                if (input.device.position == .back) {
                    newCamera = cameraWithPosition(position: .front)
                } else {
                    newCamera = cameraWithPosition(position: .back)
                }
            }
            
            //Add input to session
            var err: NSError?
            var newVideoInput: AVCaptureDeviceInput!
            do {
                newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            } catch let err1 as NSError {
                err = err1
                newVideoInput = nil
            }
            
            if newVideoInput == nil || err != nil {
                print("Error creating capture device input: \(String(describing: err?.localizedDescription))")
            } else {
                session.addInput(newVideoInput)
            }
            
            //Commit all the configuration changes at once
            session.commitConfiguration()
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
        
        selectFilterCategory(with: 1)
    }
    
    @IBAction func tapHumanFilter(_ sender: Any) {
        self.filterType = .pose(filters: self.poseFilters)
        self.filters = self.poseFilters
        preparePoseFilterView()
        appearHumanFilterView()
    }
    
    @IBAction func tapCapture(_ sender: Any) {
        AudioServicesPlaySystemSound(1108);
        
        let storyboard: UIStoryboard = self.storyboard!
        guard let capturedImageViewController: CapturedImageViewController = storyboard.instantiateViewController(withIdentifier: "CapturedImageViewController") as? CapturedImageViewController else { return }
        
        self.present(capturedImageViewController, animated: false, completion: nil)
        
        if let capturedImage = self.libraryImageView.image {
            // 이미지 합치기
            let filteredImage = filterController.imageCompound(backgroundImage: capturedImage,
                                                               previewFrameSize: cameraRatioView.frame.size,
                                                               cameraViewRect: cameraRatioView.frame)
            capturedImageViewController.capturedImage = filteredImage
        } else if let capturedImage = self.capturedImage {
            // 이미지 합치기
            let filteredImage = filterController.imageCompound(backgroundImage: capturedImage,
                                                               previewFrameSize: filterView.frame.size,
                                                               cameraViewRect: cameraRatioView.frame)
            capturedImageViewController.capturedImage = filteredImage
        }
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
    
    enum CameraRatio {
        case ratio(ratio: CGFloat)
        case full
    }
    
    var cameraRatio: CameraRatio = .full
    
    @IBAction func tapScale(_ sender: Any) {
        topScaleView.alpha = 0
        if let button: UIButton = sender as? UIButton {
            if button.tag == 1 { // 1:1
                updateCameraRatio(with: .ratio(ratio: 1))
            } else if button.tag == 2 {
                updateCameraRatio(with: .ratio(ratio: 9/16))
            } else if button.tag == 3 {
                updateCameraRatio(with: .ratio(ratio: 3/4))
            } else if button.tag == 4 {
                updateCameraRatio(with: .full)
            } else if button.tag == 5 {
                updateCameraRatio(with: .ratio(ratio: 8/3))
            }
            
            ratioButtonStackView.subviews.forEach({
                if let btn = $0 as? UIButton { btn.isSelected = $0.tag == button.tag ? true : false }
            })
        }
        
        UIView.animate(withDuration: 0.25) {
            self.cameraRatioView.layoutIfNeeded()
        }
    }
    
    func updateCameraRatio(with ratio: CameraRatio) {
        if let cameraRatioConstraint = cameraRatioConstraint {
            cameraRatioConstraint.isActive = false
            // cameraRatioView.removeConstraint(cameraRatioConstraint)
        }
        
        cameraRatio = ratio
        
        switch ratio {
        case .ratio(let ratio):
            cameraRatioConstraint = cameraRatioView.widthAnchor.constraint(equalTo: cameraRatioView.heightAnchor, multiplier: ratio)
            cameraRatioConstraint?.isActive = true
        case .full:
            cameraRatioConstraint?.isActive = false
            cameraRatioConstraint = nil
        }
    }
    
    @IBAction func tapFilterClose(_ sender: Any) {
        disappearFilterView()
    }
    
    @IBAction func tapFilterCategory(_ sender: Any) {
        if let button: UIButton = sender as? UIButton {
            print(button.tag)
            selectFilterCategory(with: button.tag)
        }
    }
    
    func selectFilterCategory(with index: Int) {
        reloadFilterCategory(with: index)
        
        // button select
        filterTypeStackView.subviews.forEach({
            if let btn: UIButton = $0 as? UIButton,
                btn.tag != 0 {
                btn.isSelected = btn.tag == index ? true : false
            }
        })
    }
    
    func reloadFilterCategory(with index: Int) {
        if index == 1 {
            self.filterType = .human(filters: self.humanFilters)
            self.filters = self.humanFilters
        } else if index == 2 {
            self.filterType = .text(filters: self.textFilters)
            self.filters = self.textFilters
        } else if index == 3 {
            self.filterType = .funny(filters: self.funnyFilters)
            self.filters = self.funnyFilters
        } else if index == 4 {
            self.filterType = .background(filters: self.backgroundFilters)
            self.filters = self.backgroundFilters
        } else {
            self.filterType = .none
            self.filters = []
        }
        
        self.filterCollectionview.reloadData()
    }
    
    func setFilterGroup(filters: [Filter]) {
        
    }
    
    func prepareTimeFilterView() {
        //filterTypeStackView.subviews.forEach({ if $0.tag != 0 { $0.alpha = 1 } })
        
    }
    
    func preparePoseFilterView() {
        //filterTypeStackView.subviews.forEach({ if $0.tag != 0 { $0.alpha = 0 } })
    }
    
    func appearTimeFilterView() {
        //self.currentFilterInfos = self.timeFilterInfos
        self.filterCollectionview.reloadData()
        
        self.bottomBlurView.alpha = 1
        
        self.filterTypeStackView.subviews.forEach({$0.alpha = ($0.tag == 0 || $0.tag == 1) ? 1 : 0})
    }
    
    func appearHumanFilterView() {
        //self.currentFilterInfos = self.humanFilterInfos
        self.filterCollectionview.reloadData()
        
        self.bottomBlurView.alpha = 1
        
        self.filterTypeStackView.subviews.forEach({$0.alpha = ($0.tag == 0) ? 1 : 0})
    }
    
    func disappearFilterView() {
        self.bottomBlurView.alpha = 0
        self.filterType = .none
        self.filters = []
    }
    
    func setPhotoLibraryImage(image: UIImage) {
        libraryImageView.image = image
        libraryImageCloseButton.alpha = 1
        topView.alpha = 0
        captureSession?.stopRunning()
        
        let ratio: CGFloat = image.size.width / image.size.height
        
        if let cameraRatioConstraint = cameraRatioConstraint {
            cameraRatioConstraint.isActive = false
            // cameraRatioView.removeConstraint(cameraRatioConstraint)
        }
        
        cameraRatioConstraint = cameraRatioView.widthAnchor.constraint(equalTo: cameraRatioView.heightAnchor, multiplier: ratio)
        cameraRatioConstraint?.isActive = true
        
        view.bringSubviewToFront(filterView)
        view.bringSubviewToFront(ratioTopView)
        view.bringSubviewToFront(ratioBottomView)
        view.bringSubviewToFront(topScaleView)
        view.bringSubviewToFront(libraryImageCloseButton)
        view.bringSubviewToFront(topView)
        view.bringSubviewToFront(bottomView)
        view.bringSubviewToFront(bottomBlurView)
    }
    
    func setVideoPreviewImage() {
        libraryImageView.image = nil
        libraryImageCloseButton.alpha = 0
        topView.alpha = 1
        captureSession?.startRunning()
        
        updateCameraRatio(with: cameraRatio)
        
        view.bringSubviewToFront(previewView)
        view.bringSubviewToFront(filterView)
        view.bringSubviewToFront(ratioTopView)
        view.bringSubviewToFront(ratioBottomView)
        view.bringSubviewToFront(topScaleView)
        view.bringSubviewToFront(libraryImageCloseButton)
        view.bringSubviewToFront(topView)
        view.bringSubviewToFront(bottomView)
        view.bringSubviewToFront(bottomBlurView)
    }
    
    @IBAction func tapLibraryImageClose(_ sender: Any) {
        setVideoPreviewImage()
    }
    @IBAction func tapClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            setPhotoLibraryImage(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated:  true, completion: nil)
    }
}

extension CameraViewController: UICollectionViewDelegate {
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

extension CameraViewController: UICollectionViewDataSource {
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

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        guard let visionModel = self.visionModel else {
            return
        }
        
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        self.capturedImage = UIImage.convert(cimage: ciimage)
        
        // ================ human filter 아니면 SSD 사용 X ================
        guard filterController.shouldHumanTracking() else { return }
        
        var requestOptions:[VNImageOption : Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(EXIFOrientation.rightTop.rawValue))
        
        let trackingRequest = VNCoreMLRequest(model: visionModel) { (request, error) in
            guard let predictions: [Prediction] = self.processClassifications(for: request, error: error) else { return }
            
            if let classNames = self.ssdPostProcessor.classNames,
                let prediction = predictions
                    .filter({classNames[$0.detectedClass]=="person"})
                    .max(by: {self.sigmoid($0.score) < self.sigmoid($1.score)}) {
                
                self.detected(prediction: prediction)
//                for debug
//                DispatchQueue.main.async {
//                    self.drawBoxes(predictions: [prediction])
//                }
            } else {
//                for debug
//                self.drawBoxes(predictions: [])
            }
        }
        trackingRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        
        
        do {
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation!, options: requestOptions)
            try imageRequestHandler.perform([trackingRequest])
        } catch {
            print(error)
            
        }
    }
}

extension CameraViewController {
    func detected(prediction: Prediction) {
        
        let rect = prediction.finalPrediction.toCGRect(imgWidth: self.screenWidth!, imgHeight: self.screenWidth!, xOffset: 0, yOffset: (self.screenHeight! - self.screenWidth!)/2)
        let fixedRect = CGRect(x: rect.origin.x - CGFloat(horizonalSpace!), y: rect.origin.y,
                               width: rect.width, height: rect.height)
        self.capturedRect = fixedRect
        
        let confidenct = self.sigmoid(prediction.score)
        DispatchQueue.main.async {
            self.filterController.detectdHuman(rect: fixedRect, confidence: confidenct)
        }
    }
}

// Vision Helper (왠만하면 건드리지 않는걸 추천합니다.)
extension CameraViewController {
    func setupBoxes() {
        // Create shape layers for the bounding boxes.
        for _ in 0..<numBoxes {
            let box = BoundingBox()
            box.addToLayer(view.layer)
            self.boundingBoxes.append(box)
        }
    }
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: ssd_mobilenet_feature_extractor().model)
            else { fatalError("Can't load VisionML model") }
        self.visionModel = visionModel
    }
    
    func processClassifications(for request: VNRequest, error: Error?) -> [Prediction]? {
        guard let results = request.results as? [VNCoreMLFeatureValueObservation] else {
            return nil
        }
        guard results.count == 2 else {
            return nil
        }
        guard let boxPredictions = results[1].featureValue.multiArrayValue,
            let classPredictions = results[0].featureValue.multiArrayValue else {
                return nil
        }
        
        let predictions = self.ssdPostProcessor.postprocess(boxPredictions: boxPredictions, classPredictions: classPredictions)
        return predictions
    }
    
    // for debug
    func drawBoxes(predictions: [Prediction]) {
        guard let classNames = self.ssdPostProcessor.classNames else { return }
        
        for (index, prediction) in predictions.enumerated() {
            
            let classifiedLabel = classNames[prediction.detectedClass]
            if classifiedLabel != "person" {continue;}
            
            //print("Class: \(classifiedLabel)")
            
            let textColor: UIColor
            let textLabel = String(format: "%.2f - %@", self.sigmoid(prediction.score), classNames[prediction.detectedClass])
            
            
            
            textColor = UIColor.black
            let rect = prediction.finalPrediction.toCGRect(imgWidth: self.screenWidth!, imgHeight: self.screenWidth!, xOffset: 0, yOffset: (self.screenHeight! - self.screenWidth!)/2)
            let fixedRect = CGRect(x: rect.origin.x - CGFloat(horizonalSpace!), y: rect.origin.y,
                                   width: rect.width, height: rect.height)
            //print(fixedRect)
            self.boundingBoxes[index].show(frame: fixedRect,
                                           label: textLabel,
                                           color: UIColor.red, textColor: textColor)
            
        }
        for index in predictions.count..<self.numBoxes {
            self.boundingBoxes[index].hide()
        }
    }
    
    
    func sigmoid(_ val:Double) -> Double {
        return 1.0/(1.0 + exp(-val))
    }
    
    func softmax(_ values:[Double]) -> [Double] {
        if values.count == 1 { return [1.0]}
        guard let maxValue = values.max() else {
            fatalError("Softmax error")
        }
        let expValues = values.map { exp($0 - maxValue)}
        let expSum = expValues.reduce(0, +)
        return expValues.map({$0/expSum})
    }
    
    public static func softmax2(_ x: [Double]) -> [Double] {
        var x:[Float] = x.compactMap{Float($0)}
        let len = vDSP_Length(x.count)
        
        // Find the maximum value in the input array.
        var max: Float = 0
        vDSP_maxv(x, 1, &max, len)
        
        // Subtract the maximum from all the elements in the array.
        // Now the highest value in the array is 0.
        max = -max
        vDSP_vsadd(x, 1, &max, &x, 1, len)
        
        // Exponentiate all the elements in the array.
        var count = Int32(x.count)
        vvexpf(&x, x, &count)
        
        // Compute the sum of all exponentiated values.
        var sum: Float = 0
        vDSP_sve(x, 1, &sum, len)
        
        // Divide each element by the sum. This normalizes the array contents
        // so that they all add up to 1.
        vDSP_vsdiv(x, 1, &sum, &x, 1, len)
        
        let y:[Double] = x.compactMap{Double($0)}
        return y
    }
    
    enum EXIFOrientation : Int32 {
        case topLeft = 1
        case topRight
        case bottomRight
        case bottomLeft
        case leftTop
        case rightTop
        case rightBottom
        case leftBottom
        
        var isReflect:Bool {
            switch self {
            case .topLeft,.bottomRight,.rightTop,.leftBottom: return false
            default: return true
            }
        }
    }
    
    func compensatingEXIFOrientation(deviceOrientation:UIDeviceOrientation) -> EXIFOrientation
    {
        switch (deviceOrientation) {
        case (.landscapeRight): return .bottomRight
        case (.landscapeLeft): return .topLeft
        case (.portrait): return .rightTop
        case (.portraitUpsideDown): return .leftBottom
            
        case (.faceUp): return .rightTop
        case (.faceDown): return .rightTop
        case (_): fallthrough
        default:
            NSLog("Called in unrecognized orientation")
            return .rightTop
        }
    }
}

extension UIImage {
    static func convert(cimage: CIImage) -> UIImage {
        let context: CIContext = CIContext.init(options: nil)
        let cgImage: CGImage = context.createCGImage(cimage, from: cimage.extent)!
//        let image: UIImage = UIImage.init(cgImage: cgImage)
        let image: UIImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: UIImage.Orientation.right)
        return image
    }
}

