//
//  TouristSiteViewController.swift
//  empathy-ios
//
//  Created by Suji Kim on 27/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class TouristSiteViewController: UIViewController {

    @IBOutlet weak var touristTableView: UITableView!
    var touristArray: [[String: Any?]] = []
    let locationManager = CLLocationManager()
    var locValue: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tapBackAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension TouristSiteViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        if self.locValue == nil {
            self.locValue = locValue
            DispatchQueue.main.async {
                self.requestTourInfo(locValue: locValue)
            }
        }
    }
}

extension TouristSiteViewController: UITableViewDelegate {
    
}

extension TouristSiteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.touristArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TouristSiteTableViewCell") as! TouristSiteTableViewCell
        cell.setInfo(info: touristArray[indexPath.row])
        return cell
    }
}

class TouristSiteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    func setInfo(info: [String: Any?]) {
        if let imageURLString = info["imageURL"] as? String,
            let imageURL = URL(string: imageURLString) {
            cellImageView.kf.setImage(with: imageURL)
        } else {
            cellImageView.image = UIImage(named: "infoImgPlaceholder")
        }
        if let title = info["title"] as? String {
            label1.text = title
        } else {
            label1.text = nil
        }
        if let addr = info["addr"] as? String {
            label2.text = addr
        } else {
            label2.text = nil
        }
    }
}

// request
extension TouristSiteViewController {
    func requestTourInfo(locValue: CLLocationCoordinate2D) {
        
        
        let baseURL: String = "http://ec2-13-209-245-253.ap-northeast-2.compute.amazonaws.com:8080"
        
        // /info/tourAPI/{contentType}/{mapX}/{mapY}/{range}/{pageNumber}
        let contentType = [12 , 14 , 15 , 39].randomElement() ?? 12
        let urlPath: String = "/info/tourAPI/\(contentType)/\(locValue.latitude)/\(locValue.longitude)/100/1"
        
        Alamofire.request("\(baseURL)\(urlPath)").responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                self.touristArray = json as? [[String : Any?]] ?? []
            }
            self.touristTableView.reloadData()
        }
    }
}
