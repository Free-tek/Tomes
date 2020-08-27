//
//  ForgotPasswordViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 27/08/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import Lottie
import Firebase

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var sendEmail: UIButton!
    @IBOutlet weak var back: UIButton!
    
    let animationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }
    
    func setUpElements(){
        Utilities.styleTextField(email)
        Utilities.styleFilledButton(sendEmail)
        self.hideKeyboardWhenTappedAround()
    }
    
    
    @IBAction func sendEmailFunc(_ sender: Any) {
        
        if(valid()!) {
            self.animationView.alpha = 1
            self.animationView.animation = Animation.named("loadingTomes")
            self.animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            self.animationView.center = self.view.center
            self.animationView.contentMode = .scaleAspectFit
            self.animationView.loopMode = .loop
            self.animationView.play()
            self.view.addSubview(self.animationView)
            
            heading.alpha = 0.1
            emailLabel.alpha = 0.1
            email.alpha = 0.1
            sendEmail.alpha = 0.1
            back.alpha = 0.1
            

            let _email = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            Auth.auth().sendPasswordReset(withEmail: _email) { error in
                self.showToast(message: "A reset password link has been sent to your mail", seconds: 2)

                self.animationView.stop()
                self.animationView.alpha = 0

                self.heading.alpha = 1
                self.emailLabel.alpha = 1
                self.email.alpha = 1
                self.sendEmail.alpha = 1
                self.back.alpha = 1


            }



        }
    }
    
    func valid() -> Bool? {
        if self.email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(message: "Please enter your email.", seconds: 1.5)
            return false
        }
        return true
    }
}

