//
//  SignUpViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 27/08/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import Lottie
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNoLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var surname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var back: UIButton!
    

    let animationView = AnimationView()


    override func viewDidLoad() {
        super.viewDidLoad()


        setUpElements()
    }

    func setUpElements() {
        Utilities.styleTextField(firstName)
        Utilities.styleTextField(surname)
        Utilities.styleTextField(email)
        Utilities.styleTextField(phoneNo)
        Utilities.styleTextField(password)
        Utilities.styleTextField(confirmPassword)
        Utilities.styleFilledButton(signUp)
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func signUpFunc(_ sender: Any) {

        if(!validateFields()!) {
            print("Incomplete form")
        } else if(!isInternetAvailable()) {
            showToast(message: "No Internet Connection", seconds: 1.2)
        } else {

            let alert = UIAlertController(title: Utilities.StringAssets.headerTC, message:
                    Utilities.StringAssets.bodyTC, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Accept", style: UIAlertAction.Style.default, handler: { (okay) in
                self.createUser();

            }))
            alert.addAction(UIAlertAction(title: "Reject", style: UIAlertAction.Style.default, handler: { (resend) in
                alert.dismiss(animated: true, completion: nil)
            }))

            self.present(alert, animated: true, completion: nil)

        }


    }

    func createUser() {

        self.animationView.alpha = 1
        self.animationView.animation = Animation.named("loadingTomes")
        self.animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        self.animationView.center = self.view.center
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
        self.animationView.play()
        self.view.addSubview(self.animationView)

        //switch views off

        heading.alpha = 0.1
        firstNameLabel.alpha = 0.1
        surnameLabel.alpha = 0.1
        emailLabel.alpha = 0.1
        phoneNoLabel.alpha = 0.1
        passwordLabel.alpha = 0.1
        confirmPasswordLabel.alpha = 0.1
        firstName.alpha = 0.1
        surname.alpha = 0.1
        email.alpha = 0.1
        phoneNo.alpha = 0.1
        password.alpha = 0.1
        confirmPassword.alpha = 0.1
        signUp.alpha = 0.1
        back.alpha = 0.1


        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (result, err) in

            if result == nil {
                self.showToast(message: "We couldn't create your account, this email exists", seconds: 1.2)
                self.animationView.stop()
                self.animationView.alpha = 0

                self.heading.alpha = 1
                self.firstNameLabel.alpha = 1
                self.surnameLabel.alpha = 1
                self.emailLabel.alpha = 1
                self.phoneNoLabel.alpha = 1
                self.passwordLabel.alpha = 1
                self.confirmPasswordLabel.alpha = 1
                self.firstName.alpha = 1
                self.surname.alpha = 1
                self.email.alpha = 1
                self.phoneNo.alpha = 1
                self.password.alpha = 1
                self.confirmPassword.alpha = 1
                self.signUp.alpha = 1
                self.back.alpha = 1
                
            } else {

                let post: [String: Any] = ["firstname": self.firstName.text!,
                    "surname": self.surname.text!,
                    "email": self.email.text!,
                    "phoneNo": self.phoneNo.text!,
                    "password": self.password.text!,
                    "version": "IoS V1"]


                let userId = result!.user.uid
                let ref = Database.database().reference().child("users").child(userId)

                //save user's data
                ref.setValue(post) { (err, resp) in
                    guard err == nil else {
                        print("Posting failed : ")
                        self.showToast(message: "Oopss.., we couldnt create your account", seconds: 1.2)

                        return
                    }
                    print("No errors while posting, :")
                    //go to home page
                    self.animationView.stop()
                    self.animationView.alpha = 0

                    self.heading.alpha = 1
                    self.firstNameLabel.alpha = 1
                    self.surnameLabel.alpha = 1
                    self.emailLabel.alpha = 1
                    self.phoneNoLabel.alpha = 1
                    self.passwordLabel.alpha = 1
                    self.confirmPasswordLabel.alpha = 1
                    self.firstName.alpha = 1
                    self.surname.alpha = 1
                    self.email.alpha = 1
                    self.phoneNo.alpha = 1
                    self.password.alpha = 1
                    self.confirmPassword.alpha = 1
                    self.signUp.alpha = 1
                    self.back.alpha = 1



                    self.transitionToHome(userId)
                }

            }



        }

    }

    func validateFields() -> Bool? {
        //check that all fields are filled in
        if self.firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(message: "Please enter your firstname.", seconds: 1.2)
            return false
        } else if self.surname.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(message: "Please enter your surname.", seconds: 1.2)
            return false
        }
        else if self.email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(message: "Please enter your email.", seconds: 1.2)
            return false
        } else if self.phoneNo.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(message: "Please enter your phoneno.", seconds: 1.2)
            return false
        } else if self.password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(message: "Please enter your password.", seconds: 1.2)
            return false
        } else if self.confirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(message: "Please connfirm your password.", seconds: 1.2)
            return false
        } else if self.confirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) != self.password.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            showToast(message: "Password and Confirm Password do not match.", seconds: 1.5)
            return false
        }

        return true

    }

    func transitionToHome(_ userID: String) {
        self.performSegue(withIdentifier: "toHome_Signup", sender: nil)
    }

}
