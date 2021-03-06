//
//  ApartmentDetailsViewModelController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 08/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import Alamofire
import SwiftyJSON

class ApartmentDetailsViewModelController {

    var viewModels: [ApartmentDetailsViewModel?] = []

    func fetchApartments(_ key: String, completion: @escaping (_ success: Bool) -> ()) {

        var apartmentDetailsModel: [ApartmentDetailsModel?] = []
        let Url = String(format: Constants.Endpoints.getApartmentImage)
        let userID = Auth.auth().currentUser?.uid

        let parameters: [String: Any] = [
            "userId": "\(userID!)",
            "productKey": key
        ]

        AF.request(Url, method: .post, parameters: parameters)
            .responseJSON { response in

                do {

                    if response.data != nil {

                        let json = try JSON(data: response.data!)

                        if json["success"][0]["success"].string == "success" {

                            let apartmentImageList = json["result"][0].array

                            for i in 1...apartmentImageList!.count - 1 {
                                let itemImage = apartmentImageList![i].string
                                let itemGotten = ApartmentDetailsModel(itemImage: itemImage!, itemKey: i)
                                apartmentDetailsModel.append(itemGotten)
                            }

                            self.viewModels = self.initViewModels(apartmentDetailsModel)
                            completion(true)

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

    func viewModel(at index: Int) -> ApartmentDetailsViewModel? {
        guard index >= 0 && index < viewModelsCount else { return nil }
        return viewModels[index]
    }


    func initViewModels(_ apartmentImageModel: [ApartmentDetailsModel?]) -> [ApartmentDetailsViewModel?] {
        return apartmentImageModel.map { apartment in
            if let apartment = apartment {
                return ApartmentDetailsViewModel(apartment: apartment)
            } else {
                return nil
            }
        }
    }

}
