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

class BookApartmentViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    
    

    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var companyAddress: UITextField!
    @IBOutlet weak var refereeName: UITextField!
    @IBOutlet weak var refereePhoneNo: UITextField!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var back: UIButton!
    
    var durationPicker: UIPickerView?
    private var durationDataSource = [String] ()
    var durataionReady = false
    
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
    var _apartmentPrices = ""
    var  apartmentLocation = ""
    var apartmentAvailability = ""
    var apartmentPrices = ""
    
    
    var refList: DatabaseReference!
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        setUpPricePicker()
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
            self.duration.text = self._apartmentPrices
            
            
            
            
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
            viewController.apartmentPrices = duration.text!
            viewController._apartmentPrices = apartmentPrices
            
            
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
            
        }else if self.duration.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(message: "Please select the duration you want to book the apartment for", seconds: 1.2)
            return false
        }
        
        return true
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return durationDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return durationDataSource[row]

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        duration.text = durationDataSource[row]
    }
    
    
    func setUpPricePicker() {
        durationPicker = UIPickerView()
        duration.inputView = durationPicker
        durationPicker!.delegate = self

        self.durationPicker!.delegate = self
        self.durationPicker!.dataSource = self

        if apartmentPrices != nil{
            durationDataSource = apartmentPrices.components(separatedBy: ", ")
            self.durataionReady = true
        }
        
    }


}

