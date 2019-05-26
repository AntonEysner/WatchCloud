//
//  RegisterVC.swift
//  WatchCloud
//
//  Created by Bogdan Dovgopol on 10/5/19.
//  Copyright © 2019 Bogdan Dovgopol. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordCheckImg: UIImageView!
    @IBOutlet weak var confirmPasswordCheckImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        passwordTxt.addTarget(self, action: #selector(textFieldsDidChange(_:)), for: .editingChanged)
        confirmPasswordTxt.addTarget(self, action: #selector(textFieldsDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldsDidChange(_ textField: UITextField){
        
        guard let password = passwordTxt.text else { return }
        
        if textField == confirmPasswordTxt {
            passwordCheckImg.isHidden = false
            confirmPasswordCheckImg.isHidden = false
        } else {
            if password.isEmpty {
                passwordCheckImg.isHidden = true
                confirmPasswordCheckImg.isHidden = true
                confirmPasswordTxt.text = ""
            }
        }
        
        //when the passwords match, shows green check mark, else red cross
        if passwordTxt.text == confirmPasswordTxt.text {
            passwordCheckImg.image = UIImage(named: AppImages.Check)
            confirmPasswordCheckImg.image = UIImage(named: AppImages.Check)
        } else {
            passwordCheckImg.image = UIImage(named: AppImages.Cross)
            confirmPasswordCheckImg.image = UIImage(named: AppImages.Cross)
        }
        
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        guard let email = emailTxt.text, email.isNotEmpty,
            let password = passwordTxt.text, password.isNotEmpty else {
                simpleAlert(title: "Error", message: "Please fill out all fields.")
                return
                
        }
        
        guard let confirmPass = confirmPasswordTxt.text, confirmPass == password else {
            simpleAlert(title: "Error", message: "Password do not match.")
            return
        }
        
        activityIndicator.startAnimating()
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                debugPrint(error)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                self.activityIndicator.stopAnimating()
                return
            }
            
            guard let fireUser = result?.user else { return }
            let user = User.init(id: fireUser.uid, email: email, stripeId: "")
            
            //upload to firestore
            self.createFirestoreUser(user: user)
        }
        
//        guard let authUser = Auth.auth().currentUser else {
//            return
//        }
//
//        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//        authUser.link(with: credential) { (result, error) in
//            if let error = error {
//                debugPrint(error)
//                Auth.auth().handleFireAuthError(error: error, vc: self)
//                self.activityIndicator.stopAnimating()
//                return
//            }
//
//            self.activityIndicator.stopAnimating()
//            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//        }
        
    }
    
    func createFirestoreUser(user: User) {
        let newUserRef = Firestore.firestore().collection("users").document(user.id)
        
        let data = User.modelToData(user: user)
        
        newUserRef.setData(data) { (error) in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint("Unable to upload an user: \(error.localizedDescription)")
            } else {
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            self.activityIndicator.stopAnimating()
        }

    }
    
    @IBAction func hasAccountClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
