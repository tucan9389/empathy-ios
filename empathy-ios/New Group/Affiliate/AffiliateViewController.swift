//
//  AffiliateViewController.swift
//  empathy-ios
//
//  Created by Suji Kim on 27/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class AffiliateViewController: UIViewController {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var affiliateInfo: [String : Any?] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let baseURL: String = "http://ec2-13-209-245-253.ap-northeast-2.compute.amazonaws.com:8080"
        let urlPath: String = "/info/alliance"
        
        Alamofire.request("\(baseURL)\(urlPath)").responseJSON { response in
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result
//            print(response.result.value)
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                self.affiliateInfo = json as? [String : Any?] ?? [:]
                
                DispatchQueue.main.async {
                    self.update(affiliateInfo: self.affiliateInfo)
                }
            }
            //self.touristTableView.reloadData()
        }
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "gotoDetail",
            let destVC = segue.destination as? AffiliateDetailViewController {
            
        }
    }
 
    
    func update(affiliateInfo: [String : Any?]) {
        if let urlString = affiliateInfo["imageURL"] as? String,
            let url = URL(string: urlString) {
            self.bgImageView.kf.setImage(with: url)
        }
        if let locatiionStr = affiliateInfo["locatiionStr"] as? String {
            self.addressLabel.text = locatiionStr
        }
        if let name = affiliateInfo["name"] as? String {
            self.titleLabel.text = name
        }
        if let kind = affiliateInfo["kind"] as? String {
            self.subtitleLabel.text = kind
        }
    }

    
}

