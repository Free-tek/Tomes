//
//  ApartmentDetailsViewModel.swift
//  Tomes
//
//  Created by Botosoft Technologies on 08/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import Foundation

struct ApartmentDetailsViewModel{
    var itemImage: String?
    var itemKey: Int?
    
    
    init(apartment: ApartmentDetailsModel) {
        itemImage = apartment.itemImage
        itemKey = apartment.itemKey
    }
}
