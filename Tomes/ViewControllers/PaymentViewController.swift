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

    let paystackPublicKey = "pk_test_4630d972a60683fef74c82acb4e8dace692ff638"
    let card: PSTCKCard = PSTCKCard()
    let animationView = AnimationView();


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
    var occupation = ""
    var emailAddress = ""
    var apartmentLocation = ""
    var apartmentPrices = ""
    var allApartmentPrices = ""
    var duration = ""
    var _apartmentPrices = ""
    var nextOfKinName = ""
    var nextOfKinPhoneNo = ""

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

        
        // building new Paystack Transaction
        if validate() != false && price != 0 {

           
            if apartmentPrices != "" && apartmentPrices.lowercased().contains("weekly") {
                price = Int (apartmentPrices.lowercased().replacingOccurrences(of: "weekly - ₦", with: ""))!
                duration = "weekly"
                

            } else if apartmentPrices != "" && apartmentPrices.lowercased().contains("monthly") {
                price = Int (apartmentPrices.lowercased().replacingOccurrences(of: "monthly - ₦", with: ""))!
                duration = "monthly"

            } else if apartmentPrices != "" && apartmentPrices.lowercased().contains("daily") {
                price = Int (apartmentPrices.lowercased().replacingOccurrences(of: "daily - ₦", with: ""))!
                duration = "daily"

            } else if apartmentPrices != "" && apartmentPrices.lowercased().contains("yearly") {
                price = Int (apartmentPrices.lowercased().replacingOccurrences(of: "yearly - ₦", with: ""))!
                duration = "yearly"

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
                showToast(message: "Ooops... We couldn't process your payment, please check your card details", seconds: 1.2)
            }


            do {
                try transactionParams.setCustomFieldValue("iOS SDK", displayedAs: "Paid Via iOS app");
                try transactionParams.setCustomFieldValue(apartmentName, displayedAs: "Booked");
                try transactionParams.setMetadataValue("iOS SDK", forKey: "paid_via");
                try transactionParams.setMetadataValueDict(custom_filters, forKey: "custom_filters");
                try transactionParams.setMetadataValueArray(items, forKey: "items");
            } catch {
               

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
                showToast(message: "Ooops... We couldnt process your payment, please check your card details", seconds: 1.2)

            }
            transactionParams.email = emailAddress;

            PSTCKAPIClient.shared().chargeCard(cardParams, forTransaction: transactionParams, on: self,
                didEndWithError: { (error, reference) -> Void in
                   

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
                    self.showToast(message: "Ooops... we couldnt make this payment, please check your card details", seconds: 1.2)
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

                    var endDate = 0
                    if self.duration == "daily"{
                        endDate = 1
                    }else if self.duration == "weekly"{
                        endDate = 7
                    }else if self.duration == "monthly"{
                        endDate = 30
                    }else if self.duration == "yearly"{
                        endDate = 365
                    }
                    
                    var dateComponent = DateComponents()
                    dateComponent.day = endDate
                    let futureDate = Calendar.current.date(byAdding: dateComponent, to: date)

                    let dateformat = DateFormatter()
                    dateformat.dateFormat = "MM/dd/yy HH:mm:ss"
                    let paidUpTo = dateformat.string(from: futureDate!)

                    let df = DateFormatter()
                    df.dateFormat = "MM/dd/yy HH:mm:ss"
                    let now = df.string(from: Date())
                    
                    
                    
                    //Confirm payment and save package to DB
                    let post: [String: Any] = [
                        "fullName": self.fullName,
                        "phoneNo": self.phoneNo,
                        "occupation": self.occupation,
                        "emailAddress": self.emailAddress,
                        "price": self.price,
                        "apartment_location": self.apartmentLocation,
                        "apartment_name": self.apartmentName,
                        "date": now,
                        "month": month,
                        "paidUpTo": paidUpTo,
                        "duration": self.duration,
                        "nextOfKinName": self.nextOfKinName,
                        "nextOfKinPhoneNo": self.nextOfKinPhoneNo
                    ]
                    
                    
                    let postOrders: [String: Any] = [
                        "fullName": self.fullName,
                        "phoneNo": self.phoneNo,
                        "occupation": self.occupation,
                        "emailAddress": self.emailAddress,
                        "price": self.price,
                        "apartment_location": self.apartmentLocation,
                        "apartment_name": self.apartmentName,
                        "date": now,
                        "month": month,
                        "paidUpTo": paidUpTo,
                        "duration": self.duration,
                        "nextOfKinName": self.nextOfKinName,
                        "nextOfKinPhoneNo": self.nextOfKinPhoneNo
                    ]


                    
                    
                    let userId = Auth.auth().currentUser?.uid
                    let userRef = Database.database().reference().child("users").child(userId!)
                    userRef.observeSingleEvent(of: .value, with: {
                        (snapshot) in

                        let data = snapshot.value as? [String: Any]
                        let bookedTill = (data?["bookedTill"])
                        let bookedOn = (data?["bookedOn"])
                        
                        if bookedTill == nil || bookedOn == nil{
                            userRef.child("duration").setValue(self.duration)
                            userRef.child("bookedTill").setValue(paidUpTo)
                            userRef.child("bookedOn").setValue(now)
                        }else{
                            
                            let startDate = dateformat.date(from: bookedTill as! String)
                            
                            let today = Date()
                            if today > startDate! || today == startDate! {
                                //today is later than startDate
                                userRef.child("duration").setValue(self.duration)
                                userRef.child("bookedTill").setValue(paidUpTo)
                                userRef.child("bookedOn").setValue(now)
                            }else{
                                let daysLeftComponents = Calendar.current.dateComponents([.day], from: today, to: startDate!)
                                let newEndingDate = Calendar.current.date(byAdding: .day, value: daysLeftComponents.day! + endDate, to: today)
                                let paidUpTo = dateformat.string(from: newEndingDate!)
                                userRef.child("duration").setValue("Top Up")
                                userRef.child("bookedTill").setValue(paidUpTo)
                                userRef.child("bookedOn").setValue(now)
                                userRef.child("totalDays").setValue(Int(daysLeftComponents.day! + endDate))
                                endDate = daysLeftComponents.day! + endDate
                                
                                let refApartment = Database.database().reference().child("apartments").child(self.key)
                                refApartment.child("totalDays").setValue(Int(daysLeftComponents.day! + endDate))
                                
                            }
                            
                            
                        }
                        
                        
                        
                        if bookedTill != nil || bookedOn != nil{
                            let startDate = dateformat.date(from: bookedTill as! String)
                            
                            let today = Date()
                            if today < startDate! && today != startDate!{
                                self.duration = "Top Up"
                            }
                        }
                        
                        
                        let ref = Database.database().reference().child("users").child(userId!).child("payment_history")
                        let refPayments = Database.database().reference().child("payments")

                        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                           
                            let refApartment = Database.database().reference().child("apartments").child(self.key)
                            refApartment.child("Availability").setValue("false")
                            refApartment.child("paidUpTo").setValue(paidUpTo)
                            refApartment.child("currentOccupant").setValue(userId!)
                            refApartment.child("bookedTill").setValue(paidUpTo)
                            refApartment.child("bookingDuration").setValue(self.duration)
                            

                            
                            //save user's data
                            ref.child("\(snapshot.childrenCount + 1)").setValue(post) { (err, resp) in
                                guard err == nil else {
                                   

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
                               
                                //go to home page
                                
                                //----------
                                refPayments.child(now).setValue(postOrders) { (err, resp) in
                                    guard err == nil else {
                                      

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


                                    
                                    let refUser = Database.database().reference().child("users").child(userId!)
                                    refUser.child("nextOfKinName").setValue("\(self.nextOfKinName)")
                                    refUser.child("occupation").setValue("\(self.occupation)")
                                    refUser.child("nextOfKinPhoneNo").setValue("\(self.nextOfKinPhoneNo)")
                                    refUser.child("payment_date").setValue(now)
                                    
                                    self.setUpNotificationsForRenewal(endDate: endDate, planType: self.duration)
                                    self.showToast(message: "Congrats... Payment made, you will be contacted soon", seconds: 2)
                                    
                                    //transition account
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                            self.performSegue(withIdentifier: "backHome_Payment", sender: nil)
                                        })
                                    

                                }



                            }
                            

                        })
                        
                        
                        
                        
                        
                        
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
        viewController._occupation = occupation
        viewController._apartmentPrices = apartmentPrices
        viewController.allApartmentPrices = allApartmentPrices
        viewController.__nextOfKinName = nextOfKinName
        viewController.__nextOfKinPhoneNo = nextOfKinPhoneNo
        viewController.fromProceedToPayment = true
        
        
        viewController.view.window?.rootViewController = viewController
        viewController.view.window?.makeKeyAndVisible()

        self.present(viewController, animated: false, completion: nil)
    }


    func validate() -> Bool {
        
        if self.cvv.text!.count != 3 {
            showToast(message: "Please enter a valid CVV number", seconds: 1.2)
            return false
        }else if self.expiryYear.text!.count != 2 {
            showToast(message: "Please enter a valid expiry year hint: YY", seconds: 1.2)
            return false
        }else if self.expiryMonth.text!.count < 1 || self.expiryMonth.text!.count > 2 {
            showToast(message: "Please enter a valid expiry month hint: 1 - 12", seconds: 1.2)
            return false
            
        }else if String(Array(self.expiryMonth.text!)[0]) == "0" && (Int(String(Array(self.expiryMonth.text!)[1]))! > 9 || Int(String(Array(self.expiryMonth.text!)[1]))! <= 0)  {
            
            showToast(message: "Please enter a valid expiry month hint: 1 - 12", seconds: 1.2)
            return false
        }

        return true
    }
    
    func setUpNotificationsForRenewal(endDate: Int, planType: String){
        let date = Date()
        let calendar = Calendar.current
        let dateformat = DateFormatter()
        dateformat.dateFormat = "MM/dd/yy HH:mm:ss"
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        if self.duration == "daily"{
            
            //75% notification
            let firstNotificationDate = calendar.date(byAdding: .hour, value: 18, to: date)
            
            let notificationDate = dateformat.string(from: firstNotificationDate!)
            let localDate = dateformat.date(from: notificationDate)
            let year = String(NSCalendar.current.component(.year, from: localDate!))
            let month = String(NSCalendar.current.component(.month, from: localDate!))
            let day = String(NSCalendar.current.component(.day, from: localDate!))
            let hour = String(NSCalendar.current.component(.hour, from: localDate!))
            let minute = String(NSCalendar.current.component(.minute, from: localDate!))
            
            
            scheduleLocalNotification(year: Int(year)!, month: Int(month)!, day: Int(day)!, hour: Int(hour)!, minute:  Int(minute)!, percentageUsed: "75%", plan:"daily")
            
            //50% notification
            let secondNotificationDate = calendar.date(byAdding: .hour, value: 12, to: date)
            
            let secondnotificationDate = dateformat.string(from: secondNotificationDate!)
            let secondlocalDate = dateformat.date(from: secondnotificationDate)
            
            let secondyear = String(NSCalendar.current.component(.year, from: secondlocalDate!))
            let secondmonth = String(NSCalendar.current.component(.month, from: secondlocalDate!))
            let secondday = String(NSCalendar.current.component(.day, from: secondlocalDate!))
            let secondhour = String(NSCalendar.current.component(.hour, from: secondlocalDate!))
            let secondminute = String(NSCalendar.current.component(.minute, from: secondlocalDate!))
            
            scheduleLocalNotification(year: Int(secondyear)!, month: Int(secondmonth)!, day: Int(secondday)!, hour: Int(secondhour)!, minute:  Int(secondminute)!, percentageUsed: "50%", plan:"daily")
            
            //25% notification
            let thirdNotificationDate = calendar.date(byAdding: .hour, value: 6, to: date)
            
            let thirdnotificationDate = dateformat.string(from: thirdNotificationDate!)
            let thirdlocalDate = dateformat.date(from: thirdnotificationDate)
            
            let thirdyear = String(NSCalendar.current.component(.year, from: thirdlocalDate!))
            let thirdmonth = String(NSCalendar.current.component(.month, from: thirdlocalDate!))
            let thirdday = String(NSCalendar.current.component(.day, from: thirdlocalDate!))
            let thirdhour = String(NSCalendar.current.component(.hour, from: thirdlocalDate!))
            let thirdminute = String(NSCalendar.current.component(.minute, from: thirdlocalDate!))
            
            scheduleLocalNotification(year: Int(thirdyear)!, month: Int(thirdmonth)!, day: Int(thirdday)!, hour: Int(thirdhour)!, minute:  Int(thirdminute)!, percentageUsed: "25%", plan:"daily")
            
            
        }else if self.duration == "weekly"{
            //75% notification
            let firstNotificationDate = calendar.date(byAdding: .day, value: 5, to: date)
            
            let notificationDate = dateformat.string(from: firstNotificationDate!)
            let localDate = dateformat.date(from: notificationDate)
            let year = String(NSCalendar.current.component(.year, from: localDate!))
            let month = String(NSCalendar.current.component(.month, from: localDate!))
            let day = String(NSCalendar.current.component(.day, from: localDate!))
            let hour = String(NSCalendar.current.component(.hour, from: localDate!))
            let minute = String(NSCalendar.current.component(.minute, from: localDate!))
            
            scheduleLocalNotification(year: Int(year)!, month: Int(month)!, day: Int(day)!, hour: Int(hour)!, minute:  Int(minute)!, percentageUsed: "75%", plan:"weekly")
            
            //50% notification
            let secondNotificationDate = calendar.date(byAdding: .day, value: 3, to: date)
            
            let secondnotificationDate = dateformat.string(from: secondNotificationDate!)
            let secondlocalDate = dateformat.date(from: secondnotificationDate)
            
            let secondyear = String(NSCalendar.current.component(.year, from: secondlocalDate!))
            let secondmonth = String(NSCalendar.current.component(.month, from: secondlocalDate!))
            let secondday = String(NSCalendar.current.component(.day, from: secondlocalDate!))
            let secondhour = String(NSCalendar.current.component(.hour, from: secondlocalDate!))
            let secondminute = String(NSCalendar.current.component(.minute, from: secondlocalDate!))
            
            scheduleLocalNotification(year: Int(secondyear)!, month: Int(secondmonth)!, day: Int(secondday)!, hour: Int(secondhour)!, minute:  Int(secondminute)!, percentageUsed: "50%", plan:"weekly")
            
            //25% notification
            let thirdNotificationDate = calendar.date(byAdding: .day, value: 1, to: date)
            
            let thirdnotificationDate = dateformat.string(from: thirdNotificationDate!)
            let thirdlocalDate = dateformat.date(from: thirdnotificationDate)
            
            let thirdyear = String(NSCalendar.current.component(.year, from: thirdlocalDate!))
            let thirdmonth = String(NSCalendar.current.component(.month, from: thirdlocalDate!))
            let thirdday = String(NSCalendar.current.component(.day, from: thirdlocalDate!))
            let thirdhour = String(NSCalendar.current.component(.hour, from: thirdlocalDate!))
            let thirdminute = String(NSCalendar.current.component(.minute, from: thirdlocalDate!))
            
            scheduleLocalNotification(year: Int(thirdyear)!, month: Int(thirdmonth)!, day: Int(thirdday)!, hour: Int(thirdhour)!, minute:  Int(thirdminute)!, percentageUsed: "25%", plan:"weekly")
            
        }else if self.duration == "monthly"{
            
            //75% notification
            let firstNotificationDate = calendar.date(byAdding: .day, value: 8, to: date)
            
            let notificationDate = dateformat.string(from: firstNotificationDate!)
            let localDate = dateformat.date(from: notificationDate)
            let year = String(NSCalendar.current.component(.year, from: localDate!))
            let month = String(NSCalendar.current.component(.month, from: localDate!))
            let day = String(NSCalendar.current.component(.day, from: localDate!))
            let hour = String(NSCalendar.current.component(.hour, from: localDate!))
            let minute = String(NSCalendar.current.component(.minute, from: localDate!))
            
            scheduleLocalNotification(year: Int(year)!, month: Int(month)!, day: Int(day)!, hour: Int(hour)!, minute:  Int(minute)!, percentageUsed: "75%", plan:"monthly")
            
            //50% notification
            let secondNotificationDate = calendar.date(byAdding: .day, value: 15, to: date)
            
            let secondnotificationDate = dateformat.string(from: secondNotificationDate!)
            let secondlocalDate = dateformat.date(from: secondnotificationDate)
            
            let secondyear = String(NSCalendar.current.component(.year, from: secondlocalDate!))
            let secondmonth = String(NSCalendar.current.component(.month, from: secondlocalDate!))
            let secondday = String(NSCalendar.current.component(.day, from: secondlocalDate!))
            let secondhour = String(NSCalendar.current.component(.hour, from: secondlocalDate!))
            let secondminute = String(NSCalendar.current.component(.minute, from: secondlocalDate!))
            
            scheduleLocalNotification(year: Int(secondyear)!, month: Int(secondmonth)!, day: Int(secondday)!, hour: Int(secondhour)!, minute:  Int(secondminute)!, percentageUsed: "50%", plan:"monthly")
            
            //25% notification
            let thirdNotificationDate = calendar.date(byAdding: .day, value: 23, to: date)
            
            let thirdnotificationDate = dateformat.string(from: thirdNotificationDate!)
            let thirdlocalDate = dateformat.date(from: thirdnotificationDate)
            
            let thirdyear = String(NSCalendar.current.component(.year, from: thirdlocalDate!))
            let thirdmonth = String(NSCalendar.current.component(.month, from: thirdlocalDate!))
            let thirdday = String(NSCalendar.current.component(.day, from: thirdlocalDate!))
            let thirdhour = String(NSCalendar.current.component(.hour, from: thirdlocalDate!))
            let thirdminute = String(NSCalendar.current.component(.minute, from: thirdlocalDate!))
            
            scheduleLocalNotification(year: Int(thirdyear)!, month: Int(thirdmonth)!, day: Int(thirdday)!, hour: Int(thirdhour)!, minute:  Int(thirdminute)!, percentageUsed: "25%", plan:"monthly")
        }else if self.duration == "yearly"{
            
            //75% notification
            let firstNotificationDate = calendar.date(byAdding: .day, value: 91, to: date)
            
            let notificationDate = dateformat.string(from: firstNotificationDate!)
            let localDate = dateformat.date(from: notificationDate)
            let year = String(NSCalendar.current.component(.year, from: localDate!))
            let month = String(NSCalendar.current.component(.month, from: localDate!))
            let day = String(NSCalendar.current.component(.day, from: localDate!))
            let hour = String(NSCalendar.current.component(.hour, from: localDate!))
            let minute = String(NSCalendar.current.component(.minute, from: localDate!))
            
            scheduleLocalNotification(year: Int(year)!, month: Int(month)!, day: Int(day)!, hour: Int(hour)!, minute:  Int(minute)!, percentageUsed: "75%", plan:"yearly")
            
            //50% notification
            let secondNotificationDate = calendar.date(byAdding: .day, value: 182, to: date)
            
            let secondnotificationDate = dateformat.string(from: secondNotificationDate!)
            let secondlocalDate = dateformat.date(from: secondnotificationDate)
            
            let secondyear = String(NSCalendar.current.component(.year, from: secondlocalDate!))
            let secondmonth = String(NSCalendar.current.component(.month, from: secondlocalDate!))
            let secondday = String(NSCalendar.current.component(.day, from: secondlocalDate!))
            let secondhour = String(NSCalendar.current.component(.hour, from: secondlocalDate!))
            let secondminute = String(NSCalendar.current.component(.minute, from: secondlocalDate!))
            
            scheduleLocalNotification(year: Int(secondyear)!, month: Int(secondmonth)!, day: Int(secondday)!, hour: Int(secondhour)!, minute:  Int(secondminute)!, percentageUsed: "50%", plan:"yearly")
            
            //25% notification
            let thirdNotificationDate = calendar.date(byAdding: .day, value: 273, to: date)
            
            let thirdnotificationDate = dateformat.string(from: thirdNotificationDate!)
            let thirdlocalDate = dateformat.date(from: thirdnotificationDate)
            
            let thirdyear = String(NSCalendar.current.component(.year, from: thirdlocalDate!))
            let thirdmonth = String(NSCalendar.current.component(.month, from: thirdlocalDate!))
            let thirdday = String(NSCalendar.current.component(.day, from: thirdlocalDate!))
            let thirdhour = String(NSCalendar.current.component(.hour, from: thirdlocalDate!))
            let thirdminute = String(NSCalendar.current.component(.minute, from: thirdlocalDate!))
            
            scheduleLocalNotification(year: Int(thirdyear)!, month: Int(thirdmonth)!, day: Int(thirdday)!, hour: Int(thirdhour)!, minute:  Int(thirdminute)!, percentageUsed: "25%", plan:"yearly")
            
        }else if self.duration == "Top Up"{
            
            
            //75% notification
            let lastHalf = Int((endDate * 25) / 100)
            let firstNotificationDate = calendar.date(byAdding: .day, value: lastHalf, to: date)
            
            let notificationDate = dateformat.string(from: firstNotificationDate!)
            let localDate = dateformat.date(from: notificationDate)
            let year = String(NSCalendar.current.component(.year, from: localDate!))
            let month = String(NSCalendar.current.component(.month, from: localDate!))
            let day = String(NSCalendar.current.component(.day, from: localDate!))
            let hour = String(NSCalendar.current.component(.hour, from: localDate!))
            let minute = String(NSCalendar.current.component(.minute, from: localDate!))
            
            scheduleLocalNotification(year: Int(year)!, month: Int(month)!, day: Int(day)!, hour: Int(hour)!, minute:  Int(minute)!, percentageUsed: "75%", plan:"yearly")
            
            //50% notification
            let secondHalf = Int((endDate * 50) / 100)
            let secondNotificationDate = calendar.date(byAdding: .day, value: secondHalf, to: date)
            
            let secondnotificationDate = dateformat.string(from: secondNotificationDate!)
            let secondlocalDate = dateformat.date(from: secondnotificationDate)
            
            let secondyear = String(NSCalendar.current.component(.year, from: secondlocalDate!))
            let secondmonth = String(NSCalendar.current.component(.month, from: secondlocalDate!))
            let secondday = String(NSCalendar.current.component(.day, from: secondlocalDate!))
            let secondhour = String(NSCalendar.current.component(.hour, from: secondlocalDate!))
            let secondminute = String(NSCalendar.current.component(.minute, from: secondlocalDate!))
            
            scheduleLocalNotification(year: Int(secondyear)!, month: Int(secondmonth)!, day: Int(secondday)!, hour: Int(secondhour)!, minute:  Int(secondminute)!, percentageUsed: "50%", plan:"yearly")
            
            //25% notification
            let thirdHalf = Int((endDate * 75) / 100)
            let thirdNotificationDate = calendar.date(byAdding: .day, value: thirdHalf, to: date)
            
            let thirdnotificationDate = dateformat.string(from: thirdNotificationDate!)
            let thirdlocalDate = dateformat.date(from: thirdnotificationDate)
            
            let thirdyear = String(NSCalendar.current.component(.year, from: thirdlocalDate!))
            let thirdmonth = String(NSCalendar.current.component(.month, from: thirdlocalDate!))
            let thirdday = String(NSCalendar.current.component(.day, from: thirdlocalDate!))
            let thirdhour = String(NSCalendar.current.component(.hour, from: thirdlocalDate!))
            let thirdminute = String(NSCalendar.current.component(.minute, from: thirdlocalDate!))
            
            scheduleLocalNotification(year: Int(thirdyear)!, month: Int(thirdmonth)!, day: Int(thirdday)!, hour: Int(thirdhour)!, minute:  Int(thirdminute)!, percentageUsed: "25%", plan:"yearly")
        
        }
        
        
    }

    
    func scheduleLocalNotification(year: Int, month: Int, day: Int, hour: Int, minute:  Int, percentageUsed: String, plan: String) {
        
        let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        let yourFireDate = Calendar.current.date(from: dateComponents)

        let notification = UILocalNotification()
        notification.fireDate = yourFireDate
        notification.alertBody = "Hello \(self.fullName), you have used up \(percentageUsed)% of your \(plan) plan, you can renew your subscription now, so the room doesn't go available"
        notification.alertTitle = "TOMES: You have used up \(percentageUsed)% of your \(plan) plan"
        //notification.alertAction = "be awesome!"
        notification.soundName = UILocalNotificationDefaultSoundName
        //notification.userInfo = ["CustomField1": "w00t"]
        notification.applicationIconBadgeNumber += 1
        UIApplication.shared.scheduleLocalNotification(notification)
    }

}
