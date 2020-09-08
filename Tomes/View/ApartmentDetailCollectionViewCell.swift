//
//  ApartmentDetailCollectionViewCell.swift
//  Tomes
//
//  Created by Botosoft Technologies on 08/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit

class ApartmentDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var apartmentImage: UIImageView!

    static let cellIdentifier = "ApartmentDetailCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setOpaqueBackground()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    static func nib() -> UINib {
        return UINib(nibName: "ApartmentDetailCollectionViewCell", bundle: nil)
    }

    public func configure(with viewModel: ApartmentDetailsViewModel) {
        
        apartmentImage.setImage(with: viewModel.itemImage!)

    }


}

private extension ApartmentDetailCollectionViewCell {
    static let defaultBackgroundColor = UIColor.groupTableViewBackground

    func setOpaqueBackground() {
        alpha = 1.0
        apartmentImage.alpha = 1.0
    }
}
