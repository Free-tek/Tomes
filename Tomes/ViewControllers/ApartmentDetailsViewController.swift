//
//  ApartmentDetailsViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 08/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import AutoScrollCollectionView
import FirebaseAuth
import FirebaseDatabase
import Alamofire
import SwiftyJSON
import Lottie

class ApartmentDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {


    @IBOutlet weak var apartmentImageCollectionView: AutoScrollCollectionView!
    @IBOutlet weak var feature1: UIImageView!
    @IBOutlet weak var feature2: UIImageView!
    @IBOutlet weak var feature3: UIImageView!
    @IBOutlet weak var feature4: UIImageView!
    @IBOutlet weak var feature5: UIImageView!
    @IBOutlet weak var feature6: UIImageView!
    @IBOutlet weak var feature7: UIImageView!
    @IBOutlet weak var feature8: UIImageView!
    @IBOutlet weak var feature9: UIImageView!
    @IBOutlet weak var feature10: UIImageView!
    @IBOutlet weak var backMore: UIButton!
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var viewAllFeatures: UIButton!
    @IBOutlet weak var topFeatureView: UIView!

    @IBOutlet weak var bookView: UIView!
    @IBOutlet weak var orderPrice: UILabel!
    @IBOutlet weak var perMonthLabel: UILabel!
    @IBOutlet weak var bookNow: UIButton!

    @IBOutlet weak var backHome: UIButton!
    var key = ""
    var imagePosition = 0
    var _price = 0
    var _title = ""
    var _apartmentLocation = ""
    var _apartmentAvailability = ""
    var _apartmentPrices = ""
    var canUserRenew: Bool!

    let animationView = AnimationView();
    
    let apartmentDetailsViewModelController: ApartmentDetailsViewModelController = ApartmentDetailsViewModelController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        setUpApartmentFeatures()

        if key != nil{
            apartmentDetailsViewModelController.fetchApartments(key, completion: { (success) in
                if !success {
                    print("error encountered")
                } else {
                    DispatchQueue.main.async {
                        
                        self.animationView.alpha = 1
                        self.animationView.stop()
                        self.apartmentImageCollectionView.alpha = 1
                        self.apartmentImageCollectionView.reloadData()
                        self.apartmentImageCollectionView.startAutoScrolling(withTimeInterval: TimeInterval(exactly: 3.0)!)

                    }
                }
            })
        }
        
