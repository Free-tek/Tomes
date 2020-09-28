//
//  ContactUsViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 28/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController {

    @IBOutlet weak var customerCareIcon: UIImageView!
    @IBOutlet weak var facilityManagerIcon: UIImageView!
    @IBOutlet weak var chefIcon: UIImageView!
    @IBOutlet weak var laundryServiceIcon: UIImageView!
    @IBOutlet weak var cleaningServiceIcon: UIImageView!
    @IBOutlet weak var chaufferServiceIcon: UIImageView!

    @IBOutlet weak var customerCareView: UIView!
    @IBOutlet weak var facilityManagerView: UIView!
    @IBOutlet weak var chefView: UIView!
    @IBOutlet weak var laundryManView: UIView!
    @IBOutlet weak var cleaningServiceView: UIView!
    @IBOutlet weak var chaufferServiceView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }


    func setUpElements() {

      
        customerCareView.layer.cornerRadius = 15
        customerCareView.layer.masksToBounds = true

        facilityManagerView.layer.cornerRadius = 15
        facilityManagerView.layer.masksToBounds = true

        chefView.layer.cornerRadius = 15
        chefView.layer.masksToBounds = true

        laundryManView.layer.cornerRadius = 15
        laundryManView.layer.masksToBounds = true

        cleaningServiceView.layer.cornerRadius = 15
        cleaningServiceView.layer.masksToBounds = true

        chaufferServiceView.layer.cornerRadius = 15
        chaufferServiceView.layer.masksToBounds = true

    }


}
