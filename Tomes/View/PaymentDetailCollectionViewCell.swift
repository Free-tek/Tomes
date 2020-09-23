//
//  PaymentDetailCollectionViewCell.swift
//  Tomes
//
//  Created by Botosoft Technologies on 22/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit

class PaymentDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var rent: UILabel!
    @IBOutlet weak var paidUpTo: UILabel!
    @IBOutlet weak var paidUpToLabel: UILabel!
    @IBOutlet weak var nameOfApartment: UILabel!
    @IBOutlet weak var locationOfApartment: UILabel!
    @IBOutlet weak var payNow: UIButton!
    @IBOutlet weak var background: UIView!
    
    static let cellIdentifier = "PaymentDetailCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setOpaqueBackground()
    }


    override func prepareForReuse() {
        super.prepareForReuse()

    }

    static func nib() -> UINib {
        return UINib(nibName: "PaymentDetailCollectionViewCell", bundle: nil)
    }


    public func configure(with viewModel: PaymentRecordViewModel) {
        
        background.layer.cornerRadius = 20
        background.layer.masksToBounds = true
        
        payNow.layer.cornerRadius = 5
        payNow.layer.masksToBounds = true
        
        if viewModel.apartmentName! != ""{
            
        
            month.text = viewModel.month!
            rent.text = "\(viewModel.price!)"
            paidUpTo.text = viewModel.paidUpTo!
            nameOfApartment.text = viewModel.apartmentName!
            locationOfApartment.text = viewModel.apartmentLocation!
            
            if viewModel.count == 1{
                paidUpTo.isHidden = true
                paidUpToLabel.isHidden = true
                background.backgroundColor = UIColor.init(red: 144/255, green: 164/255, blue: 184/255, alpha: 1)
            }else{
                payNow.isHidden = false
                background.backgroundColor = UIColor.init(red: 255/255, green: 77/255, blue: 17/255, alpha: 1)
            }
            
        }
        

        
    }


}

private extension PaymentDetailCollectionViewCell {
    static let defaultBackgroundColor = UIColor.groupTableViewBackground

    func setOpaqueBackground() {
        alpha = 1.0
        
    }
}
