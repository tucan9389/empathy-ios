//
//  MainFeedViewController.swift
//  empathy-ios
//
//  Created by Suji Kim on 25/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import Alamofire

class MainFeedViewController: UIViewController {

    @IBOutlet weak var peopleJourneyCollectionView: UICollectionView!
    @IBOutlet weak var smileLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var placeHolderView: UIView!
    @IBOutlet weak var myJourneyView: UIView!
    @IBOutlet weak var myJourneyImageView: UIImageView!
    @IBOutlet weak var myJourneyLabel: UILabel!
    
    var userInfo:UserInfo?
    var mainFeedInfo:MainFeed?
    
    var random:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        smileLabel.transform = CGAffineTransform(rotationAngle:  CGFloat.pi / 2)
        if let id = userInfo?.userId {
            requestMainFeedInfo("Seoul", String(id))
        }
        
    }
    
    
    @IBAction func tapToursiteButton(_ sender: Any) {
        random = Int.random(in: 0 ... 10)
        if let randomNumber = random {
            if randomNumber%2 == 0 {
                if let viewController = UIStoryboard.init(name: "TouristSite", bundle: Bundle.main).instantiateViewController(withIdentifier: "TouristSiteViewController") as? TouristSiteViewController {
//                    self.navigationController?.pushViewController(viewController, animated: true)
                    present(viewController, animated: true, completion: nil)
                }
                
            }
            else {
                if let viewController = UIStoryboard.init(name: "Affiliate", bundle: Bundle.main).instantiateViewController(withIdentifier: "AffiliateViewController") as? AffiliateViewController {
//                    self.navigationController?.pushViewController(viewController, animated: true)
                    present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMyFeed") || (segue.identifier == "toMyFeed2"), let destination = segue.destination as? MyFeedViewController {
            destination.userInfo = self.userInfo
        }
    }
}

extension MainFeedViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfItem = mainFeedInfo?.otherPeopleList.count {
            if numberOfItem < 18 {
                return numberOfItem
            }
            else {
                return 18
            }
        }
        else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = peopleJourneyCollectionView.dequeueReusableCell(withReuseIdentifier: "peopleJourney", for: indexPath) as? MainFeedCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let info = mainFeedInfo?.otherPeopleList[indexPath.row] {
            if let ownerImageURLString = info.ownerProfileUrl as? String, let journeyImageURLString = info.imageUrl as? String {
                cell.config(info.ownerName, ownerImageURLString, journeyImageURL: journeyImageURLString)
            }
        }
        return cell
    }
}

extension MainFeedViewController {
    func requestMainFeedInfo(_ city:String, _ userId:String){
        if let user = userInfo {
            let urlPath = Commons.baseUrl + "/journey/main/\(city)/\(userId)"
            Alamofire.request(urlPath).responseJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                if let json = response.result.value as? [String:Any] {
                    print("JSON: \(json)") // serialized json response
                    
                    if let enumStr = json["enumStr"] as? String, let mainText = json["mainText"] as? String, let imageURL = json["imageURL"] as? String, let isFirst = json["isFirst"] as? String, let weekday = json["weekday"] as? String {
                        if let otherPeopleLists = json["otherPeopleList"] as? [OtherPeopleJourney] {
                            if otherPeopleLists.count == 0 {
                                self.mainFeedInfo = MainFeed.init(enumStr: enumStr, imageURL: imageURL, isFirst: isFirst, mainText: mainText, otherPeopleList: [], weekday: weekday)
                            }
                            else {
                                self.mainFeedInfo = MainFeed.init(enumStr: enumStr, imageURL: imageURL, isFirst: isFirst, mainText: mainText, otherPeopleList: otherPeopleLists, weekday: weekday)
                            }
                        }
                        if let info = self.mainFeedInfo {
                            self.update(mainfeedInfo: info)
                        }
                    }
                }
            }
        }
        
    }
    
    func update(mainfeedInfo : MainFeed) {
        if mainfeedInfo.isFirst == "true" {
            placeHolderView.isHidden = false
            myJourneyView.isHidden = true
        }
        else {
            placeHolderView.isHidden = true
            myJourneyView.isHidden = false
            myJourneyLabel.text = mainfeedInfo.mainText
            if  let journeyURL = URL(string: mainfeedInfo.imageURL) {
                myJourneyImageView.kf.setImage(with: journeyURL)
            }
        }
        cityLabel.text = mainfeedInfo.enumStr
        weekdayLabel.text = mainfeedInfo.weekday
        
        peopleJourneyCollectionView.reloadData()
    }
}
