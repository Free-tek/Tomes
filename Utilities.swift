//
//  Utilities.swift
//  Tomes
//
//  Created by Botosoft Technologies on 27/08/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import Foundation

import UIKit

class Utilities {

    struct StringAssets {
        static let headerTC = "Terms and Conditions"
        static let bodyTC = "👉 By using the Tomes App you agree that all apartments rented are subject to the Company's rules.\n" + "👉 You can be subject to eviction when your rents are due \n" + "👉 You have only a notice of 3 hours to leave the apartment after your rent expires. \n" + "👉 The company reserves the right to allow you renew your rent or not."
    }


    static func styleTextField(_ textField: UITextField) {

        textField.layer.cornerRadius = 15.0
        textField.tintColor = UIColor.white

    }

    static func noBoundaryTextField(_ textField: UITextField) {
        textField.borderStyle = .none
    }

    static func styleFilledButton(_ button: UIButton) {

        //Filled rounded corner Style
        button.layer.cornerRadius = 15.0
        button.tintColor = UIColor.white
    }

    static func roundButtonImage(_ button: UIButton) {

        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: button.bounds.width - button.bounds.height)
        button.imageView?.layer.cornerRadius = button.bounds.height / 2.0
    }

    static func styleFilledLabel(_ label: UILabel) {

        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15.0
        label.tintColor = UIColor.white
    }

    static func styleFilledTextView(_ textView: UITextView) {


        textView.layer.cornerRadius = 15.0
        textView.tintColor = UIColor.white
    }

    static func styleHollowTextView(_ label: UILabel) {


        label.layer.cornerRadius = 15.0
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.init(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1).cgColor
    }

    static func styleHollowButton(_ button: UIButton) {

        //Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.init(red: 236 / 255, green: 13 / 255, blue: 13 / 255, alpha: 1).cgColor
        button.layer.cornerRadius = 15.0
        //button.tintColor = UIColor.black
    }


    static func styleHollowView(_ view: UIView) {

        //Hollow rounded corner style
        view.layer.cornerRadius = 5.0

    }

    static func styleHollowViewEdge(_ view: UIView) {

        //Hollow rounded corner style
        view.layer.cornerRadius = 10.0
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
    }

    static func roundedImage(_ image: UIImageView) {
        image.layer.borderWidth = 2
        image.layer.borderColor = UIColor.init(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1).cgColor
        image.layer.cornerRadius = 5.0
    }

    static func isPasswordValid(_ password: String) -> Bool {

        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "ˆ(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }

    static func roundCornersImage(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.orange as! CGColor
        imageView.layer.borderWidth = 10

    }

}
