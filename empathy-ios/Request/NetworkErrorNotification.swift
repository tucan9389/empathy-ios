//
//  NetworkErrorNotification.swift
//  empathy-ios
//
//  Created by byungtak on 29/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import Foundation


func DidReceiveNetworkErrorNotification() -> Notification.Name {
    let DidReceiveNetworkErrorNotification: Notification.Name = Notification.Name("ErrorHandling")
    
    return DidReceiveNetworkErrorNotification
}
