//
//  FeedDetail.swift
//  empathy-ios
//
//  Created by byungtak on 29/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import Foundation

//{
//    "contents": "string",
//    "creationTime": "string",
//    "imageUrl": "string",
//    "journeyId": 0,
//    "location": "string",
//    "ownerProfileUrl": "string",
//    "title": "string"
//}
struct FeedDetail: Codable {
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
