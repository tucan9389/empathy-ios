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
    
    private var feedDetail: FeedDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeView()
        initializeNotificationObserver()
        
//        fetchFeedDetail(targetId: 1)
    }
    
    @objc func didReceiveDetailFeedNotification(_ noti: Notification) {
        guard let feedDetail: FeedDetail = noti.userInfo?["feedDetail"] as? FeedDetail else {
            return
        }
        
        self.feedDetail = feedDetail
    }
    
    private func initializeView() {
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
    }

    private func initializeNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveDetailFeedNotification(_:)), name: DidReceiveFeedDetailNotification, object: nil)
    }

}
