//
//  TMapTestViewController.swift
//  empathy-ios
//
//  Created by GwakDoyoung on 01/12/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class TMapTestViewController: UIViewController {

    @IBOutlet weak var tmapView: TMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tmapView.setMapType(STANDARD)
        tmapView.setSKTMapApiKey(TMAP_IDS.KEY)
        //TMapTapi.setSKTMapAuthenticationWith(self, apiKey: TMAP_IDS.KEY)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tmapView.setCenter(CLLocationCoordinate2D(latitude: 129, longitude: 32), animated: true)
    }
}

extension TMapTestViewController: TMapTapiDelegate {
    
}

extension TMapTestViewController: TMapViewDelegate{
    
}

extension TMapTestViewController: TMapGpsManagerDelegate {
    func locationChanged(_ newTmp: TMapPoint!) {
        
    }
    
    func headingChanged(_ heading: Double) {
        
    }
}
