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

        let Url = String(format: "https://tomesdocker-tuki75gfda-uc.a.run.app/getApartmentImage")
        let userID = Auth.auth().currentUser?.uid

        let parameters: [String: Any] = [
            "userId": "\(userID!)",
            "productKey": key
        ]

        AF.request(Url, method: .post, parameters: parameters)
            .responseJSON { response in
                print(response)

                do {

                    if response.data != nil {

                        let json = try JSON(data: response.data!)

                        print("success line \(json["success"][0]["success"])")
                        if json["success"][0]["success"].string == "success" {

                            let apartmentImageList = json["result"][0].array

                            for i in 1...apartmentImageList!.count - 1 {
                                let itemImage = apartmentImageList![i].string

                                print("this is  the image \(itemImage!)")

                                let itemGotten = ApartmentDetailsModel(itemImage: itemImage!, itemKey: i)

                                apartmentDetailsModel.append(itemGotten)
                            }

                            self.viewModels = self.initViewModels(apartmentDetailsModel)
                            print("this is the viewmodel \(self.viewModels)")
                            completion(true)

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
