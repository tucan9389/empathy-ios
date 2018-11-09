//
//  RoundedButton.swift
//  empathy-ios
//
//  Created by Suji Kim on 09/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class RoundedButton:UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2 //테두리가 26이 됨
    }
}
