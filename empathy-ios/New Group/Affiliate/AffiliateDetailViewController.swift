//
//  AffiliateDetailViewController.swift
//  empathy-ios
//
//  Created by Suji Kim on 27/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import Alamofire

class AffiliateDetailViewController: UIViewController {

    var targetId: Int = 0
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bussinessHoursLabel: UILabel!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var priceInfoLabel: UILabel!
    @IBOutlet weak var locationStrLabel: UILabel!
    
    @IBOutlet weak var tmapBGView: UIView!
    var tmapView: TMapView?
    @IBOutlet weak var tmapImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let _mapView = TMapView(frame: self.tmapBGView.bounds)
        _mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        _mapView.setSKTMapApiKey(TMAP_IDS.KEY)
        
        tmapBGView.addSubview(_mapView)
        tmapView = _mapView
        tmapView?.setSKTMapApiKey(TMAP_IDS.KEY)
        //        TMapTapi.setSKTMapAuthenticationWith(self, apiKey: TMAP_IDS.KEY)
        
        
        // /info/tourAPI/{contentType}/{mapX}/{mapY}/{range}/{pageNumber}
        let urlPath: String = "/info/alliance/detail/\(targetId)"
        
        Alamofire.request("\(Commons.baseUrl)\(urlPath)").responseJSON { response in
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result
//
            print(response.result.value)
            
            if let data = response.data//,
                /*let utf8Text = String(data: data, encoding: .utf8)*/ {
                    //print("utf8Text: \(utf8Text)") // serialized json response
                    //self.touristArray = json as? [[String : Any?]] ?? []
                    let decoder = JSONDecoder()
                    
                    do {
                        let detailInfo = try decoder.decode(AffiliateDetailModel.self, from: data)
                        //print(detailInfo)
                        self.update(detailInfo: detailInfo)
                    } catch let DecodingError.dataCorrupted(context) {
                        print(context)
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.valueNotFound(value, context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.typeMismatch(type, context)  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch {
                        print("error: ", error)
                    }
            }
            //self.touristTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //
        if let locationCoordinate2D = detailInfo?.getLocationCoordinate2D() {
            let mapPoint = TMapPoint(coordinate: locationCoordinate2D)
            let marker = TMapMarkerItem()
            marker.setTMapPoint(mapPoint)
            //marker.setName("😘")
            marker.setIcon(UIImage(named: "marker_1"))
            marker.enableClustering = true
            tmapView?.addTMapMarkerItemID("marker0", marker: marker, animated: true)
            
            tmapView?.zoomLevel = 15
            tmapView?.setCenter(locationCoordinate2D, animated: true)
        }
        
        //        if let locationCoordinate2D = self.locationCoordinate2D {
        //            let path = TMapPathData()
        //            let point = TMapPoint(coordinate: locationCoordinate2D)
        //            let address = path.convertGpsToAddress(at: point)
        //            let dic = path.reverseGeocoding(point, addressType: "A03")
        //            print("😘😘😘😘😘 address:\(address)")
        //            print("😘😘😘😘😘 dic:\(dic)")
        //        }
        
        tmapImageView.image = tmapView?.getCaptureImage()
        tmapImageView.contentMode = .scaleAspectFill
    }
    
    @IBAction func touchBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var detailInfo: AffiliateDetailModel?
    
    func update(detailInfo: AffiliateDetailModel) {
        self.detailInfo = detailInfo
        
        if let url = URL(string: detailInfo.imageURL ?? "") {
            topImageView.kf.setImage(with: url)
        }
        
        
        titleLabel.text = detailInfo.title
        descriptionLabel.text = detailInfo.overview
        
        bussinessHoursLabel.text = detailInfo.duration
        playTimeLabel.text = detailInfo.playTime
        priceInfoLabel.text = detailInfo.priceInfo
        locationStrLabel.text = detailInfo.locationStr
        // addressLabel.text = "\(detailInfo.mapx ?? "-1"), \(detailInfo.mapy ?? "-1")"
    }
}


struct AffiliateDetailModel: Codable {
    let duration: String?
    let playTime: String?// = "\Uc5c6\Uc74c";
    let priceInfo: String?// = "";
    let imageURL: String?// = "http://tong.visitkorea.or.kr/cms/resource/16/2373216_image2_1.jpg";
    let locationStr: String?// = "\Uc11c\Uc6b8\Ud2b9\Ubcc4\Uc2dc \Uc911\Uad6c \Uc138\Uc885\Ub300\Ub85c 125";
    let mapx: String?// = "126.9765267272";
    let mapy: String?// = "37.5675596477";
    let overview: String?
    let title: String?
    
    func getLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(self.mapy ?? "0") ?? 0,
                                      longitude: Double(self.mapx ?? "0") ?? 0)
    }
}
