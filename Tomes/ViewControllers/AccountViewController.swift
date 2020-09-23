//
//  AccountViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 22/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Lottie

class AccountViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {



    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var paymentHistory: UICollectionView!
    @IBOutlet weak var daysLeftView: UIView!
    @IBOutlet weak var daysLeftTimer: UIImageView!
    @IBOutlet weak var daysLeft: UILabel!
    @IBOutlet weak var paymentHistoryView: UIView!
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    @IBOutlet weak var historyLabel: UILabel!
    
    let animationView = AnimationView();

    let paymentRecordViewModelController: PaymentRecordViewModelController = PaymentRecordViewModelController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElement()

        paymentRecordViewModelController.fetchPaymentHistory(completion: { (success) in
            if !success {
                print("error encountered")
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

            self.welcomeText.text = "Hello, \(firstName)"

            if paymentDate == nil {
                self.daysLeftView.isHidden = true
            } else {
                
                self.daysLeftView.isHidden = false
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                let date = dateFormatter.date(from: paymentDate as! String)

                let startDate = Date()

                let components = Calendar.current.dateComponents([.day], from: startDate, to: date!)

                if 30 - components.day! <= 0 {
                    self.daysLeftView.isHidden = true

                } else if 30 - components.day! == 1 {
                    self.daysLeft.text = "1 day left"

                } else {
                    self.daysLeft.text = "\(30 - components.day!) days left"
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
        
        if paymentRecordViewModelController.viewModelsCount <= 1{
            historyLabel.isHidden = false
        }
        
        return paymentRecordViewModelController.viewModelsCount
    }

    @objc(collectionView: cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = paymentCollectionView.dequeueReusableCell(withReuseIdentifier: "PaymentDetailCollectionViewCell", for: indexPath) as! PaymentDetailCollectionViewCell



        if let viewModel = paymentRecordViewModelController.viewModel(at: indexPath.row) {
            cell.configure(with: viewModel)

//            cell.contentView.layer.cornerRadius = 25
//            cell.contentView.layer.borderWidth = 1.0
//
            

//            cell.contentView.layer.borderColor = UIColor.clear.cgColor
//            cell.contentView.layer.masksToBounds = true
//
//            cell.layer.shadowColor = UIColor.gray.cgColor
//            cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//            cell.layer.shadowRadius = 2.0
//            cell.layer.shadowOpacity = 1.0
//            cell.layer.masksToBounds = false
//            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath


        }


        return cell
    }

    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }

    //get clicked item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {

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

