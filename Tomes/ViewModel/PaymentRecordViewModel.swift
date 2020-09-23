//
//  PaymentRecordViewModel.swift
//  Tomes
//
//  Created by Botosoft Technologies on 22/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import Foundation

struct  PaymentRecordViewModel{
    var month: String?
    var paidUpTo: String?
    var price: Int?
    var apartmentName: String?
    var apartmentLocation: String?
    var count: Int?
    
    init( paymentRecord: PaymentRecordModel) {
        self.month = paymentRecord.month
        self.paidUpTo = paymentRecord.paidUpTo
        self.price = paymentRecord.price
        self.apartmentName = paymentRecord.apartmentName
        self.apartmentLocation = paymentRecord.apartmentLocation
        self.count = paymentRecord.count
    }
    
}
