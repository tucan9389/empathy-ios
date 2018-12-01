//
//  MainFeedCollectionViewCell.swift
//  empathy-ios
//
//  Created by Suji Kim on 01/12/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class MainFeedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var journeyImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    func config(_ name:String, _ userImageURL:String, journeyImageURL: String) {
        userNameLabel.text = name
        if let imageURL = URL(string: userImageURL), let journeyURL = URL(string: journeyImageURL) {
            userImageView.kf.setImage(with: imageURL)
            journeyImageView.kf.setImage(with: journeyURL)
        }
    }
}
