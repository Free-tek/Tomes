//
//  ApartmentListModel.swift
//  Tomes
//
//  Created by Botosoft Technologies on 03/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import Foundation

struct ApartmentListModel{
    var itemImage: String?
    var itemPrice: Int?
    var itemTitle: String?
    var itemLocation: String?
    var itemAvailability: String?
    var itemKey: String?

    init( itemImage: String?, itemPrice: Int?, itemTitle: String?,itemLocation: String?, itemAvailability: String?, itemKey: String?){
        self.itemImage = itemImage
        self.itemPrice = itemPrice
        self.itemTitle = itemTitle
        self.itemLocation = itemLocation
        self.itemAvailability = itemAvailability
        self.itemKey = itemKey
    }
    
}
