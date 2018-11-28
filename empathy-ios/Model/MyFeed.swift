//
//  MyFeed.swift
//  empathy-ios
//
//  Created by byungtak on 25/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import Foundation

struct MyFeedsApiResponse: Codable {
    let myFeeds = [MyFeed]()
    
    enum CodingKeys: String, CodingKey {
        case myFeeds
    }
}

struct MyFeed: Codable {
    let contents: String
    let creationTime: String
    let imageUrl: String
    let journeyId: Int
    let location: String
    let ownerProfileUrl: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case contents, creationTime, imageUrl, journeyId, location, ownerProfileUrl, title
    }
}
