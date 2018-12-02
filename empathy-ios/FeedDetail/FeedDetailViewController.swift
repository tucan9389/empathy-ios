//
//  FeedDetailViewController.swift
//  empathy-ios
//
//  Created by byungtak on 29/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class FeedDetailViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var journeyImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    private var feedDetail: FeedDetail?
    
    var journeyDetailId:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeView()
//        initializeNotificationObserver()
//        fetchFeedDetail(targetId: 1)
    }
    
    @IBAction func tapBackAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func update(_ journeydetail:MyJourney) {
        
    }
    
//    @objc func didReceiveDetailFeedNotification(_ noti: Notification) {
//        guard let feedDetail: FeedDetail = noti.userInfo?["feedDetail"] as? FeedDetail else {
//            return
//        }
//
//        self.feedDetail = feedDetail
//    }
    
    private func initializeView() {
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
    }

//    private func initializeNotificationObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveDetailFeedNotification(_:)), name: DidReceiveFeedDetailNotification, object: nil)
//    }

}
