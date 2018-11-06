//
//  FilterCollectionView.swift
//  empathy-ios
//
//  Created by GwakDoyoung on 06/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class FilterCollectionView: UICollectionView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

class FilterCollectionCell: UICollectionViewCell {
    @IBOutlet weak var previewImageView: UIImageView!
    
    var info: FilterInfo? {
        didSet {
            if let info = info {
                self.previewImageView.image = info.image
            }
        }
    }
}

class FilterInfo {
    let image: UIImage?
    
    init(imageName: String?) {
        if let imageName = imageName {
            self.image = UIImage(named: imageName)
        } else {
            self.image = nil
        }
    }
    
    init(image: UIImage?) {
        self.image = image
    }
}
