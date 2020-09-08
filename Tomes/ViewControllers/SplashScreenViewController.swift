//
//  SplashScreenViewController.swift
//  Tomes
//
//  Created by Botosoft Technologies on 08/09/2020.
//  Copyright © 2020 Tomes. All rights reserved.
//

import UIKit
import Lottie
import Firebase
import FirebaseAuth

class SplashScreenViewController: UIViewController {

    let animationView = AnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
        checkLogin()
    }

    func setUpElements() {
        self.animationView.alpha = 1
        self.animationView.animation = Animation.named("tomes")
        self.animationView.frame = CGRect(x: 0, y: 0, width: 500, height: 350)
        self.animationView.center = self.view.center
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
        self.animationView.play()
        self.view.addSubview(self.animationView)
    }


    func checkLogin() {
        let userID = Auth.auth().currentUser?.uid
        
        //try! Auth.auth().signOut()
        if userID != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.transitionToHome(userID!)
            })

        } else {
           
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                self.transitionToLogin()
            }
        }

    }

    func transitionToHome(_ userID: String) {
        self.performSegue(withIdentifier: "toHome", sender: nil)
    }

    func transitionToLogin() {
        
        self.animationView.stop()
        self.animationView.alpha = 0
        
        self.performSegue(withIdentifier: "toLogin", sender: nil)
        
    }


}
