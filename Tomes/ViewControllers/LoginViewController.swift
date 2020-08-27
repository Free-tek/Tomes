//
//  LoginViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 27/08/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import SystemConfiguration
import Lottie
import  Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var header1: UILabel!
    @IBOutlet weak var header2: UILabel!
    @IBOutlet weak var emailHint: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var passwordHint: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var forgotPassword: UIButton!
    
    let animationView = AnimationView();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    func setUpElements(){
        Utilities.styleTextField(email)
        Utilities.styleTextField(password)
        Utilities.styleFilledButton(login)
        Utilities.styleFilledButton(signUp)
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func loginFunc(_ sender: Any) {
        if(!validateFields()!){
            print("form not field correctly")
        }else  if (!isInternetAvailable()){
            showToast(message: "No Internet Connection", seconds: 1.2)
        }else{
            
            self.animationView.alpha = 1
            self.animationView.animation = Animation.named("loadingTomes")
            self.animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            self.animationView.center = self.view.center
            self.animationView.contentMode = .scaleAspectFit
            self.animationView.loopMode = .loop
            self.animationView.play()
            self.view.addSubview(self.animationView)

            //switch views off

            icon.alpha = 0.1
            header1.alpha = 0.1
            header2.alpha = 0.1
            emailHint.alpha = 0.1
            email.alpha = 0.1
            passwordHint.alpha = 0.1
            password.alpha = 0.1
            login.alpha = 0.1
            signUp.alpha = 0.1
            forgotPassword.alpha = 0.1
            
            
            let _email = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let _password = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            Auth.auth().signIn(withEmail: _email, password: _password) { [weak self] authResult, error in
                guard self != nil else { return }

                if error == nil {


                    self?.animationView.stop()
                    self?.animationView.alpha = 0

                    //switch views back on
                    self?.email.alpha = 1
                    self?.password.alpha = 1
                    self?.icon.alpha = 1
                    self?.header1.alpha = 1
                    self?.header2.alpha = 1
                    self?.forgotPassword.alpha = 1
                    self?.emailHint.alpha = 1
                    self?.email.alpha = 1
                    self?.passwordHint.alpha = 1
                    self?.password.alpha = 1
                    self?.login.alpha = 1
                    self?.signUp.alpha = 1
                    self?.forgotPassword.alpha = 1
                    
                    let userId = Auth.auth().currentUser?.uid
                    self?.transitionToHome(userId!)


                } else {
                    // user sign in not successful
                    self?.animationView.stop()
                    self?.animationView.alpha = 0

                    //switch views back on
                    self?.email.alpha = 1
                    self?.password.alpha = 1
                    self?.icon.alpha = 1
                    self?.header1.alpha = 1
                    self?.header2.alpha = 1
                    self?.forgotPassword.alpha = 1
                    self?.emailHint.alpha = 1
                    self?.email.alpha = 1
                    self?.passwordHint.alpha = 1
                    self?.password.alpha = 1
                    self?.login.alpha = 1
                    self?.signUp.alpha = 1
                    self?.forgotPassword.alpha = 1

                    self?.showToast(message: "Login Unsuccessful, Check your email and password.", seconds: 1.5)

                }
            }

            
        }
    }
    

    @IBAction func signUpFunc(_ sender: Any) {
    }
    
    @IBAction func forgotPasswordFunc(_ sender: Any) {
    }
    
    func validateFields() -> Bool? {
        //check that all fields are filled in
        if self.email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(message: "Please enter your email.", seconds: 1.2)
            return false
        } else if self.password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(message: "Please enter your password.", seconds: 1.2)
            return false
        }
        return true

    }
    
    func transitionToHome(_ userID: String) {
        self.performSegue(withIdentifier: "toHome_Login", sender: nil)
    }
}


extension UIViewController {


    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func showToast(message: String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15

        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }

}
