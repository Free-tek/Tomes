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
                                let itemAvailability = json["result"][i]["Availability"].string
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
                    self.viewModels =  self.viewModels.filter({($0?.itemTitle!.lowercased())!.prefix(searchItem1.count) == searchItem1.lowercased()})
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
