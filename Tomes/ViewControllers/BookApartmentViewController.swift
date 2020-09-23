//
//  BookApartmentViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 08/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import Paystack

class BookApartmentViewController: UIViewController {

    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var companyAddress: UITextField!
    @IBOutlet weak var refereeName: UITextField!
    @IBOutlet weak var refereePhoneNo: UITextField!
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var payNow: UIButton!
    
    var key = ""
    var price = 0
    var apartmentName = ""
    var _fullName = ""
    var _phoneNo = ""
    var _emailAddress = ""
    var _companyAddress = ""
    var _refereeName = ""
    var _refereePhoneNo = ""
    var  apartmentLocation = ""
    var apartmentAvailability = ""
    
    
    var refList: DatabaseReference!
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        fetchUsersDetails()
        hideKeyboardWhenTappedAround()
    }
    
    func setUpElements(){
        payNow.layer.cornerRadius = 10
        payNow.layer.masksToBounds = true
    }
    
    func fetchUsersDetails(){
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users").child(userID!)

        ref.observeSingleEvent(of: .value){
            (snapshot) in
            let data = snapshot.value as? [String:Any]


            let _firstName  = data?["firstname"]
            let _surname  = data?["surname"]
            let _phoneNumber = data?["phoneNo"]
            let _email = data?["email"]
            
            
            let fname = (_firstName as? String)!
            let sname = (_surname as? String)!
            
            self.fullName.text = "\(fname) \(sname)"
            self.phoneNo.text = (_phoneNumber as? String)!
            self.emailAddress.text = (_email as? String)!
            
            self.companyAddress.text = self._companyAddress
            self.refereeName.text = self._refereeName
            self.refereePhoneNo.text = self._refereePhoneNo
            
            
            
            
        }
    }
    
    @IBAction func backFunc(_ sender: Any) {
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "apartmentDetailsPage") as! ApartmentDetailsViewController

        viewController.key = key
    

        viewController.view.window?.rootViewController = viewController
        viewController.view.window?.makeKeyAndVisible()

        self.present(viewController, animated: false, completion: nil)
    }
    
    @IBAction func payNowFunc(_ sender: Any) {
        if validateFields(){
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let viewController = storyboard.instantiateViewController(withIdentifier: "payment") as! PaymentViewController
            
            viewController.key = key
            viewController.price = price
            viewController.apartmentName = apartmentName
            viewController.fullName = fullName.text!
            viewController.phoneNo = phoneNo.text!
            viewController.emailAddress = emailAddress.text!
            viewController.companyAddress = companyAddress.text!
            viewController.refereeName = refereeName.text!
            viewController.refereePhoneNo = refereePhoneNo.text!
            viewController.apartmentLocation = apartmentLocation
            
            viewController.view.window?.rootViewController = viewController
            viewController.view.window?.makeKeyAndVisible()

            self.present(viewController, animated: false, completion: nil)
            
        }
    }
    
    func validateFields() -> Bool{
        if self.fullName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(message: "Please enter your full name", seconds: 1.2)
            return false
        }
        else if self.phoneNo.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(message: "Please enter your phone no", seconds: 1.2)
            return false
        } else if self.emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(message: "Please enter your email address", seconds: 1.2)
            return false
        }
        else if self.companyAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(message: "Please enter your company address", seconds: 1.2)
            return false
        }
        else if self.refereeName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(message: "Please enter your refree full name", seconds: 1.2)
            return false
        }
        else if self.refereePhoneNo.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(message: "Please enter your referee phone number", seconds: 1.2)
            return false
        }
        
        return true
    }
    

}
