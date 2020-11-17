//
//  HomeViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 27/08/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import RangeSeekSlider
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Lottie
import OneSignal

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching, RangeSeekSliderDelegate, UIPickerViewDelegate, UIPickerViewDataSource {


    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ApartmentListTableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var backFromFilter: UIButton!
    @IBOutlet weak var priceRangeSlider: RangeSeekSlider!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var goFilter: UIButton!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var header1: UILabel!
    @IBOutlet weak var header2: UILabel!
    @IBOutlet weak var revert: UIButton!
    @IBOutlet weak var noResultIcon: UIImageView!
    @IBOutlet weak var noResultLabel: UILabel!

    
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var cancelRatingView: UIButton!
    @IBOutlet weak var serviceLabel: UILabel!
    
    @IBOutlet weak var oneStar: UIButton!
    @IBOutlet weak var twoStar: UIButton!
    @IBOutlet weak var threeStar: UIButton!
    @IBOutlet weak var fourStar: UIButton!
    @IBOutlet weak var fiveStar: UIButton!
    @IBOutlet weak var nextRating: UIButton!
    
    var services: [String] = ["Power Supply", "Internet Service", "Cleaning Service", "Conduciveness", "Security"]
    var currentService = 0
    var rating = 0
    
    
    let apartmentListViewModelController: ApartmentListViewModelController = ApartmentListViewModelController()

    var refList: DatabaseReference!
    var locations = [String]()
    var lastRatingDate: Date?

    var pickerView = UIPickerView()

    var minimumPrice = 120000
    var maximumPrice = 500000

    let animationView = AnimationView();

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        saveOneSignalId()

        

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
        
        revert.alpha = 0
        noResultIcon.alpha = 0
        noResultLabel.alpha = 0
        
        priceView.layer.cornerRadius = 10
        priceView.clipsToBounds = true

        locationView.layer.cornerRadius = 10
        locationView.clipsToBounds = true

        filterView.alpha = 0
        
        
        goFilter.layer.cornerRadius = 5.0
        goFilter.clipsToBounds = true

        pickerView.delegate = self
        pickerView.dataSource = self
        location.inputView = pickerView


        //setup Slider
        priceRangeSlider.delegate = self
        priceRangeSlider.minValue = 120000
        priceRangeSlider.maxValue = 600000
        priceRangeSlider.selectedMinValue = 125000
        priceRangeSlider.selectedMaxValue = 500000

        priceRangeSlider.numberFormatter.numberStyle = .currency
        priceRangeSlider.numberFormatter.locale = Locale(identifier: "en_NG")
        priceRangeSlider.numberFormatter.maximumFractionDigits = 2
        priceRangeSlider.minLabelFont = UIFont(name: "ChalkboardSE-Regular", size: 15.0)!
        priceRangeSlider.maxLabelFont = UIFont(name: "ChalkboardSE-Regular", size: 15.0)!

        
        filterView.alpha = 0
        filterView.layer.cornerRadius = 10.0
        filterView.clipsToBounds = true

        filterView.layer.borderColor = UIColor.clear.cgColor
        filterView.layer.masksToBounds = true

        filterView.layer.shadowColor = UIColor.gray.cgColor
        filterView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        filterView.layer.shadowRadius = 2.0
        filterView.layer.shadowOpacity = 1.0
        filterView.layer.masksToBounds = false
        filterView.layer.shadowPath = UIBezierPath(roundedRect: filterView.bounds, cornerRadius: filterView.layer.cornerRadius).cgPath
        
        
        

        self.activityIndicator.alpha = 0
        
        filterButton.layer.cornerRadius = 20.0

        hideKeyboardWhenTappedAround()

        ApartmentListTableView.delegate = self
        ApartmentListTableView.dataSource = self
        ApartmentListTableView.register(ApartmentListTableViewCell.nib(), forCellReuseIdentifier: ApartmentListTableViewCell.cellIdentifier)

        ApartmentListTableView.alpha = 0
        ApartmentListTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0);

        ApartmentListTableView.tableFooterView = UIView()

        registerCellForTableView()

        ApartmentListTableView.backgroundColor = UIColor.clear
        
        //fetch locations
        let ref = Database.database().reference().child("locations")

        ref.observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {

                let _location = child.value as! String
                print(_location)
                self.locations.append(_location)

            }
        }
        
        showRating(completionHandler: { (result) in
            
            if !result! {
                
                self.apartmentListViewModelController.fetchApartments(completion: { (success) in
                    if !success {
                        print("error encountered")
                    } else {
                        DispatchQueue.main.async {
                            self.animationView.stop()
                            self.animationView.alpha = 0
                            self.ApartmentListTableView.alpha = 1
                            self.ApartmentListTableView.reloadData()
                        }
                    }
                })
                
            } else {
            
                
                self.animationView.stop()
                self.animationView.alpha = 0
                
                self.ratingView.alpha = 1
                self.ratingView.layer.cornerRadius = 15
                
                self.ratingView.clipsToBounds = true

                self.ratingView.layer.borderColor = UIColor.clear.cgColor
                self.ratingView.layer.masksToBounds = true

                self.ratingView.layer.shadowColor = UIColor.gray.cgColor
                self.ratingView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
                self.ratingView.layer.shadowRadius = 2.0
                self.ratingView.layer.shadowOpacity = 1.0
                self.ratingView.layer.masksToBounds = false
                self.ratingView.layer.shadowPath = UIBezierPath(roundedRect: self.ratingView.bounds, cornerRadius: self.ratingView.layer.cornerRadius).cgPath
                
                
                self.serviceLabel.text = self.services[0].uppercased()
                
                self.nextRating.layer.cornerRadius = 10
                
                
            }

        })
        
    }
    
    func saveOneSignalId(){
        
        let oneSignalUserId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
        
        if oneSignalUserId != nil{
            let userID = Auth.auth().currentUser?.uid
            let refUser = Database.database().reference().child("users").child(userID!)
            refUser.child("oneSignalUserId").setValue(oneSignalUserId)
        }
        
        
    }
    

    func showRating(completionHandler:@escaping (_ result: Bool?)->()){
        
        let userId = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users").child(userId!)

        
        ref.observeSingleEvent(of: .value, with: {
            (snapshot) in

            let data = snapshot.value as? [String: Any]
            let paymentDate = (data?["payment_date"])
            let duration = (data?["duration"])
            let lastRating = (data?["last_rating"])
            
            let startDate = Date()
            
            let _dateFormatter = DateFormatter()
            _dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            
            
            if duration == nil || paymentDate == nil{
                
                completionHandler(false)
            
            }else{
                
                
                let _paymentDate = _dateFormatter.date(from: paymentDate as! String)
                
                let paymentComponents = Calendar.current.dateComponents([.day], from: _paymentDate!, to: startDate)
                
                
                if lastRating == nil{
                    
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd"
                    let dateString = df.string(from: Date())
                    
                    ref.child("last_rating").setValue(dateString)
                    completionHandler(false)
                    
                }
                
                
                if paymentComponents.day! >= 30{
                    
                    
                    completionHandler(false)
                    
                    
                }else if lastRating != nil{
                    
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    self.lastRatingDate = dateFormatter.date(from: lastRating as! String)
                    
                    let components = Calendar.current.dateComponents([.day], from: startDate, to: self.lastRatingDate!)
                    
                    if duration as! String == "monthly" {
                        
                        
                        if components.day! <= -7{
                            
                            let df = DateFormatter()
                            df.dateFormat = "yyyy-MM-dd"
                            let dateString = df.string(from: startDate)
                            
                            ref.child("last_rating").setValue(dateString)
                            completionHandler(true)
                        }
                        
                        else if components.day! <= 0 {
                            completionHandler(false)

                        }else {
                            let df = DateFormatter()
                            df.dateFormat = "yyyy-MM-dd"
                            let dateString = df.string(from: startDate)
                            
                            ref.child("last_rating").setValue(dateString)
                            completionHandler(true)
                        }

                    }else{
                        completionHandler(false)
                    }
                    
                    
                    
                }
                
            }
            
            
        })

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        locations.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locations[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        location.text = locations[row]
        location.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apartmentListViewModelController.viewModelsCount

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ApartmentListTableView.dequeueReusableCell(withIdentifier: ApartmentListTableViewCell.cellIdentifier, for: indexPath) as! ApartmentListTableViewCell

        if let viewModel =
            apartmentListViewModelController.viewModel(at: indexPath.row) {
            cell.configure(with: viewModel)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        150
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //handle  clicks
        let model = apartmentListViewModelController.viewModel(at: indexPath.item)

        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "apartmentDetailsPage") as! ApartmentDetailsViewController

        viewController.key = String(indexPath.item + 1)

        viewController.view.window?.rootViewController = viewController
        viewController.view.window?.makeKeyAndVisible()

        self.present(viewController, animated: false, completion: nil)

    }


    private func registerCellForTableView() {

        let apartmentCellNib = UINib(nibName: "ApartmentListTableViewCell", bundle: nil)
        ApartmentListTableView.register(apartmentCellNib, forCellReuseIdentifier: "ApartmentListTableViewCell")
    }



    @IBAction func backFromFilterFunc(_ sender: Any) {
        filterView.alpha = 0
        searchBar.alpha = 1
        filterButton.alpha = 1
        ApartmentListTableView.alpha = 1
        header1.alpha = 1
        header2.alpha = 1
    }



    @IBAction func filterButtonFunc(_ sender: Any) {
        searchBar.alpha = 0
        filterButton.alpha = 0
        ApartmentListTableView.alpha = 0
        header1.alpha = 0
        header2.alpha = 0
        filterView.alpha = 1

    }

    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        minimumPrice = Int(minValue)
        maximumPrice = Int(maxValue)
    }

    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches \(minimumPrice) :: \(maximumPrice)")
    }

    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches \(minimumPrice) :: \(maximumPrice)")


    }

    
    @IBAction func cancelRatingView(_ sender: Any) {
        
        self.animationView.alpha = 1
        self.animationView.animation = Animation.named("loadingTomes")
        self.animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        self.animationView.center = self.view.center
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
        self.animationView.play()
        self.view.addSubview(self.animationView)
        
        ratingView.alpha=0
        apartmentListViewModelController.fetchApartments(completion: { (success) in
            if !success {
                print("error encountered")
            } else {
                DispatchQueue.main.async {
                    self.animationView.stop()
                    self.animationView.alpha = 0
                    self.ApartmentListTableView.alpha = 1
                    self.ApartmentListTableView.reloadData()
                }
            }
        })
    }
    
    @IBAction func goFilter(_ sender: Any) {

        self.animationView.play()
        self.animationView.alpha = 1

        filterView.alpha = 0
        searchBar.alpha = 1
        filterButton.alpha = 1
        ApartmentListTableView.alpha = 1
        header1.alpha = 1
        header2.alpha = 1

        let price: [Int] = [minimumPrice, maximumPrice]

        apartmentListViewModelController.fetchApartmentSearched("filter", location.text!, price, completion: { (success) in

            if !success {
                print("error encountered")
            } else {
                DispatchQueue.main.async {
                    self.animationView.stop()
                    self.animationView.alpha = 0
                    self.ApartmentListTableView.alpha = 1
                    self.ApartmentListTableView.reloadData()


                    if self.ApartmentListTableView.visibleCells.isEmpty {
                        // no result
                        self.noResultIcon.alpha = 1
                        self.noResultLabel.alpha = 1
                        self.revert.alpha = 1
                        self.ApartmentListTableView.alpha = 0
                    }

                }
            }

        })
    }


    @IBAction func revertFunction(_ sender: Any) {
        noResultIcon.alpha = 0
        noResultLabel.alpha = 0
        revert.alpha = 0

        self.animationView.play()
        self.animationView.alpha = 1
        apartmentListViewModelController.fetchApartments(completion: { (success) in
            if !success {
                print("error encountered")
            } else {
                DispatchQueue.main.async {
                    self.animationView.stop()
                    self.animationView.alpha = 0
                    self.ApartmentListTableView.alpha = 1
                    self.ApartmentListTableView.reloadData()

                    if self.ApartmentListTableView.visibleCells.isEmpty {
                        // no result
                        self.noResultIcon.alpha = 1
                        self.noResultLabel.alpha = 1
                        self.revert.alpha = 1
                        self.ApartmentListTableView.alpha = 0
                    }

                }
            }
        })
    }
    
    
    @IBAction func oneStarFunc(_ sender: Any) {
        self.rating = 1
        oneStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        twoStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
        threeStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
        fourStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
        fiveStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
    }
    
    @IBAction func twoStarFunc(_ sender: Any) {
        self.rating = 2
        twoStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        oneStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        threeStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
        fourStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
        fiveStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)

    }
    
    @IBAction func threeStarFunc(_ sender: Any) {
        self.rating = 3
        threeStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        oneStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        twoStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        fourStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
        fiveStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)

    }
    
    @IBAction func fourStarFunc(_ sender: Any) {
        self.rating = 4
        fourStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        oneStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        twoStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        threeStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        fiveStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)

    }
    
    @IBAction func fiveStarFunc(_ sender: Any) {
        self.rating = 5
        fiveStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        oneStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        twoStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        threeStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
        fourStar.setImage(UIImage(named: "star-filled.png"), for: .normal)
    }
    
    
    @IBAction func nextRatingFunc(_ sender: Any) {
        
        if serviceLabel.text == services[services.count-1]{
            //done
            ratingView.alpha = 0
            
            showToast(message: "Thanks for filling the rating", seconds: 1)
            
            
            apartmentListViewModelController.fetchApartments(completion: { (success) in
                if !success {
                    print("error encountered")
                } else {
                    DispatchQueue.main.async {
                        self.animationView.stop()
                        self.animationView.alpha = 0
                        self.ApartmentListTableView.alpha = 1
                        self.ApartmentListTableView.reloadData()
                    }
                }
            })
            
            
        }else{
            
            oneStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
            twoStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
            threeStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
            fourStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
            fiveStar.setImage(UIImage(named: "star-hollow.png"), for: .normal)
            
            serviceLabel.text = services[currentService+1]
            currentService += 1
            
            if currentService == services.count - 1{
                nextRating.setTitle("Done", for: .normal)
            }
            
            
            
        }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: Date())
        
        let userId = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("ratings").child(dateString).child(userId!)
        
        ref.child("\(services[currentService - 1])").setValue(rating)
        Database.database().reference().child("users").child(userId!).child("last_rating").setValue(dateString)
       
        rating = 0
        
        
        
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.animationView.play()
        self.animationView.alpha = 1

        if searchText == "" {
            revert.alpha = 0
            noResultIcon.alpha = 0
            noResultLabel.alpha = 0

            apartmentListViewModelController.fetchApartments(completion: { (success) in
                if !success {
                    print("error encountered")
                } else {
                    DispatchQueue.main.async {
                        self.animationView.stop()
                        self.animationView.alpha = 0
                        self.ApartmentListTableView.alpha = 1
                        self.ApartmentListTableView.reloadData()
                        
                        self.noResultIcon.alpha = 0
                        self.noResultLabel.alpha = 0
                        self.revert.alpha = 0

                        if self.ApartmentListTableView.visibleCells.isEmpty {
                            // no result
                            self.noResultIcon.alpha = 1
                            self.noResultLabel.alpha = 1
                            self.revert.alpha = 1
                            self.ApartmentListTableView.alpha = 0
                        }
                    }
                }
            })


        } else {

            revert.alpha = 0
            noResultIcon.alpha = 0
            noResultLabel.alpha = 0
            
            apartmentListViewModelController.fetchApartmentSearched("search", searchText, [Int](), completion: { (success) in

                    if !success {
                        print("error encountered")
                    } else {
                        DispatchQueue.main.async {
                            self.animationView.stop()
                            self.animationView.alpha = 0
                            self.ApartmentListTableView.alpha = 1
                            self.ApartmentListTableView.reloadData()

                            if self.ApartmentListTableView.visibleCells.isEmpty {
                                // no result
                                self.noResultIcon.alpha = 1
                                self.noResultLabel.alpha = 1
                                self.revert.alpha = 1
                                self.ApartmentListTableView.alpha = 0
                            }

                        }
                    }

                })
        }





    }
    
}


extension UIView {

    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor = backgroundCGColor
    }
}

