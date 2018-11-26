//
//  FilterController.swift
//  empathy-ios
//
//  Created by GwakDoyoung on 07/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class FilterController {
    var superView: UIView?
    
    var timeFilterView: FilterImageView?
    var poseFilterView: FilterImageView?
    
    func putTimeFilter(with filter: Filter) {
        if timeFilterView == nil {
            timeFilterView = FilterImageView()
            timeFilterView?.closeButton?.addTarget(self, action: #selector(self.tapTimeFilterClose), for: UIControl.Event.touchUpInside)
            if let timeFilterView = timeFilterView {
                self.superView?.addSubview(timeFilterView)
            }
        }
        
        guard let filterView = self.timeFilterView else {
            return
        }
        
        filterView.alpha = 1
        filterView.set(filter: filter)
    }
    
    func putPoseFilter(with filter: Filter) {
        if poseFilterView == nil {
            poseFilterView = FilterImageView()
            poseFilterView?.closeButton?.addTarget(self, action: #selector(self.tapPoseFilterClose), for: UIControl.Event.touchUpInside)
            if let poseFilterView = poseFilterView {
                self.superView?.addSubview(poseFilterView)
            }
        }
        
        guard let filterView = self.poseFilterView else {
            return
        }
        
        filterView.alpha = 1
        filterView.set(filter: filter)
    }
    
    @objc func tapPoseFilterClose(_ sender: Any) {
        poseFilterView?.alpha = 0
    }
    
    @objc func tapTimeFilterClose(_ sender: Any) {
        timeFilterView?.alpha = 0
    }
    
    func detectdHuman(rect: CGRect, confidence: Double) {
        guard let timeFilterView = timeFilterView, timeFilterView.alpha == 1 else {
            print("not selected time filter")
            return
        }
        
        timeFilterView.detectdHuman(rect: rect, confidence: confidence)
    }
    
    func imageCompound(backgroundImage: UIImage, previewFrameSize: CGSize, cameraViewRect: CGRect) -> UIImage? {
        let bottomImage: UIImage = backgroundImage
        let newWidth: CGFloat = bottomImage.size.height * previewFrameSize.width / previewFrameSize.height
        let cameraViewRatio: CGFloat = cameraViewRect.size.width / cameraViewRect.size.height
        var croppingImageRect: CGRect = CGRect(x: (backgroundImage.size.width - newWidth)/2,
                                               y: 0, width: newWidth, height: backgroundImage.size.height)
        
        //print("croppingImageRect:", croppingImageRect)
        //print("bottomImage.size:", bottomImage.size)
        let newHeight: CGFloat = croppingImageRect.width / cameraViewRatio
        croppingImageRect.origin.y = (croppingImageRect.height - newHeight) / 2
        croppingImageRect.size.height = newHeight
        
        let croppedBottomImage: UIImage = bottomImage.croppedImage(inRect: croppingImageRect)
        //print("croppedBottomImage.size:", croppedBottomImage.size)
        if let topImage: UIImage = timeFilterView?.imageView?.image {
            let targetViewRect = cameraViewRect
            let (topImageCenterRate, topImageSizeRate) = timeFilterView?.rateCenterAndSize(targetViewRect: targetViewRect) ?? (.zero, .zero)
            
            return croppedBottomImage.compound(topImage: topImage,
                                               topImageCenter: topImageCenterRate,
                                               topImageSize: topImageSizeRate)
        } else {
            return croppedBottomImage
        }
        
    }
}

extension UIImage {
    // self와 topImage를 합쳐서 새로운 이미지 반환
    func compound(topImage: UIImage, topImageCenter: CGPoint, topImageSize: CGSize) -> UIImage? {
        let bottomImage: UIImage = self
        
        // Change here the new image size if you want
        UIGraphicsBeginImageContextWithOptions(bottomImage.size, false, bottomImage.scale)
        
        let bottomRect: CGRect = CGRect(x: 0, y: 0,
                                        width: bottomImage.size.width,
                                        height: bottomImage.size.height)
        // background image rect
        bottomImage.draw(in: bottomRect)
        
        let oldSize: CGSize = bottomImage.size//CGSize(width: oldWidth, height: newSize.height)
        
        //let topImageY: CGFloat = topImageRateRect.origin.x
        let topImageRect: CGRect = CGRect(x: (topImageCenter.x - topImageSize.width/2) * oldSize.width,
                                          y: (topImageCenter.y - topImageSize.height/2) * oldSize.height,
                                          width: topImageSize.width * oldSize.width,
                                          height: topImageSize.height * oldSize.height)
        // foreground image rect
        topImage.draw(in: topImageRect, blendMode: CGBlendMode.normal, alpha:1.0)
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // 어디선가 가져온 cropping 코드
    func croppedImage(inRect rect: CGRect) -> UIImage {
        let rad: (Double) -> CGFloat = { deg in
            return CGFloat(deg / 180.0 * .pi)
        }
        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            let rotation = CGAffineTransform(rotationAngle: rad(90))
            rectTransform = rotation.translatedBy(x: 0, y: -size.height)
        case .right:
            let rotation = CGAffineTransform(rotationAngle: rad(-90))
            rectTransform = rotation.translatedBy(x: -size.width, y: 0)
        case .down:
            let rotation = CGAffineTransform(rotationAngle: rad(-180))
            rectTransform = rotation.translatedBy(x: -size.width, y: -size.height)
        default:
            rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: scale, y: scale)
        let transformedRect = rect.applying(rectTransform)
        let imageRef = cgImage!.cropping(to: transformedRect)!
        let result = UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
        return result
    }
}

class FilterImageView: UIView {
    
    var filter: Filter?
    
    var imageView: UIImageView?
    var rotateScalePanButton: UIImageView?
    var closeButton: UIButton?
    var panGesture: UIPanGestureRecognizer?
    var rotateScalePanGesture: UIPanGestureRecognizer?
    
    var lastRotateAngle: CGFloat?
    var lastScale: CGFloat?
    
    var imageViewRateRect: CGRect {
        var x: CGFloat = (self.center.x)
        x -= (imageView?.frame.width ?? 0)/2
        x /= (self.superview?.frame.width ?? 1)
        
        var y: CGFloat = (self.center.y)
        y -= (imageView?.frame.height ?? 0)/2
        y -= (closeButton?.frame.height ?? 0) / 2
        y /= (self.superview?.frame.height ?? 1)
        
        let w: CGFloat = (imageView?.frame.width ?? 0) / (self.superview?.frame.width ?? 1)
        let h: CGFloat = (imageView?.frame.height ?? 0) / (self.superview?.frame.height ?? 1)
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    func rateCenterAndSize(targetViewRect: CGRect) -> (CGPoint, CGSize) {
        // targetViewRect: 20, 80, 516, 744
        let superViewRect: CGRect = superview?.frame ?? .zero
        
        var x: CGFloat = (self.center.x) + (imageView?.center.x ?? 0) - self.frame.size.width/2
        var y: CGFloat = (self.center.y) + (imageView?.center.y ?? 0) - self.frame.size.height/2
        
        x -= (targetViewRect.origin.x - superViewRect.origin.x)
        y -= (targetViewRect.origin.y - superViewRect.origin.y)
        
        var w: CGFloat = (imageView?.frame.width ?? 0)
        var h: CGFloat = (imageView?.frame.height ?? 0)
        
        x /= (targetViewRect.width)
        y /= (targetViewRect.height)
        w /= (targetViewRect.width)
        h /= (targetViewRect.height)
        
        return (CGPoint(x: x, y: y), CGSize(width: w, height: h))
    }
    
    init() {
        super.init(frame: .zero)
        self.setInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setInit()
    }
    
    func setInit() {
        // for debugging
        //self.layer.borderWidth = 2
        //self.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3).cgColor
        self.clipsToBounds = false
        
        
        imageView = UIImageView(frame: .zero)
        let closeButtonImage = UIImage(named: "filter_close")
        closeButton = UIButton(frame: CGRect(origin: .zero, size: closeButtonImage?.size ?? .zero))
        closeButton?.setImage(closeButtonImage, for: UIControl.State.normal)
        let rotateScaleImage = UIImage(named: "iconRotate")
        rotateScalePanButton = UIImageView(image: rotateScaleImage)
        rotateScalePanButton?.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        rotateScalePanButton?.contentMode = .center
        rotateScalePanButton?.isUserInteractionEnabled = true
        
        if let imageView = imageView {
            self.addSubview(imageView)
        }
        
        if let closeButton = closeButton {
            self.addSubview(closeButton)
        }
        
        if let rotateScalePanButton = rotateScalePanButton {
            self.addSubview(rotateScalePanButton)
        }
        
        self.isUserInteractionEnabled = true
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        if let panGesture = panGesture {
            self.addGestureRecognizer(panGesture)
        }
        
        rotateScalePanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedViewScale(_:)))
        if let rotateScalePanGesture = rotateScalePanGesture {
            self.rotateScalePanButton?.addGestureRecognizer(rotateScalePanGesture)
        }
    }
    
    func set(filter: Filter) {
        self.filter = filter
        
        self.transform = CGAffineTransform.identity
        
        self.lastScale = nil
        self.lastRotateAngle = nil
        
        
        // 이미지 넣기
        guard let image = UIImage(named: filter.imageURL) else { print("no image!!");return; }
        imageView?.image = image
        imageView?.sizeToFit()
        let imageSize = image.size
        
        // auto scale mode
        let targetScale: CGFloat = 0.35
        let scaledW: CGFloat = (self.superview?.frame.width ?? 0) * targetScale
        let scaledH: CGFloat = (self.superview?.frame.height ?? 0) * targetScale
        let scaleRateW: CGFloat = scaledW / imageSize.width
        let scaleRateH: CGFloat = scaledH / imageSize.height
        let minScaleRate: CGFloat = min(scaleRateH, scaleRateW)
        imageView?.frame = CGRect(x: 0, y: 0,
                                  width: imageSize.width * minScaleRate,
                                  height: imageSize.height * minScaleRate)
        
        
        
        let closeButtonX: CGFloat = (imageView?.frame.origin.x ?? 0) + (closeButton?.frame.width ?? 0)/2
        let closeButtonY: CGFloat = (imageView?.frame.height ?? 0) + (closeButton?.frame.height ?? 0)/2
        closeButton?.center = CGPoint(x: closeButtonX, y: closeButtonY)
        let imageViewX: CGFloat = (closeButton?.center.x ?? 0) + (imageView?.frame.width ?? 0)/2
        let imageViewY: CGFloat = (imageView?.frame.height ?? 0)/2 + (closeButton?.frame.height ?? 0)/2
        imageView?.center = CGPoint(x: imageViewX, y: imageViewY)
        if filter.align_left {
            rotateScalePanButton?.center = .zero
            rotateScalePanButton?.alpha = 0
        } else {
            rotateScalePanButton?.alpha = 1
            let rotateScalePanButtonX: CGFloat = (imageView?.frame.origin.x ?? 0) + (imageView?.frame.width ?? 0)
            let rotateScalePanButtonY: CGFloat = (rotateScalePanButton?.frame.height ?? 0)/2
            rotateScalePanButton?.center = CGPoint(x: rotateScalePanButtonX, y: rotateScalePanButtonY)
        }
        
        
        
        updateFrame()
        self.center = CGPoint(x: (self.superview?.frame.width ?? 0)/2 ,
                              y: (self.superview?.frame.height ?? 0)/2)
        
        
        // self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/3)
    }
    
    func updateFrame() {
        // 이미지, 버튼들에대한 frame 설정
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        for subview in subviews {
            maxX = max(maxX, subview.frame.origin.x + subview.frame.width)
            maxY = max(maxY, subview.frame.origin.y + subview.frame.height)
        }
        
        self.frame = CGRect(x: 0, y: 0, width: maxX, height: maxY)
    }
    
    func setImageHeight(height: CGFloat) {
        guard let imageSize = imageView?.image?.size else { return }
        
        let targetImageSize: CGSize = CGSize(width: imageSize.width * height / imageSize.height,
                                             height: height)
        imageView?.frame = CGRect(x: (closeButton?.frame.height ?? 0)/2, y: 0,
                                  width: targetImageSize.width, height: targetImageSize.height)
        
        let closeButtonX: CGFloat = (imageView?.frame.origin.x ?? 0) + (closeButton?.frame.width ?? 0)/2
        let closeButtonY: CGFloat = (imageView?.frame.height ?? 0) + (closeButton?.frame.height ?? 0)/2
        closeButton?.center = CGPoint(x: closeButtonX, y: closeButtonY)
        let imageViewX: CGFloat = (closeButton?.center.x ?? 0) + (imageView?.frame.width ?? 0)/2
        let imageViewY: CGFloat = height/2
        imageView?.center = CGPoint(x: imageViewX, y: imageViewY)
    }
    
    var initialCenter: CGPoint? = nil
    
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        if let superview = self.superview {
            self.bringSubviewToFront(superview)
        }
        let translation = sender.translation(in: self.superview)
        
        if sender.state == .began {
            initialCenter = self.center
        } else if sender.state == .changed {
            if let initialCenter = initialCenter {
                self.center = CGPoint(x: initialCenter.x + translation.x,
                                      y: initialCenter.y + translation.y)
            }
        } else if sender.state == .ended {
            if let initialCenter = initialCenter {
                self.center = CGPoint(x: initialCenter.x + translation.x,
                                      y: initialCenter.y + translation.y)
            }
            initialCenter = nil
        }
    }
    
    @objc func draggedViewScale(_ sender: UIPanGestureRecognizer){
        if let filter = filter, filter.align_left { return }
//        if let superview = self.superview {
//            self.bringSubviewToFront(superview)
//        }
        let translation = sender.translation(in: self.superview)
        
        if sender.state == .began {
            //initialCenter = self.center
        } else if sender.state == .changed {
//            if let initialCenter = initialCenter {
//                self.center = CGPoint(x: initialCenter.x + translation.x,
//                                      y: initialCenter.y + translation.y)
//            }
        } else if sender.state == .ended {
//            if let initialCenter = initialCenter {
//                self.center = CGPoint(x: initialCenter.x + translation.x,
//                                      y: initialCenter.y + translation.y)
//            }
//            initialCenter = nil
        }
        print(translation)
    }
    
    let minimumHieght: CGFloat = 60.0
    
    func detectdHuman(rect: CGRect, confidence: Double) {
        guard let filter = filter, filter.align_left, rect.height > minimumHieght else { return }
        
        switch filter.alignGravity {
        case .center_left:
            setImageHeight(height: rect.height*1.08)
            updateFrame()
            self.center = CGPoint(x: rect.origin.x - (imageView?.frame.width ?? 0)/2,
                                   y: rect.origin.y + rect.height/2 + (closeButton?.frame.height ?? 0)/2)
//        case .center_middle:
        case .center_right:
            setImageHeight(height: rect.height*1.08)
            updateFrame()
            self.center = CGPoint(x: rect.origin.x + rect.width + (imageView?.frame.width ?? 0)/2,
                                  y: rect.origin.y + rect.height/2 + (closeButton?.frame.height ?? 0)/2)
        default:
            break;
        }
    }
    
    
}
