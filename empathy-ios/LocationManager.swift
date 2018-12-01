//
//  File.swift
//  empathy-ios
//
//  Created by GwakDoyoung on 02/12/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var locValue: CLLocationCoordinate2D?
    
    override init() {
        super.init()
    }
    
    typealias LocationCallback = ((CLLocationCoordinate2D?) -> ())
    fileprivate var complete: LocationCallback? = nil
    
    func requestLocation(complete: @escaping LocationCallback) {
        if let locValue = self.locValue {
            complete(locValue)
        } else {
            self.complete = complete
            // Ask for Authorisation from the User.
            self.locationManager.requestAlwaysAuthorization()
            
            // For use in foreground
            self.locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    fileprivate let dict = [
        "Seoul": [37.56667, 126.97806],
        "Incheon": [37.45639, 126.70528],
        "Daejeon": [37.56667, 126.97806],
        "Daegue": [36.35111, 127.38500],
        "Gwangju": [35.15972, 126.85306],
        "Busan": [35.17944, 129.07556],
        "Ulsan": [35.53889, 129.31667],
        "Sejong": [36.48750, 127.28167],
        "GyeonggiDo": [37.56667, 126.97806],
        "GangwonDo": [37.8633724,127.1265699],
        "ChungcheongbukDo": [36.6371934,127.4064467],
        "ChungcheongnamDo": [36.537139,126.2333762],
        "GyeongsangbukDo": [36.5566144,128.7244566],
        "GyeongsangnamDo": [35.1813852,127.8305914],
        "Jeollabukdo": [37.56667, 126.97806],
        "JeollanamDo": [37.56667, 126.97806],
        "Jejudo": [33.50000, 126.51667],
    ]
    
    func getNearestLocationEnum(location: CLLocationCoordinate2D) -> LocationEnum {
        var minLocal = ""
        var min = 100000000.0
        for local in dict.keys {
            if let position = dict[local] {
                let dist = pow((position[0] - location.latitude), 2) + pow((position[1] - location.longitude), 2)
                if min > dist {
                    min = dist
                    minLocal = local
                }
            }
        }
        
        if minLocal == "Seoul" || minLocal == "GyeonggiDo" {
            if let position = dict[minLocal] {
                var dist = pow((position[0] - location.latitude), 2) + pow((position[1] - location.longitude), 2)
                dist = sqrt(dist)
                if dist < 127.1755433 - 126.8494651 {
                    return .Seoul
                } else {
                    return .GyeonggiDo
                }
            }
        } else {
            return LocationEnum(rawValue: minLocal) ?? .none
        }
        
        return .none
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        if self.locValue == nil {
            self.locValue = locValue
            if let complete = self.complete {
                complete(self.locValue)
            }
        }
    }
}
