//
//  LoginViewController.swift
//  empathy-ios
//
//  Created by Suji Kim on 09/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import Alamofire

class LoginViewController: UIViewController {

//    @IBOutlet weak var instagramLoginButton: RoundedButton!
    @IBOutlet weak var facebookLoginButton: RoundedButton!
    
    var userInformation:UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        facebookLoginButton.addTarget(self, action: #selector(facebookLoginButtonClicked), for: .touchUpInside)
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // Once the button is clicked, show the login dialog
    //
    @objc func facebookLoginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                print(accessToken)
                self.getUserInformation { userInfo, error in
                    if let error = error {(print(error.localizedDescription))}
                    
                    if let userInfo = userInfo, let id = userInfo["id"], let name = (userInfo["name"] as? String), let email=userInfo["email"], let pictureURL = (userInfo["picture"] as? [String:Any])?["data"] as? [String:Any]{
                        print("\(id)////\(name)////\(email)")
                        print("URL:::\(pictureURL["url"])")
                        if let url = (pictureURL["url"] as? String) {
                            self.postLoginFacebook(name, url)
                        }
                    }
                }
                if let viewController = UIStoryboard.init(name: "MainFeed", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainFeedViewController") as? MainFeedViewController {
                    self.navigationController?.pushViewController(viewController, animated: true)
                    self.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }

    func getUserInformation( completion: @escaping (_ : [String:Any]?, _ : Error?) -> Void) {
        let request = GraphRequest(graphPath: "me", parameters: ["fields" :"id,name, email, picture"])
        request.start { response, result in
            switch result {
            case .failed(let error):
                completion(nil, error)
            case .success(let graphResponse):
                completion(graphResponse.dictionaryValue, nil)
            }
        }
    }
}

// MARK - request
extension LoginViewController {
    func postLoginFacebook(_ name:String, _ pictureURL:String) {
        let urlPath = "\(Commons.baseUrl)/user/"
//        let
        Alamofire.request(urlPath,
            method: .post, parameters: ["name":name, "loginApi":"facebook" , "picturURL":pictureURL],
            encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                if let json = (response.result.value as? Int){
                    print(json)
                    self.userInformation = UserInfo.init(userId: json, name: name, pictureURL: pictureURL)
                }
        }
    }
}