        if canUserBookApartment() == false{
            _apartmentAvailability == "false"
        }else{
            _apartmentAvailability == "true"
        }
        
    }

    func setUpElements() {
        
        self.animationView.alpha = 1
        self.animationView.animation = Animation.named("loadingTomes")
        self.animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        self.animationView.center = self.view.center
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
        self.animationView.play()
        self.view.addSubview(self.animationView)

            
        bookView.alpha = 0
        
        viewAllFeatures.alpha = 0
        viewAllFeatures.layer.cornerRadius = 5
        viewAllFeatures.layer.masksToBounds = true
        
       
        
        //set round corner and shadow
        moreView.alpha = 0
        moreView.layer.cornerRadius = 10.0
        moreView.clipsToBounds = true

        moreView.layer.borderColor = UIColor.clear.cgColor
        moreView.layer.masksToBounds = true

        moreView.layer.shadowColor = UIColor.gray.cgColor
        moreView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        moreView.layer.shadowRadius = 2.0
        moreView.layer.shadowOpacity = 1.0
        moreView.layer.masksToBounds = false
        moreView.layer.shadowPath = UIBezierPath(roundedRect: moreView.bounds, cornerRadius: moreView.layer.cornerRadius).cgPath

        bookView.layer.cornerRadius = 10
        bookView.layer.masksToBounds = true

        bookNow.layer.cornerRadius = 10
        bookNow.layer.masksToBounds = true

        apartmentImageCollectionView.register(ApartmentDetailCollectionViewCell.nib(), forCellWithReuseIdentifier: ApartmentDetailCollectionViewCell.cellIdentifier)

        apartmentImageCollectionView.delegate = self
        apartmentImageCollectionView.dataSource = self

        apartmentImageCollectionView.backgroundColor = UIColor(white: 1, alpha: 0.5)

        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height


        let flowLayout = UICollectionViewFlowLayout()
        
        if screenHeight >= 812{
            
            if screenHeight < 896{
                let padding =  (896 - screenHeight) + 150
                flowLayout.itemSize = CGSize(width: screenWidth - 10, height: screenHeight + padding)
            }else{
                let padding =  (screenHeight - 896) + 150
                flowLayout.itemSize = CGSize(width: screenWidth - 10, height: screenHeight + padding)
            }
        
            flowLayout.itemSize = CGSize(width: screenWidth - 10, height: screenHeight + 150)
        
        }else{
            
            flowLayout.itemSize = CGSize(width: screenWidth - 10, height: screenHeight)
        }
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        apartmentImageCollectionView.collectionViewLayout = flowLayout

    }
    
    func canUserBookApartment() -> Bool{
        
        var result = false
        let userID = Auth.auth().currentUser?.uid
        var refList: DatabaseReference!
        refList = Database.database().reference().child("apartments").child(key);
        refList.observeSingleEvent(of: .value, with: {
            (snapshot) in

            let data = snapshot.value as? [String: Any]
            let currentOccupantId = (data?["currentOccupant"])
            let availability = (data?["Availability"])
            
            
            if availability != nil && availability as! String == "false" && currentOccupantId != nil && currentOccupantId as! String == userID{
                result = true
            }
            
        })

        
        return false
        
        
    }

    func setUpApartmentFeatures() {
        var apartmentListModel = [ApartmentListModel?]()
        let Url = String(format: Constants.Endpoints.getApartmentDetails)
        let userID = Auth.auth().currentUser?.uid

        let parameters: [String: Any] = [
            "userId": "\(userID!)",
            "productKey": key

        ]

        AF.request(Url, method: .post, parameters: parameters)
            .responseJSON { response in
                print(response)

                do {
                    if response.data != nil {
                        let json = try JSON(data: response.data!)

                        
                        if json["success"][0]["success"].string == "success" {

                            let furnished = json["result"][0]["furnished"].string
                            let kitchen = json["result"][0]["kitchen"].string
                            let power = json["result"][0]["power"].string
                            let internet = json["result"][0]["internet"].string
                            let security = json["result"][0]["security"].string
                            let transport = json["result"][0]["transport"].string
                            let facility_manager = json["result"][0]["facility_manager"].string
                            let cook = json["result"][0]["cook"].string
                            let laundry = json["result"][0]["laundry"].string
                            let smarttv = json["result"][0]["smarttv"].string
                            self._title = json["result"][0]["title"].string!
                            self._apartmentPrices = json["result"][0]["apartment_prices"].string!
                            self._price = json["result"][0]["price"].int!
                            self._apartmentLocation = json["result"][0]["location"].string!
                            //self._apartmentAvailability = json["result"][0]["Availability"].string!
                           
                            

                            self.orderPrice.text = ("₦\(self._price)")
                            
                            self.bookView.alpha = 1

                            self.feature1.alpha = 0
                            self.feature2.alpha = 0
                            self.feature3.alpha = 0
                            self.feature4.alpha = 0
                            self.feature5.alpha = 0
                            self.feature6.alpha = 0
                            self.feature7.alpha = 0
                            self.feature8.alpha = 0
                            self.feature9.alpha = 0
                            self.feature10.alpha = 0

                            if furnished != nil && furnished! == "true" {
                                self.imagePosition = self.imagePosition + 1
                                self.setImage(self.imagePosition, "furnished")
                            }

                            if kitchen != nil && kitchen! == "true" {
                                self.imagePosition = self.imagePosition + 1
                                self.setImage(self.imagePosition, "kitchen")
                            }

                            if power != nil && power! == "true" {
                                self.imagePosition = self.imagePosition + 1
                                self.setImage(self.imagePosition, "power")
                            }


                            if internet != nil && internet! == "true" {
                                self.imagePosition = self.imagePosition + 1
                                self.setImage(self.imagePosition, "internet")
                            }

                            if security != nil && security! == "true" {
                                self.imagePosition = self.imagePosition + 1
                                self.setImage(self.imagePosition, "security")
                            }

                            if transport != nil && transport! == "true" {
                                self.imagePosition = self.imagePosition + 1
                                self.setImage(self.imagePosition, "onDemandTransportation")
                            }

                            if facility_manager != nil && facility_manager! == "true" {
                                self.viewAllFeatures.alpha = 1
                                self.imagePosition = self.imagePosition + 1
                                self.setImage(self.imagePosition, "facility")
                            }

                            if cook != nil && cook! == "true" {
                                self.imagePosition = self.imagePosition + 1
                                self.setImage(self.imagePosition, "cook")
                            }

                            if laundry != nil && laundry! == "true" {
                                self.imagePosition = self.imagePosition + 1
                                self.setImage(self.imagePosition, "laundry")
                            }
                            
                            if smarttv != nil && smarttv! == "true" {
                                self.imagePosition = self.imagePosition + 1
                                self.setImage(self.imagePosition, "smarttv")
                            }
                            
                            

                        } else {
                            //TODO: error
                        }

                    } else {
                        //TODO: No network

                    }



                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }

        }

    }
    @IBAction func viewAllFeaturesFunc(_ sender: Any) {
        moreView.alpha = 1
        apartmentImageCollectionView.alpha = 1
        bookView.alpha = 0
        topFeatureView.alpha = 0
        viewAllFeatures.alpha = 0
        backHome.alpha  = 0


    }

    @IBAction func backMoreFunc(_ sender: Any) {
        moreView.alpha = 0
        apartmentImageCollectionView.alpha = 1
        bookView.alpha = 1
        topFeatureView.alpha = 1
        viewAllFeatures.alpha = 1
        backHome.alpha  = 1

    }

    @IBAction func bookNowFunc(_ sender: Any) {
        
        if _apartmentAvailability != "true"{
            showToast(message: "Ooops... this apartment is no longer available", seconds: 1.3)
        
        }else{
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let viewController = storyboard.instantiateViewController(withIdentifier: "bookApartmentNow") as! BookApartmentViewController

            viewController.key = key
            viewController.price = _price
            viewController.apartmentName = _title
            viewController.apartmentLocation = _apartmentLocation
            viewController.apartmentAvailability = _apartmentAvailability
            viewController.allApartmentPrices = _apartmentPrices

            viewController.view.window?.rootViewController = viewController
            viewController.view.window?.makeKeyAndVisible()

            self.present(viewController, animated: false, completion: nil)
        }
        
       
        
    }

    func setImage(_ imagePosition: Int, _ imageName: String) {
        switch imagePosition {
        case 1:
            feature1.image = UIImage(named: imageName)
            feature1.alpha = 1
        case 2:
            feature2.image = UIImage(named: imageName)
            feature2.alpha = 1
        case 3:
            feature3.image = UIImage(named: imageName)
            feature3.alpha = 1
        case 4:
            feature4.image = UIImage(named: imageName)
            feature4.alpha = 1
        case 5:
            feature5.image = UIImage(named: imageName)
            feature5.alpha = 1
        case 6:
            feature6.image = UIImage(named: imageName)
            feature6.alpha = 1
        case 7:
            feature7.image = UIImage(named: imageName)
            feature7.alpha = 1
        case 8:
            feature8.image = UIImage(named: imageName)
            feature8.alpha = 1
        case 9:
            feature9.image = UIImage(named: imageName)
            feature9.alpha = 1
        case 10:
            feature10.image = UIImage(named: imageName)
            feature10.alpha = 1
        default:
            print("Out of bounds")
        }
    }

    @objc public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apartmentDetailsViewModelController.viewModelsCount
    }

    @objc(collectionView: cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = apartmentImageCollectionView.dequeueReusableCell(withReuseIdentifier: "ApartmentDetailCollectionViewCell", for: indexPath) as! ApartmentDetailCollectionViewCell

        if let viewModel = apartmentDetailsViewModelController.viewModel(at: indexPath.row) {
            cell.configure(with: viewModel)
        }

        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = view.frame.size.height
        let width = view.frame.size.width
        // in case you you want the cell to be 40% of your controllers view
        return CGSize(width: width-5, height: height+150)
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        let screenRect = UIScreen.main.bounds
//        let screenHeight = screenRect.size.height
//
//        return screenHeight
//
//    }

    //get clicked item
    private func collectionView(_ collectionView: UICollectionView, didSelectRowAt indexPath: IndexPath) {

    }




}
