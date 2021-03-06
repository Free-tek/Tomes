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

        let Url = String(format: Constants.Endpoints.getPaymentHistory)
        let userID = Auth.auth().currentUser?.uid

        let parameters: [String: Any] = [
            "userId": "\(userID!)"
        ]

        AF.request(Url, method: .post, parameters: parameters)
            .responseJSON { response in
               

                do {

                    if response.data != nil {

                        let json = try JSON(data: response.data!)

                       
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
                                    let count = Int(json["suggestion_key"][0]["suggestion_key"].string!)!
                                    let suggestion = true
                                    
                                    
                                    let itemGotten = PaymentRecordModel(month: month, paidUpTo: paidUpTo, price: price!, apartmentName: apartmentName!, apartmentLocation: apartmentLocation!, count: count, suggestion: suggestion)
                                    //paymentRecordModel.append(itemGotten)
                                    paymentRecordModel.insert(itemGotten, at: 0)
                                    completion(true)
                                    
                                    self.viewModels = self.initViewModels(paymentRecordModel)
                                    
                                    completion(true)
                                    
                                }else{
                                    let itemGotten = PaymentRecordModel(month: "", paidUpTo: "", price: 0, apartmentName: "", apartmentLocation: "", count: 0, suggestion: true)
                                    
                                    self.viewModels = self.initViewModels(paymentRecordModel)
                                    
                                    completion(true)
                                    paymentRecordModel.append(itemGotten)
                                    completion(false)
                                }
                                

                                
                                
                                
                            }else if json["result"].count >= 1{
                                
                                
                                for i in 1...json["result"][0].count - 1 {
                                    
                                    
                                    let month = json["result"][0][i]["month"].string
                                    let paidUpTo = json["result"][0][i]["paidUpTo"].string
                                    let price = json["result"][0][i]["price"].int
                                    let apartmentName = json["result"][0][i]["apartment_name"].string
                                    let apartmentLocation = json["result"][0][i]["apartment_location"].string
                                    
                                    let count = i

                                   
                                    
                                    let itemGotten = PaymentRecordModel(month: month!, paidUpTo: paidUpTo!, price: price!, apartmentName: apartmentName!,apartmentLocation: apartmentLocation!, count: count, suggestion: false)

                                    if i == 1{
                                        let itemGotten = PaymentRecordModel(month: month!, paidUpTo: paidUpTo!, price: price!, apartmentName: apartmentName!,apartmentLocation: apartmentLocation!, count:count, suggestion: true)
                                        paymentRecordModel.append(itemGotten)
                                    }
                                    paymentRecordModel.insert(itemGotten, at: 0)
                                    
                                }
                                
                                self.viewModels = self.initViewModels(paymentRecordModel)
                                
                                
                                let element = self.viewModels.remove(at: self.viewModelsCount - 1)
                                self.viewModels.insert(element, at: 0)
                                
                                
                               
                                completion(true)

                                
                                
                            }else{
                                completion(false)
                            }
                            
                            

                        } else {
                            //TODO: error occurred
                            
                            completion(false)
                        }


                    } else {

                        //TODO: Network ERROR
                        
                        completion(false)
                    }


                } catch let error as NSError {
                    //TODO: error occurred
                    
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
