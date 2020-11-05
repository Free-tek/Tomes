//
//  ApartmentListTableViewCell.swift
//  Tomes
//
//  Created by Botosoft Technologies on 03/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import Kingfisher

class ApartmentListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var apartmentImage: UIImageView!
    @IBOutlet weak var availabilityIcon: UIImageView!
    @IBOutlet weak var availability: UILabel!
    
    static let cellIdentifier = "ApartmentListTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        setOpaqueBackground()
        
        card.layer.cornerRadius = 15
        

    }
    
    
       override func prepareForReuse() {
           super.prepareForReuse()
                   
       }

       static func nib() -> UINib {
           return UINib(nibName: "ApartmentListTableViewCell", bundle: nil)
       }
    
    
    public func configure(with viewModel: ApartmentListViewModel) {
        
        apartmentImage.layer.cornerRadius = 15
        apartmentImage.clipsToBounds = true

        apartmentImage.setImage(with: viewModel.itemImage!)
                
        price.text = "NGN \(viewModel.itemPrice!)"
        title.text = viewModel.itemTitle!
        location.text = (viewModel.itemLocation!)
        
        if viewModel.itemAvailability! == "true"{
            availability.text = "Available"
            availabilityIcon.image = UIImage(named: "available")
        }else{
            availability.text = "Unavailable"
            availabilityIcon.image = UIImage(named: "unavailable")
        }
        
    }
    
}

private extension ApartmentListTableViewCell {
    static let defaultBackgroundColor = UIColor.groupTableViewBackground

    func setOpaqueBackground() {
        alpha = 1.0
        backgroundColor = ApartmentListTableViewCell.defaultBackgroundColor
        
    }
}

extension UIImageView {
    func setImage(with urlString: String){
        guard let url = URL.init(string: urlString) else {
            return
        }
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        var kf = self.kf
        kf.indicatorType = .activity
        self.kf.setImage(with: resource)
    }
}
