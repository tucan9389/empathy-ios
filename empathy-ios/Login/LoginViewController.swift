//
//  LoginViewController.swift
//  empathy-ios
//
//  Created by Suji Kim on 09/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginViewController: UIViewController {

    @IBOutlet weak var instagramLoginButton: RoundedButton!
    @IBOutlet weak var facebookLoginButton: RoundedButton!
    
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
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                print(accessToken)
            }
        }
    }

}
