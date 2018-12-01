//
//  MainFeedViewController.swift
//  empathy-ios
//
//  Created by Suji Kim on 25/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class MainFeedViewController: UIViewController {

    @IBOutlet weak var peopleJourneyCollectionView: UICollectionView!
    @IBOutlet weak var smileLabel: UILabel!
    
    var userInfo:UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        smileLabel.transform = CGAffineTransform(rotationAngle:  CGFloat.pi / 2)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainFeedViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = peopleJourneyCollectionView.dequeueReusableCell(withReuseIdentifier: "peopleJourney", for: indexPath) as? MainFeedCollectionViewCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}

extension MainFeedViewController {
    func requestMainFeedInfo(){
        
    }
}
