//
//  PaymentViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 08/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import Paystack

class PaymentViewController: UIViewController {

    //let paymentTextField = PSTCKPaymentCardTextField()

    let paystackPublicKey = "pk_test_4630d972a60683fef74c82acb4e8dace692ff638"
    let backendURLString = "https://calm-scrubland-33409.herokuapp.com"
    let card: PSTCKCard = PSTCKCard()

    // MARK: Properties

    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var cvv: UITextField!
    @IBOutlet weak var expiryYear: UITextField!
    @IBOutlet weak var expiryMonth: UITextField!
    @IBOutlet weak var payNow: UIButton!

    var price = 0
    var key = ""
    var apartmentName = ""
    var fullName = ""
    var phoneNo = ""
    var companyAddress = ""
    var emailAddress = ""
    var refereeName = ""
    var refereePhoneNo = ""

    let cardParams = PSTCKCardParams.init();

    override func viewDidLoad() {

        super.viewDidLoad()

        setUpElement()
        hideKeyboardWhenTappedAround()

    }

    func setUpElement() {
        payNow.layer.cornerRadius = 10

    }

    @IBAction func payNowFunc(_ sender: Any) {

        // cardParams already fetched from our view or assembled by you
        let transactionParams = PSTCKTransactionParams.init();

        // then set parameters thus from card
        cardParams.number = cardNumber.text!
        cardParams.cvc = cvv.text!
        cardParams.expYear = UInt(expiryYear.text!)!
        cardParams.expMonth = UInt(expiryMonth.text!)!

        // building new Paystack Transaction
        if price != 0 {

            //transactionParams.access_code = newCode as String;
            transactionParams.additionalAPIParameters = ["enforce_otp": "true"];
            transactionParams.email = emailAddress;
            transactionParams.amount = UInt("\(price)00")!;
            
            
            
            let dictParams: NSMutableDictionary = [
                "recurring": false
            ];
            let arrParams: NSMutableArray = [
                "0", "go"
            ];

            let custom_filters: NSMutableDictionary = [
                "recurring": true
            ];

            let items: NSMutableArray = [
                apartmentName
            ];
            do {
                try transactionParams.setMetadataValueDict(dictParams, forKey: "custom_filters");
                try transactionParams.setMetadataValueArray(arrParams, forKey: "custom_array");
            } catch {
                print(error)
            }


            do {
                try transactionParams.setCustomFieldValue("iOS SDK", displayedAs: "Paid Via iOS app");
                try transactionParams.setCustomFieldValue(apartmentName, displayedAs: "Booked");
                try transactionParams.setMetadataValue("iOS SDK", forKey: "paid_via");
                try transactionParams.setMetadataValueDict(custom_filters, forKey: "custom_filters");
                try transactionParams.setMetadataValueArray(items, forKey: "items");
            } catch {
                print(error);
            }
            transactionParams.email = emailAddress;

            PSTCKAPIClient.shared().chargeCard(cardParams, forTransaction: transactionParams, on: self,
                didEndWithError: { (error, reference) -> Void in
                    print("error payment: \(error)")
                    self.showToast(message: "Ooops... we couldnt make this payment", seconds: 1.2)
                }, didRequestValidation: { (reference) -> Void in
                    // an OTP was requested, transaction has not yet succeeded
                    self.showToast(message: "Ooops... please genetrate  on the doc ", seconds: 1.2)
                }, didTransactionSuccess: { (reference) -> Void in
                    // transaction may have succeeded, please verify on backend
                    self.showToast(message: "Congrats... Payment made, you will be contacted soon", seconds: 2)
                    
                    //TODO: Confirm payment and save package to DB
                    //transition home
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            self.performSegue(withIdentifier: "backHome_payment", sender: nil)
                        })

                })

        } else {
            //TODO: take them pack to product details page
            showToast(message: "error making payment", seconds: 1.2)
        }



    }


    @IBAction func backBookApartment(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "bookApartmentNow") as! BookApartmentViewController



        viewController._fullName = fullName
        viewController._phoneNo = phoneNo
        viewController._emailAddress = emailAddress
        viewController._companyAddress = companyAddress
        viewController._refereeName = refereeName
        viewController._refereePhoneNo = refereePhoneNo

        viewController.view.window?.rootViewController = viewController
        viewController.view.window?.makeKeyAndVisible()

        self.present(viewController, animated: false, completion: nil)
    }


    func validate() -> Bool {

        if self.cardNumber.text?.count != 13 {
            showToast(message: "Please enter a valid card number", seconds: 1.2)
            return false
        }
        else if self.cvv.text?.count != 3 {
            showToast(message: "Please enter a valid CVV number", seconds: 1.2)
            return false
        } else if self.expiryYear.text?.count != 4 {
            showToast(message: "Please enter a valid expiry year hint: YYYY", seconds: 1.2)
            return false
        } else if self.expiryMonth.text?.count != 1 || self.expiryMonth.text?.count != 2 {
            showToast(message: "Please enter a valid expiry hint: 1-12", seconds: 1.2)
            return false
        }

        return true
    }


}
