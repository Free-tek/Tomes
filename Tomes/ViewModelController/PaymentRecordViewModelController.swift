//
//  PaymentRecordViewModelController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 22/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import Alamofire
import SwiftyJSON

class PaymentRecordViewModelController {

    var viewModels: [PaymentRecordViewModel?] = []

    func fetchPaymentHistory(completion: @escaping (_ success: Bool) -> ()) {

        var paymentRecordModel: [PaymentRecordModel?] = []

        let Url = String(format: "https://tomesdocker-tuki75gfda-uc.a.run.app/getPaymentHistory")
        let userID = Auth.auth().currentUser?.uid

        let parameters: [String: Any] = [
            "userId": "\(userID!)"
        ]

        AF.request(Url, method: .post, parameters: parameters)
            .responseJSON { response in
                print(response)

                do {

                    if response.data != nil {

                        let json = try JSON(data: response.data!)

                        print("success line \(json["success"][0]["success"])")
                        if json["success"][0]["success"].string == "success" {
                            
                            if json["error"][0]["error"].string == "no history"{
                                
                                if json["suggestion"][0] != ""{
                                    
                                    let date = Date()
                                    let calendar = Calendar.current
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "LLLL"
                                    let _month = dateFormatter.string(from: date)
                                    
                                    
                                    let month = _month
                                    let paidUpTo = ""
                                    let price = json["suggestion"][0]["price"].int
                                    let apartmentName = json["suggestion"][0]["title"].string
                                    let apartmentLocation = json["suggestion"][0]["location"].string
                                    let count = 1
                                    
                                    
                                    let itemGotten = PaymentRecordModel(month: month, paidUpTo: paidUpTo, price: price!, apartmentName: apartmentName!, apartmentLocation: apartmentLocation!, count: count)
                                    paymentRecordModel.append(itemGotten)
                                    completion(true)
                                    
                                    self.viewModels = self.initViewModels(paymentRecordModel)
                                    print("this is the viewmodel \(self.viewModels)")
                                    completion(true)
                                    
                                }else{
                                    let itemGotten = PaymentRecordModel(month: "", paidUpTo: "", price: 0, apartmentName: "", apartmentLocation: "", count: 0)
                                    
                                    self.viewModels = self.initViewModels(paymentRecordModel)
                                    print("this is the viewmodel \(self.viewModels)")
                                    completion(true)
                                    paymentRecordModel.append(itemGotten)
                                    completion(false)
                                }
                                

                                
                                
                                
                            }else if json["result"].count >= 1{
                                
                                for i in 0...json["result"].count - 1 {
                                    
                                    
                                    let month = json["result"][i]["month"].string
                                    let paidUpTo = json["result"][i]["paidUpTo"].string
                                    let price = json["result"][i]["price"].int
                                    let apartmentName = json["result"][i]["apartment_name"].string
                                    let apartmentLocation = json["result"][i]["apartment_location"].string
                                    let count = i+1

                                    let itemGotten = PaymentRecordModel(month: month!, paidUpTo: paidUpTo!, price: price!, apartmentName: apartmentName!,apartmentLocation: apartmentLocation!, count: count)

                                    paymentRecordModel.append(itemGotten)
                                }
                                
                                self.viewModels = self.initViewModels(paymentRecordModel)
                                print("this is the viewmodel \(self.viewModels)")
                                completion(true)

                                
                                
                            }else{
                                completion(false)
                            }
                            
//                            self.viewModels = self.initViewModels(paymentRecordModel)
//                            print("this is the viewmodel \(self.viewModels)")
//                            completion(true)

                            

                        } else {
                            //TODO: error occurred
                            print("error occured")
                            completion(false)
                        }


                    } else {

                        //TODO: Network ERROR
                        print("Network Error")
                        completion(false)
                    }


                } catch let error as NSError {
                    //TODO: error occurred
                    print("error occured")
                    print("Failed to load: \(error.localizedDescription)")
                    completion(false)
                }

        }

    }


    var viewModelsCount: Int {
        return viewModels.count
    }

    func viewModel(at index: Int) -> PaymentRecordViewModel? {
        guard index >= 0 && index < viewModelsCount else { return nil }
        return viewModels[index]
    }


    func initViewModels(_ paymentRecord: [PaymentRecordModel?]) -> [PaymentRecordViewModel?] {
        return paymentRecord.map { paymentRecord in
            if let paymentRecord = paymentRecord {
                return PaymentRecordViewModel(paymentRecord: paymentRecord)
            } else {
                return nil
            }
        }
    }

}
