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
    
    func putTimeFilter(with info: FilterInfo) {
        
    }
    
    func putPoseFilter(with info: FilterInfo) {
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
        filterView.set(info: info)
    }
    
    @objc func tapPoseFilterClose(_ sender: Any) {
        //print("tapPoseFilterClose!!")
        poseFilterView?.alpha = 0
    }
    
    
}

class FilterImageView: UIView {
    var imageView: UIImageView?
    var rotateScalePanButton: UIImageView?
    var closeButton: UIButton?
    var panGesture: UIPanGestureRecognizer?
    var rotateScalePanGesture: UIPanGestureRecognizer?
    
    var lastRotateAngle: CGFloat?
    var lastScale: CGFloat?
    
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
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3).cgColor
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
    
    func set(info: FilterInfo) {
        self.transform = CGAffineTransform.identity
        
        self.lastScale = nil
        self.lastRotateAngle = nil
        
        // 이미지 넣기
        if let image = info.image {
            imageView?.image = image
        }
        imageView?.sizeToFit()
        
        // auto scale mode
        if let image = info.image {
            let targetScale: CGFloat = 0.35
            let scaledW: CGFloat = (self.superview?.frame.width ?? 0) * targetScale
            let scaledH: CGFloat = (self.superview?.frame.height ?? 0) * targetScale
            let scaleRateW: CGFloat = scaledW / image.size.width
            let scaleRateH: CGFloat = scaledH / image.size.height
            let minScaleRate: CGFloat = min(scaleRateH, scaleRateW)
            imageView?.frame = CGRect(x: 0, y: 0,
                                      width: image.size.width * minScaleRate,
                                      height: image.size.height * minScaleRate)
        }
        
        
        
        let closeButtonX: CGFloat = (imageView?.frame.origin.x ?? 0) + (closeButton?.frame.width ?? 0)/2
        let closeButtonY: CGFloat = (imageView?.frame.height ?? 0) + (closeButton?.frame.height ?? 0)/2
        closeButton?.center = CGPoint(x: closeButtonX, y: closeButtonY)
        let imageViewX: CGFloat = (closeButton?.center.x ?? 0) + (imageView?.frame.width ?? 0)/2
        let imageViewY: CGFloat = (imageView?.frame.height ?? 0)/2 + (closeButton?.frame.height ?? 0)/2
        imageView?.center = CGPoint(x: imageViewX, y: imageViewY)
        let rotateScalePanButtonX: CGFloat = (imageView?.frame.origin.x ?? 0) + (imageView?.frame.width ?? 0)
        let rotateScalePanButtonY: CGFloat = (rotateScalePanButton?.frame.height ?? 0)/2
        rotateScalePanButton?.center = CGPoint(x: rotateScalePanButtonX, y: rotateScalePanButtonY)
        
        
        // 이미지, 버튼들에대한 frame 설정
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        for subview in subviews {
            maxX = max(maxX, subview.frame.origin.x + subview.frame.width)
            maxY = max(maxY, subview.frame.origin.y + subview.frame.height)
        }
        
        self.frame = CGRect(x: 0, y: 0, width: maxX, height: maxY)
        self.center = CGPoint(x: (self.superview?.frame.width ?? 0)/2 ,
                              y: (self.superview?.frame.height ?? 0)/2)
        
        
        // self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/3)
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
    
    @objc func draggedViewScale(_ sender:UIPanGestureRecognizer){
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
    
}
