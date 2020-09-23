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
        let Url = String(format: "https://tomesdocker-tuki75gfda-uc.a.run.app/getApartments")
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
                            for i in 0...json["result"].count-1 {
                                print("at stage \(i)")

                                let itemImage = json["result"][i]["image"].string
                                let itemPrice = json["result"][i]["price"].int
                                let itemTitle = json["result"][i]["title"].string
                                let itemLocation = json["result"][i]["location"].string
                                let itemAvailability = json["result"][i]["Availability"].string
                                let itemKey = "\(i)"

                                print(itemImage!, itemPrice!, itemTitle!, itemLocation!, itemAvailability!, itemKey)
                                
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
                    print("Failed to load: \(error.localizedDescription)")
                }

        }

    }
    
    func fetchApartmentSearched(_ searchType : String, _ searchItem1 : String, _ searchItem2 : [Int], completion: @escaping (_ success: Bool) -> ()){
        
        print("i got called here")
        
        if searchType == "search"{
            fetchApartments(completion: { (success) in
                if !success {
                    completion(false)
                    print("error encountered")
                }else{
                    self.viewModels =  self.viewModels.filter({($0?.itemTitle!.lowercased())!.prefix(searchItem1.count) == searchItem1.lowercased()})
                    completion(true)
                }
            })
        }else{
            //filter operation
            
            print("this was the location serached \(searchItem1)")
            fetchApartments(completion: { (success) in
                if !success {
                    completion(false)
                    print("error encountered")
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
