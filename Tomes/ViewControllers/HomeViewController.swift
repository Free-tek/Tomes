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
import Lottie

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

    let apartmentListViewModelController: ApartmentListViewModelController = ApartmentListViewModelController()

    var refList: DatabaseReference!
    var locations = [String]()

    var pickerView = UIPickerView()

    var minimumPrice = 120000
    var maximumPrice = 500000

    let animationView = AnimationView();

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()

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

        //fetch locations
        let ref = Database.database().reference().child("locations")

        ref.observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {

                let _location = child.value as! String
                print(_location)
                self.locations.append(_location)

            }
        }
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

