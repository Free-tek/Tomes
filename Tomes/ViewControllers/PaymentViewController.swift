//
//  PaymentViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 08/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import Paystack
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Lottie

class PaymentViewController: UIViewController {

    //let paymentTextField = PSTCKPaymentCardTextField()

    let paystackPublicKey = "pk_test_4630d972a60683fef74c82acb4e8dace692ff638"
    let backendURLString = "https://calm-scrubland-33409.herokuapp.com"
    let card: PSTCKCard = PSTCKCard()

    let animationView = AnimationView();

    // MARK: Properties

    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var cvv: UITextField!
    @IBOutlet weak var expiryYear: UITextField!
    @IBOutlet weak var expiryMonth: UITextField!
    @IBOutlet weak var payNow: UIButton!

    @IBOutlet weak var paymentHeader: UILabel!
    @IBOutlet weak var cardNoHeader: UILabel!
    @IBOutlet weak var cvvHeader: UILabel!
    @IBOutlet weak var expiryYearHeader: UILabel!
    @IBOutlet weak var expiryMonthHeader: UILabel!
    @IBOutlet weak var backButton: UIButton!

    


    var price = 0
    var key = ""
    var apartmentName = ""
    var fullName = ""
    var phoneNo = ""
    var companyAddress = ""
    var emailAddress = ""
    var refereeName = ""
    var refereePhoneNo = ""
    var apartmentLocation = ""
    var apartmentPrices = ""
    var duration = ""
    var _apartmentPrices = ""

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

        self.animationView.alpha = 1
        self.animationView.animation = Animation.named("loadingTomes")
        self.animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        self.animationView.center = self.view.center
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
        self.animationView.play()
        self.view.addSubview(self.animationView)

        cardNumber.alpha = 0
        cvv.alpha = 0
        expiryYear.alpha = 0
        expiryMonth.alpha = 0
        payNow.alpha = 0

        paymentHeader.alpha = 0
        cardNoHeader.alpha = 0
        cvvHeader.alpha = 0
        expiryYearHeader.alpha = 0
        expiryMonthHeader.alpha = 0

        backButton.alpha = 0


        // cardParams already fetched from our view or assembled by you
        let transactionParams = PSTCKTransactionParams.init();

        // then set parameters thus from card
        cardParams.number = cardNumber.text!
        cardParams.cvc = cvv.text!
        cardParams.expYear = UInt(expiryYear.text!)!
        cardParams.expMonth = UInt(expiryMonth.text!)!

        //check if card is valid
        
        // building new Paystack Transaction
        if validate() != false && price != 0 {

            print("this is apartment price \(apartmentPrices)")
            if apartmentPrices != "" && apartmentPrices.lowercased().contains("weekly") {
                price = Int (apartmentPrices.lowercased().replacingOccurrences(of: "weekly - ₦", with: ""))!
                duration = "weekly"
                print("entered price 1 \(price)")

            } else if apartmentPrices != "" && apartmentPrices.lowercased().contains("monthly") {
                price = Int (apartmentPrices.lowercased().replacingOccurrences(of: "monthly - ₦", with: ""))!
                duration = "monthly"

            } else if apartmentPrices != "" && apartmentPrices.lowercased().contains("daily") {
                price = Int (apartmentPrices.lowercased().replacingOccurrences(of: "daily - ₦", with: ""))!
                duration = "daily"

            }

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

                cardNumber.alpha = 1
                cvv.alpha = 1
                expiryYear.alpha = 1
                expiryMonth.alpha = 1
                payNow.alpha = 1

                paymentHeader.alpha = 1
                cardNoHeader.alpha = 1
                cvvHeader.alpha = 1
                expiryYearHeader.alpha = 1
                expiryMonthHeader.alpha = 1
                backButton.alpha = 1

                self.animationView.stop()
                self.animationView.alpha = 0
                showToast(message: "Ooops... We couldnt process your payment", seconds: 1.2)
            }


            do {
                try transactionParams.setCustomFieldValue("iOS SDK", displayedAs: "Paid Via iOS app");
                try transactionParams.setCustomFieldValue(apartmentName, displayedAs: "Booked");
                try transactionParams.setMetadataValue("iOS SDK", forKey: "paid_via");
                try transactionParams.setMetadataValueDict(custom_filters, forKey: "custom_filters");
                try transactionParams.setMetadataValueArray(items, forKey: "items");
            } catch {
                print(error);

                cardNumber.alpha = 1
                cvv.alpha = 1
                expiryYear.alpha = 1
                expiryMonth.alpha = 1
                payNow.alpha = 1

                paymentHeader.alpha = 1
                cardNoHeader.alpha = 1
                cvvHeader.alpha = 1
                expiryYearHeader.alpha = 1
                expiryMonthHeader.alpha = 1
                backButton.alpha = 1

                self.animationView.stop()
                self.animationView.alpha = 0
                showToast(message: "Ooops... We couldnt process your payment", seconds: 1.2)

            }
            transactionParams.email = emailAddress;

