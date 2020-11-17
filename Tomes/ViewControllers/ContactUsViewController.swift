//
//  ContactUsViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 28/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ContactUsViewController: UIViewController {

    @IBOutlet weak var customerCareIcon: UIImageView!
    @IBOutlet weak var facilityManagerIcon: UIImageView!
    @IBOutlet weak var chefIcon: UIImageView!
    @IBOutlet weak var laundryServiceIcon: UIImageView!
    @IBOutlet weak var cleaningServiceIcon: UIImageView!
    @IBOutlet weak var chaufferServiceIcon: UIImageView!

    @IBOutlet weak var customerCareView: UIView!
    @IBOutlet weak var facilityManagerView: UIView!
    @IBOutlet weak var chefView: UIView!
    @IBOutlet weak var laundryManView: UIView!
    @IBOutlet weak var cleaningServiceView: UIView!
    @IBOutlet weak var chaufferServiceView: UIView!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var contactUsView: UIView!
    @IBOutlet weak var whatsApp: UIButton!
    @IBOutlet weak var call: UIButton!

    @IBOutlet weak var backFromContact: UIButton!

    var key: String?
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }


    func setUpElements() {

        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)


        contactUsView.layer.cornerRadius = 5
        contactUsView.layer.borderWidth = 1.0


        contactUsView.layer.borderColor = UIColor.clear.cgColor
        contactUsView.layer.masksToBounds = true

        contactUsView.layer.shadowColor = UIColor.gray.cgColor
        contactUsView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        contactUsView.layer.shadowRadius = 2.0
        contactUsView.layer.shadowOpacity = 1.0
        contactUsView.layer.masksToBounds = false
        contactUsView.layer.shadowPath = UIBezierPath(roundedRect: contactUsView.bounds, cornerRadius: contactUsView.layer.cornerRadius).cgPath


        customerCareView.layer.cornerRadius = 15
        customerCareView.layer.masksToBounds = true

        facilityManagerView.layer.cornerRadius = 15
        facilityManagerView.layer.masksToBounds = true

        chefView.layer.cornerRadius = 15
        chefView.layer.masksToBounds = true

        laundryManView.layer.cornerRadius = 15
        laundryManView.layer.masksToBounds = true

        cleaningServiceView.layer.cornerRadius = 15
        cleaningServiceView.layer.masksToBounds = true

        chaufferServiceView.layer.cornerRadius = 15
        chaufferServiceView.layer.masksToBounds = true


        let callCustomerCare = UITapGestureRecognizer(target: self, action: #selector(self.callCustomerCare(_:)))
        customerCareView.addGestureRecognizer(callCustomerCare)

        let callfacilityManager = UITapGestureRecognizer(target: self, action: #selector(self.callfacilityManager(_:)))
        facilityManagerView.addGestureRecognizer(callfacilityManager)

        let callChef = UITapGestureRecognizer(target: self, action: #selector(self.callChef(_:)))
        chefView.addGestureRecognizer(callChef)

        let callLaundryMan = UITapGestureRecognizer(target: self, action: #selector(self.callLaundryMan(_:)))
        laundryManView.addGestureRecognizer(callLaundryMan)

        let callCleaner = UITapGestureRecognizer(target: self, action: #selector(self.callCleaner(_:)))
        cleaningServiceView.addGestureRecognizer(callCleaner)

        let callChaufer = UITapGestureRecognizer(target: self, action: #selector(self.callChaufer(_:)))
        chaufferServiceView.addGestureRecognizer(callChaufer)

    }

    @objc func callCustomerCare(_ sender: UITapGestureRecognizer) {
        // handling code
        key = "customerCare"
        contactUsView.alpha = 1
        scrollView.alpha = 0
    }

    @objc func callfacilityManager(_ sender: UITapGestureRecognizer) {
        // handling code
        key = "facilityManager"
        contactUsView.alpha = 1
        scrollView.alpha = 0
    }

    @objc func callChef(_ sender: UITapGestureRecognizer) {
        // handling code
        key = "chef"
        contactUsView.alpha = 1
        scrollView.alpha = 0
    }

    @objc func callLaundryMan(_ sender: UITapGestureRecognizer) {
        // handling code
        key = "laundryMan"
        contactUsView.alpha = 1
        scrollView.alpha = 0
    }

    @objc func callCleaner(_ sender: UITapGestureRecognizer) {
        // handling code
        key = "cleaner"
        contactUsView.alpha = 1
        scrollView.alpha = 0
    }


    @objc func callChaufer(_ sender: UITapGestureRecognizer) {
        // handling code
        key = "chaufer"
        contactUsView.alpha = 1
        scrollView.alpha = 0
    }



    @IBAction func whatsappMessageFunc(_ sender: Any) {
        
        self.activityIndicator.startAnimating()
        
        let userID = Auth.auth().currentUser?.uid
        var refList: DatabaseReference!
        var refUsers: DatabaseReference!
        
        refUsers = Database.database().reference().child("users").child(userID!);
        
        refUsers.observe(.value, with: {
            (snapshot) in

            let data = snapshot.value as? [String: Any]
            let name = (data?["firstname"]) as! String

            refList = Database.database().reference().child("contacts");

            refList.observe(.value, with: {
                (snapshot) in

                let data = snapshot.value as? [String: Any]
                let phoneNo = (data?[self.key!]) as! String

                
                self.activityIndicator.stopAnimating()
                
                

                if phoneNo != nil{
                    
                    let urlWhats = "whatsapp://send?phone=\(phoneNo)&text=I am \(name), I will like to"

                    var characterSet = CharacterSet.urlQueryAllowed
                    characterSet.insert(charactersIn: "?&")

                    if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: characterSet){

                    if let whatsappURL = NSURL(string: urlString) {
                                    if UIApplication.shared.canOpenURL(whatsappURL as URL){
                                        UIApplication.shared.openURL(whatsappURL as URL)
                                    }
                                    else {
                                        self.showToast(message: "Ooops, You don't have whatsapp installed", seconds: 1.2)

                                    }
                                }
                            }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
//                    print("this is my firstname \(name) and phone no \(phoneNo)")
//
//                    let whatsAppUrl = NSURL(string: "https://api.whatsapp.com/send?phone=\(phoneNo)&text=Hello,%20I%20am%20\(name),%20I%20will%20like%20to")
//
//
//
//                    print("this is whatspp url \(whatsAppUrl)")
//
//                    if UIApplication.shared.canOpenURL(whatsAppUrl as! URL) {
//                        UIApplication.shared.openURL(whatsAppUrl as! URL)
//                    }
//                    else {
//                        self.showToast(message: "Ooops, You don't have whatsapp installed", seconds: 1.2)
//                    }
//
//
                }
                



            })
            



        })
        
        
        
        
        
        


    }

    @IBAction func backFromContactFunc(_ sender: Any) {


        contactUsView.alpha = 0
        scrollView.alpha = 1
    }

    @IBAction func callFunc(_ sender: Any) {
        
        self.activityIndicator.startAnimating()
        
        let userID = Auth.auth().currentUser?.uid
        var refList: DatabaseReference!
        refList = Database.database().reference().child("contacts");

        refList.observe(.value, with: {
            (snapshot) in

            let data = snapshot.value as? [String: Any]
            let phoneNo = (data?[self.key!]) as! String

            self.activityIndicator.stopAnimating()
            
            guard let number = URL(string: "tel://" + phoneNo) else { return }
            UIApplication.shared.open(number)




        })


        

    }

    
}
