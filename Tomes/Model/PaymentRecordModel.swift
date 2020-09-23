//
//  PaymentRecordModel.swift
//  Tomes
//
//  Created by Botosoft Technologies on 22/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import Foundation

struct  PaymentRecordModel{
    var month: String?
    var paidUpTo: String?
    var price: Int?
    var apartmentName: String?
    var apartmentLocation: String?
    var count: Int?
    
    init( month: String?, paidUpTo: String?, price: Int?, apartmentName: String?, apartmentLocation: String?, count: Int?) {
        self.month = month
        self.paidUpTo = paidUpTo
        self.price = price
        self.apartmentName = apartmentName
        self.apartmentLocation = apartmentLocation
        self.count = count
        
    }
    
}