            PSTCKAPIClient.shared().chargeCard(cardParams, forTransaction: transactionParams, on: self,
                didEndWithError: { (error, reference) -> Void in
                    print("error payment: \(error)")

                    self.cardNumber.alpha = 1
                    self.cvv.alpha = 1
                    self.expiryYear.alpha = 1
                    self.expiryMonth.alpha = 1
                    self.payNow.alpha = 1

                    self.paymentHeader.alpha = 1
                    self.cardNoHeader.alpha = 1
                    self.cvvHeader.alpha = 1
                    self.expiryYearHeader.alpha = 1
                    self.expiryMonthHeader.alpha = 1
                    self.backButton.alpha = 1

                    self.animationView.stop()
                    self.animationView.alpha = 0
                    self.showToast(message: "Ooops... we couldnt make this payment", seconds: 1.2)
                }, didRequestValidation: { (reference) -> Void in
                    // an OTP was requested, transaction has not yet succeeded
                    self.animationView.stop()
                    self.animationView.alpha = 0
                    self.showToast(message: "Ooops... please genetrate  on the doc ", seconds: 1.2)
                }, didTransactionSuccess: { (reference) -> Void in
                    // transaction may have succeeded, please verify on backend


                    let date = Date()
                    let calendar = Calendar.current
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "LLLL"
                    let month = dateFormatter.string(from: date)


                    var dateComponent = DateComponents()
                    dateComponent.day = 30
                    let futureDate = Calendar.current.date(byAdding: dateComponent, to: date)

                    let dateformat = DateFormatter()
                    dateformat.dateFormat = "MM/dd/yy"
                    let paidUpTo = dateformat.string(from: futureDate!)

                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd hh:mm:ss"
                    let now = df.string(from: Date())


                    //Confirm payment and save package to DB
                    let post: [String: Any] = [
                        "fullName": self.fullName,
                        "phoneNo": self.phoneNo,
                        "companyAddress": self.companyAddress,
                        "emailAddress": self.emailAddress,
                        "refereeName": self.refereeName,
                        "refereePhoneNo": self.refereePhoneNo,
                        "price": self.price,
                        "apartment_location": self.apartmentLocation,
                        "apartment_name": self.apartmentName,
                        "date": now,
                        "month": month,
                        "paidUpTo": paidUpTo,
                        "duration": self.duration
                    ]


                    let userId = Auth.auth().currentUser?.uid

                    let ref = Database.database().reference().child("users").child(userId!).child("payment_history")

                    ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                        print(snapshot.childrenCount)


                        let refApartment = Database.database().reference().child("apartments").child(self.key)

                        refApartment.child("Availability").setValue("false")


                        let refUser = Database.database().reference().child("users").child(userId!)
                        refUser.child("payment_date").setValue(now)


                        //save user's data
                        ref.child("\(snapshot.childrenCount + 1)").setValue(post) { (err, resp) in
                            guard err == nil else {
                                print("Posting failed : ")

                                self.animationView.stop()
                                self.animationView.alpha = 0

                                self.cardNumber.alpha = 1
                                self.cvv.alpha = 1
                                self.expiryYear.alpha = 1
                                self.expiryMonth.alpha = 1
                                self.payNow.alpha = 1

                                self.paymentHeader.alpha = 1
                                self.cardNoHeader.alpha = 1
                                self.cvvHeader.alpha = 1
                                self.expiryYearHeader.alpha = 1
                                self.expiryMonthHeader.alpha = 1
                                self.backButton.alpha = 1

                                return
                            }
                            print("No errors while posting, :")
                            //go to home page



                            self.animationView.stop()
                            self.animationView.alpha = 0

                            self.cardNumber.alpha = 1
                            self.cvv.alpha = 1
                            self.expiryYear.alpha = 1
                            self.expiryMonth.alpha = 1
                            self.payNow.alpha = 1

                            self.paymentHeader.alpha = 1
                            self.cardNoHeader.alpha = 1
                            self.cvvHeader.alpha = 1
                            self.expiryYearHeader.alpha = 1
                            self.expiryMonthHeader.alpha = 1
                            self.backButton.alpha = 1


                            self.showToast(message: "Congrats... Payment made, you will be contacted soon", seconds: 2)


                            //transition account
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                    self.performSegue(withIdentifier: "toAccount", sender: nil)
                                })


                        }



                    })


                })



        } else {
            //TODO: take them pack to product details page
            self.animationView.stop()
            self.animationView.alpha = 0

            cardNumber.alpha = 1
            cvv.alpha = 1
            expiryYear.alpha = 1
            expiryMonth.alpha = 1
            payNow.alpha = 1

            paymentHeader.alpha = 1
            cardNoHeader.alpha = 1
            cvvHeader.alpha = 1
            expiryYearHeader.alpha = 1
            expiryMonthHeader.alpha = 1
            backButton.alpha = 1


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
        viewController._apartmentPrices = apartmentPrices
        viewController.apartmentPrices = _apartmentPrices
        
        viewController.view.window?.rootViewController = viewController
        viewController.view.window?.makeKeyAndVisible()

        self.present(viewController, animated: false, completion: nil)
    }


    func validate() -> Bool {

        print("this is expiry month : \(self.expiryMonth.text)  and count \(self.expiryMonth.text?.count),  \(self.expiryMonth.text!.count)")
        
        if self.cvv.text!.count != 3 {
            showToast(message: "Please enter a valid CVV number", seconds: 1.2)
            return false
        } else if self.expiryYear.text!.count != 2 {
            showToast(message: "Please enter a valid expiry year hint: YY", seconds: 1.2)
            return false
        }else if self.expiryMonth.text!.count < 1 || self.expiryMonth.text!.count > 2 {
            
            showToast(message: "Please enter a valid expiry month hint: 1 - 12", seconds: 1.2)
            return false
        }

        return true
    }


}
