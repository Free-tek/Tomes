//
//  ApartmentDetailsModel.swift
//  Tomes
//
//  Created by Botosoft Technologies on 08/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import Foundation

struct ApartmentDetailsModel{
    var itemImage: String?
    var itemKey: Int?

    init( itemImage: String?, itemKey: Int?){
        self.itemImage = itemImage
        self.itemKey = itemKey
    }
    
}
