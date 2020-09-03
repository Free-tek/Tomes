//
//  ApartmentListViewModel.swift
//  Tomes
//
//  Created by Botosoft Technologies on 03/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import Foundation

struct ApartmentListViewModel{
    var itemImage: String?
    var itemPrice: Int?
    var itemTitle: String?
    var itemLocation: String?
    var itemKey: String?
    var itemAvailability: String?
    
    
    init(apartment: ApartmentListModel) {
        
        itemImage = apartment.itemImage
        itemPrice = apartment.itemPrice
        itemTitle = apartment.itemTitle
        itemLocation = apartment.itemLocation
        itemAvailability = apartment.itemAvailability
        itemKey = apartment.itemKey
    }
}

