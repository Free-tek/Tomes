//
//  UserAccountViewController.swift
//  Tomes
//
//  Created by Babatunde Adewole on 10/14/20.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Lottie

class UserAccountViewController: UITabBarController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var daysLeftView: UIView!
    @IBOutlet weak var daysLeftTimer: UIImageView!
    @IBOutlet weak var daysLeft: UILabel!
    @IBOutlet weak var paymentHistoryView: UIView!
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    @IBOutlet weak var historyLabel: UILabel!

    let animationView = AnimationView();

    let paymentRecordViewModelController: PaymentRecordViewModelController = PaymentRecordViewModelController()

    var key = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElement()


        paymentRecordViewModelController.fetchPaymentHistory(completion: { (success) in
            if !success {
                print("error encountered")
                self.animationView.stop()
                self.animationView.alpha = 0
                
            } else {
                DispatchQueue.main.async {
                    self.animationView.stop()
                    self.animationView.alpha = 0

                    self.paymentCollectionView.alpha = 1
                    self.paymentCollectionView.reloadData()
                }
            }
        })


    }

    func setUpElement() {

        daysLeftView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UserAccountViewController.signOut))
        welcomeText.isUserInteractionEnabled = true
        welcomeText.addGestureRecognizer(tap)


        daysLeftView.isHidden = true
        self.animationView.alpha = 1
        self.animationView.animation = Animation.named("loadingTomes")
        self.animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.animationView.center = self.view.center
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
        self.animationView.play()

        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height

        self.view.addSubview(self.animationView)


        paymentCollectionView.delegate = self
        paymentCollectionView.dataSource = self
        paymentCollectionView.register(PaymentDetailCollectionViewCell.nib(), forCellWithReuseIdentifier: PaymentDetailCollectionViewCell.cellIdentifier)

        paymentCollectionView.alpha = 0

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 231, height: 261)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0

        paymentCollectionView.collectionViewLayout = flowLayout


        registerCellForTableView()


        let userID = Auth.auth().currentUser?.uid
        var refList: DatabaseReference!
        refList = Database.database().reference().child("users").child(userID!);


        refList.observe(.value, with: {
            (snapshot) in

            let data = snapshot.value as? [String: Any]
            let firstName = (data?["firstname"]) as! String
            let paymentDate = (data?["payment_date"])

            let duration = (data?["duration"])

            self.welcomeText.text = "Hello, \(firstName)"
            
            print("this is the duration \(duration)")
            if paymentDate == nil || duration == nil {
                self.daysLeftView.isHidden = true
            } else {

                self.daysLeftView.isHidden = false
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                let date = dateFormatter.date(from: paymentDate as! String)

                let startDate = Date()

                let components = Calendar.current.dateComponents([.day], from: date!, to: startDate)

                print("this is the component duration \(components.day)")
                
                if duration as! String == "daily" {
                    
                    if 1 - components.day! <= 0 {
                        self.daysLeftView.isHidden = true

                    } else if 1 - components.day! == 1 {
                        self.daysLeft.text = "1 day left"

                    } else {
                        self.daysLeft.text = "\(1 - components.day!) days left"
                    }

                } else if duration as! String == "weekly" {

                    if 7 - components.day! <= 0 {
                        self.daysLeftView.isHidden = true

                    } else if 7 - components.day! == 1 {
                        self.daysLeft.text = "1 day left"

                    } else {
                        self.daysLeft.text = "\(7 - components.day!) days left"
                    }

                } else if duration as! String == "monthly" {

                    if 30 - components.day! <= 0 {
                        self.daysLeftView.isHidden = true

                    } else if 30 - components.day! == 1 {
                        self.daysLeft.text = "1 day left"

                    } else {
                        self.daysLeft.text = "\(30 - components.day!) days left"
                    }

                }


            }


        })

        daysLeftView.roundCorners([.topLeft, .bottomLeft], radius: 10)
        paymentHistoryView.roundCorners([.topRight, .topLeft], radius: 70)




    }

    private func registerCellForTableView() {

        let paymentCellNib = UINib(nibName: "PaymentDetailCollectionViewCell", bundle: nil)
        paymentCollectionView.register(paymentCellNib, forCellWithReuseIdentifier: "PaymentDetailCollectionViewCell")
    }


    @objc public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if paymentRecordViewModelController.viewModelsCount <= 1 {
            historyLabel.isHidden = false
        }

        return paymentRecordViewModelController.viewModelsCount
    }

    @objc(collectionView: cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = paymentCollectionView.dequeueReusableCell(withReuseIdentifier: "PaymentDetailCollectionViewCell", for: indexPath) as! PaymentDetailCollectionViewCell



        if let viewModel = paymentRecordViewModelController.viewModel(at: indexPath.row) {
            cell.configure(with: viewModel)

            if indexPath.row == 0 {
                cell.payNow.alpha = 1

            }


        }

        key = paymentRecordViewModelController.viewModel(at: indexPath.row)?.count as! Int
        cell.payNow.addTarget(self, action: #selector(payNowFunc(_:)), for: .touchUpInside)


        return cell
    }

    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }

    //get clicked item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {

    }

    @objc func payNowFunc(_ sender: UIButton) {

        print("i am entering with this key \(key)")
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "apartmentDetailsPage") as! ApartmentDetailsViewController

        viewController.key = String(key)

        viewController.view.window?.rootViewController = viewController
        viewController.view.window?.makeKeyAndVisible()

        self.present(viewController, animated: false, completion: nil)


    }



    @IBAction func signOut(sender: UITapGestureRecognizer) {

        let alert = UIAlertController(title: "Proceed?", message: "Do you want to proceed to sign out?.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (upVote) in
            try! Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let viewController = storyboard.instantiateInitialViewController()

            if let viewController = viewController {
                self.view.window?.rootViewController = viewController
                self.view.window?.makeKeyAndVisible()
                self.present(viewController, animated: true, completion: nil)
            }
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (downVote) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)

    }

}

extension UIView {

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            var cornerMask = CACornerMask()
            if(corners.contains(.topLeft)) {
                cornerMask.insert(.layerMinXMinYCorner)
            }
            if(corners.contains(.topRight)) {
                cornerMask.insert(.layerMaxXMinYCorner)
            }
            if(corners.contains(.bottomLeft)) {
                cornerMask.insert(.layerMinXMaxYCorner)
            }
            if(corners.contains(.bottomRight)) {
                cornerMask.insert(.layerMaxXMaxYCorner)
            }
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask

        } else {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }

}


