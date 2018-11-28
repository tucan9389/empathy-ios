//
//  FetchMyFeeds.swift
//  empathy-ios
//
//  Created by byungtak on 29/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import Foundation

let DidReceiveMyFeedsNotification: Notification.Name = Notification.Name("DidReceiveMyFeeds")

func fetchMyFeeds(ownerId: Int) {
    guard let url: URL = URL(string: Commons.baseUrl + "/journey/myjourney/\(ownerId)") else {
        return
    }
    
    let session: URLSession = URLSession(configuration: .default)
    let dataTask: URLSessionDataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        
        if let error = error {
            print("data_task_error: \(error.localizedDescription)")
            
            NotificationCenter.default.post(name: DidReceiveNetworkErrorNotification(), object: nil)
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("status_code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                NotificationCenter.default.post(name: DidReceiveNetworkErrorNotification(), object: nil)
                return
            }
        }
        
        guard let data = data else {
            return
        }
        
        do {
            let myFeedsApiResponse: MyFeedsApiResponse = try JSONDecoder().decode(MyFeedsApiResponse.self, from: data)
            
            NotificationCenter.default.post(name: DidReceiveMyFeedsNotification, object: nil, userInfo: ["myFeeds" : myFeedsApiResponse.myFeeds])
        } catch(let err) {
            print("fetchcomment_jsondecoder_error:\(err.localizedDescription)")
            
            NotificationCenter.default.post(name: DidReceiveNetworkErrorNotification(), object: nil)
        }
    }
    
    dataTask.resume()
}

