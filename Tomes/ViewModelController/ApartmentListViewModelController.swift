//
//  ApartmentListViewModelController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 03/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import SwiftyJSON
import FirebaseAuth

class ApartmentListViewModelController {

    var viewModels: [ApartmentListViewModel?] = []

    func fetchApartments(completion: @escaping (_ success: Bool) -> ()) {

        var apartmentListModel = [ApartmentListModel?]()
        let Url = String(format: Constants.Endpoints.fetchApartments)
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
                            for i in 0...json["result"].count-1 {
                                

                                let itemImage = json["result"][i]["image"].string
                                let itemPrice = json["result"][i]["price"].int
                                let itemTitle = json["result"][i]["title"].string
                                let itemLocation = json["result"][i]["location"].string
                                var itemAvailability : String!
                                itemAvailability = json["result"][i]["Availability"].string
                                let currentOccupantId = json["result"][i]["currentOccupant"].string
                                let bookedTill = json["result"][i]["bookedTill"].string
                                let bookingDuration = json["result"][i]["bookingDuration"].string
                             
                                
                                if itemAvailability != nil && itemAvailability as! String == "false" && currentOccupantId != nil && currentOccupantId as! String == userID{
                                    itemAvailability = "true"
                                }else if itemAvailability != nil && itemAvailability! == "false" && bookedTill != nil && bookingDuration != nil{
                                    let bookedTill = json["result"][i]["bookedTill"].string!
                                    let bookingDuration = json["result"][i]["bookingDuration"].string!
                                    
                                    var endDate = 0
                                    if bookingDuration == "daily"{
                                        endDate = 1
                                    }else if bookingDuration == "weekly"{
                                        endDate = 7
                                    }else if bookingDuration == "monthly"{
                                        endDate = 30
                                    }else if bookingDuration == "yearly"{
                                        endDate = 365
                                    }
                                    
                                    if endDate != 0{
                                        
                                        print("availability check here 1")
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "MM/dd/yy HH:mm:ss"
                                        let date = dateFormatter.date(from: bookedTill)
                                        let startDate = Date()
                                        let components = Calendar.current.dateComponents([.day], from: startDate, to: date!)

                                        if bookingDuration == "daily" {
                                            
                                            
                                            
                                            let hourComponents = Calendar.current.dateComponents([.hour], from:  startDate, to: date!)
                                            print("availability check here 2 \(hourComponents.hour) ::: date \(date!)  ::: start \(startDate)")
                                            
                                            if hourComponents.hour! <= 6{
                                                print("availability check here 3")
                                                itemAvailability = "true"
                                            }else{
                                                print("availability check here 4")
                                                itemAvailability = "false"
                                            }
                                            
                                        } else if bookingDuration == "weekly" {

                                            if components.day! <= 1{
                                                itemAvailability = "true"
                                            }

                                        } else if bookingDuration == "monthly" {
                                            
                                            if components.day! <= 8{
                                                itemAvailability = "true"
                                            }

                                        } else if bookingDuration == "yearly" {
                                            
                                            if components.day! <= 92{
                                                itemAvailability = "true"
                                            }
                                            
                                        }
                                        
                                    }
                                    if bookingDuration == "Top Up"{
                                        
                                        let bookedTill = json["result"][i]["bookedTill"].string
                                        let totalDays = json["result"][i]["totalDays"].int
                                        
                                        if bookedTill != nil && totalDays != nil{
                                            
                                            let dateformat = DateFormatter()
                                            dateformat.dateFormat = "MM/dd/yy HH:mm:ss"
                                            let startDate = dateformat.date(from: bookedTill!)
                                            
                                            let today = Date()
                                            if today > startDate! || today == startDate! {
                                                itemAvailability = "true"
                                            }else{
                                                let daysLeftComponents = Calendar.current.dateComponents([.day], from: today, to: startDate!)
                                                if Int(daysLeftComponents.day!) <= Int(Double(totalDays!) * 0.25){
                                                    itemAvailability = "true"
                                                }
                                            }
                                            
                                        }else{
                                            itemAvailability = "true"
                                            
                                        }
                                        
                                        
                                        
                                        
                                    }
                                }
                                
                               
                                
                                let itemKey = "\(i)"
                                let itemGotten = ApartmentListModel(itemImage: itemImage!, itemPrice: itemPrice!, itemTitle: itemTitle!, itemLocation: itemLocation!, itemAvailability: itemAvailability!, itemKey: itemKey)
                                apartmentListModel.append(itemGotten)

                            }

                            self.viewModels = self.initViewModels(apartmentListModel)
                            completion(true)

                        } else {
                            completion(false)
                        }

                    } else {
                        //TODO: No network
                        completion(false)
                    }



                } catch let error as NSError {
                    completion(false)
                }

        }

    }
    
    func fetchApartmentSearched(_ searchType : String, _ searchItem1 : String, _ searchItem2 : [Int], completion: @escaping (_ success: Bool) -> ()){
        
        
        if searchType == "search"{
            fetchApartments(completion: { (success) in
                if !success {
                    completion(false)
                }else{
                    //self.viewModels =  self.viewModels.filter({($0?.itemTitle!.lowercased())!.prefix(searchItem1.count) == searchItem1.lowercased()})
                    
                    
                    self.viewModels =  self.viewModels.filter({($0?.itemLocation!.lowercased())!.prefix(searchItem1.count) == searchItem1.lowercased()})
                    completion(true)
                }
            })
        }else{
            //filter operation
            
            fetchApartments(completion: { (success) in
                if !success {
                    completion(false)
                }else{
                    self.viewModels =  self.viewModels.filter({($0?.itemLocation!.lowercased())!.prefix(searchItem1.count) == searchItem1.lowercased()})
                    
                    self.viewModels =  self.viewModels.filter({($0?.itemPrice!)! >= searchItem2[0] && ($0?.itemPrice!)! <= searchItem2[1]})
                    completion(true)
                }
            })
            
        }
        
    


    }


    var viewModelsCount: Int {
        return viewModels.count
    }

    func viewModel(at index: Int) -> ApartmentListViewModel? {
        guard index >= 0 && index < viewModelsCount else { return nil }
        return viewModels[index]
    }


    func initViewModels(_ apartmentListModel: [ApartmentListModel?]) -> [ApartmentListViewModel?] {
        return apartmentListModel.map { apartment in
            if let apartment = apartment {
                return ApartmentListViewModel(apartment: apartment)
            } else {
                return nil
            }
        }
    }


}
