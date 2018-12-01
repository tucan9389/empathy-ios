//
//  TouristSiteDetailViewController.swift
//  empathy-ios
//
//  Created by Suji Kim on 27/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class TouristSiteDetailViewController: UIViewController {
    
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bussinessHoursLabel: UILabel!
    @IBOutlet weak var dayOffLabel: UILabel!
    @IBOutlet weak var creditCardLabel: UILabel!
    @IBOutlet weak var withPetLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    

    var targetId: String = ""
    var contentType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // /info/tourAPI/detail/
        
        let baseURL: String = "http://ec2-13-209-245-253.ap-northeast-2.compute.amazonaws.com:8080"
        
        // /info/tourAPI/{contentType}/{mapX}/{mapY}/{range}/{pageNumber}
        let urlPath: String = "/info/tourAPI/detail/\(contentType)/\(targetId)"
        
        Alamofire.request("\(baseURL)\(urlPath)").responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            print(response.result.value)
            
            if let data = response.data,
                let utf8Text = String(data: data, encoding: .utf8) {
                print("utf8Text: \(utf8Text)") // serialized json response
                //self.touristArray = json as? [[String : Any?]] ?? []
                let decoder = JSONDecoder()
                
                do {
                    let detailInfo = try decoder.decode(TouristSiteDetailModel.self, from: data)
                    print(detailInfo)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    var detailInfo: TouristSiteDetailModel?
    
    func update(detailInfo: TouristSiteDetailModel) {
        self.detailInfo = detailInfo
        
        if let url = URL(string: detailInfo.imageURL ?? "") {
            topImageView.kf.setImage(with: url)
        }
        
        titleLabel.text = detailInfo.title
        descriptionLabel.text = detailInfo.overviewText
        
        bussinessHoursLabel.text = detailInfo.businessHours
        dayOffLabel.text = detailInfo.dayOff
        creditCardLabel.text = detailInfo.creditCard
        withPetLabel.text = detailInfo.withPet
        addressLabel.text = "\(detailInfo.mapx ?? "-1"), \(detailInfo.mapy ?? "-1")"
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func touchBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

struct TouristSiteDetailModel: Codable {
    let businessHours: String?
    let creditCard: String?// = "\Uc5c6\Uc74c";
    let dayOff: String?// = "";
    let imageURL: String?// = "http://tong.visitkorea.or.kr/cms/resource/16/2373216_image2_1.jpg";
    let locationStr: String?// = "\Uc11c\Uc6b8\Ud2b9\Ubcc4\Uc2dc \Uc911\Uad6c \Uc138\Uc885\Ub300\Ub85c 125";
    let mapx: String?// = "126.9765267272";
    let mapy: String?// = "37.5675596477";
    let overviewText: String?
    let title: String?
    let withPet: String?
}
