//
//  MainFeed.swift
//  empathy-ios
//
//  Created by Suji Kim on 01/12/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import Foundation

struct MainFeed: Codable {
    let enumStr:String
    let imageURL:String
    let isFirst:String
    let mainText:String
    let otherPeopleList:[OtherPeopleJourney]
    let weekday:String
}
