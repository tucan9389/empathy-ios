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



class Filter: Decodable {
    enum FilterKeys: String, CodingKey {
        case type_id = "type_id"
        case type = "type"
        case name = "name"
        case imageURL = "imageURL"
        case standard = "standard"
        case align_left = "align-left"
        case gravity = "gravity"
    }
    
    let type_id: Int //"type_id" : 1,
    let type: String //"type" : "human" ,
    let name: String //"name" : "human_1" ,
    let imageURL: String //"imageURL" : "b_1" ,
    let standard: String //"standard" : "1" ,
    let align_left: Bool //"align-left" : true ,
    let gravity: String //"gravity" : "bottom-center"
    
    
    init(type_id: Int, type: String, name: String,
         imageURL: String, standard: String,
         align_left: Bool, gravity: String) {
        self.type_id = type_id
        self.type = type
        self.name = name
        self.imageURL = imageURL
        self.standard = standard
        self.align_left = align_left
        self.gravity = gravity
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FilterKeys.self)
        let type_id = try container.decode(Int.self, forKey: .type_id)
        let type = try container.decode(String.self, forKey: .type)
        let name = try container.decode(String.self, forKey: .name)
        let imageURL = try container.decode(String.self, forKey: .imageURL)
        let standard = try container.decode(String.self, forKey: .standard)
        let align_left = try container.decode(Bool.self, forKey: .align_left)
        let gravity = try container.decode(String.self, forKey: .gravity)
        
        self.init(type_id: type_id, type: type, name: name,
                   imageURL: imageURL, standard: standard,
                   align_left: align_left, gravity: gravity)
    }
    
    enum Gravity {
        case bottom_left
        case center_left
        case top_left
        
        case bottom_right
        case center_right
        case top_right
        
        case bottom_middle
        case center_middle
        case top_middle
        
        case none
    }
    
    var alignGravity: Gravity {
        if gravity == "bottom-left" { return .bottom_left }
        else if gravity == "center-left" { return .center_left }
        else if gravity == "top-left" { return .top_left }
        else if gravity == "bottom-right" { return .bottom_right }
        else if gravity == "center-right" { return .center_right }
        else if gravity == "top-right" { return .top_right }
        else if gravity == "bottom-middle" { return .bottom_middle }
        else if gravity == "center-middle" { return .center_middle }
        else if gravity == "top-middle" { return .top_middle }
        else { return .none }
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
