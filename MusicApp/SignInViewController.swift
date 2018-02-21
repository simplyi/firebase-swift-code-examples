//
//  SignInViewController.swift
//  MusicApp
//
//  Created by Sergey Kargopolov on 2018-01-16.
//  Copyright © 2018 Sergey Kargopolov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class SignInViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var userEmailAddressTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["email"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        
        guard let userEmail = userEmailAddressTextField.text, !userEmail.isEmpty else {
            self.showMessage(messageToDisplay: "User email is required")
            return;
        }
        
        guard let userPassword = userPasswordTextField.text, !userPassword.isEmpty else {
            self.showMessage(messageToDisplay: "User password is required")
            return;
        }
        
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
            
            if let error = error
            {
                print(error.localizedDescription)
                self.showMessage(messageToDisplay: error.localizedDescription)
                return
            }
            
            if user != nil
            {
                Analytics.logEvent(AnalyticsEventLogin, parameters: nil)
                
                self.storeTokens()
                
                if !(user?.isEmailVerified)!
                {
                    self.needToVerifyEmail()
                    return
                }
                
                
                let mainPage = self.storyboard?.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                self.present(mainPage, animated: true, completion: nil)
            }
            
            
        }
        
        
    }
    
    public func needToVerifyEmail()
    {
        let alertController = UIAlertController(title: "Alert title", message: "Email address has not been verified.", preferredStyle: .alert)
        
        let resendEmailAction = UIAlertAction(title: "Resend me email", style: .default) { (action:UIAlertAction!) in
            print("resendEmailAction button tapped");
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                if error == nil
                {
                    print("Email verification request has been successfully sent")
                    try! Auth.auth().signOut()
                } else {
                    self.showMessage(messageToDisplay: "Could not send email verification request. \(String(describing: error?.localizedDescription))")
                    try! Auth.auth().signOut()
                }
            })
            
        }
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel) { (action:UIAlertAction!) in
            // Code in this block will trigger when OK button tapped.
            print("Close button tapped");
            try! Auth.auth().signOut()
        }
        
        
        alertController.addAction(resendEmailAction)
        alertController.addAction(closeAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    public func showMessage(messageToDisplay:String)
    {
        let alertController = UIAlertController(title: "Alert title", message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            // Code in this block will trigger when OK button tapped.
            print("Ok button tapped");
        }
        
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    private func storeTokens()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var databaseReference: DatabaseReference!
        databaseReference = Database.database().reference()
        
        let currentUser = Auth.auth().currentUser
        
        if let apnsToken = appDelegate.sharedData["apnsToken"]
        {
            let userDbRef =  databaseReference.child("users").child(currentUser!.uid)
            userDbRef.child("apnsToken").setValue(apnsToken)
            appDelegate.sharedData.removeValue(forKey: "apnsToken")
        }
        
        if let instanceIdToken = appDelegate.sharedData["instanceIdToken"]
        {
            let userDbRef =  databaseReference.child("users").child(currentUser!.uid)
            userDbRef.child("instanceIdToken").setValue(instanceIdToken)
            appDelegate.sharedData.removeValue(forKey: "instanceIdToken")
        }
    }
    
    func getFullName(firstName: String?, lastName:String?) -> String {
        return firstName! + " "  + lastName!
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error
        {
            print("An error took place \(error.localizedDescription)")
            return
        }
        
        print("Success")
        
        if FBSDKAccessToken.current() == nil
        {
            return
        }
 
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if let error = error {
                print("Could not sign in with Facebook because of: \(error.localizedDescription)")
                self.showMessage(messageToDisplay: error.localizedDescription)
                FBSDKLoginManager().logOut()
                return
            }
            
            // User is signed in
            print("Successfully signed! User id = \(String(describing: user?.uid))")
            print("User email address = \(String(describing: user?.email))")
            
            var userDetails: [String: String] = [:]
            if let userFullName = user?.displayName
            {
                let userNameDetails = userFullName.components(separatedBy: .whitespaces)
                if userNameDetails.count >= 2 {
                    userDetails["firstName"] =  userNameDetails[0]
                    userDetails["lastName"] = userNameDetails[1]
                }
            }
            
            // Store in database
            var databaseReference: DatabaseReference!
            databaseReference = Database.database().reference()
            
            databaseReference.child("users").child(user!.uid).setValue(["userDetails": userDetails])
            
            self.storeTokens()
            
            if !user!.isEmailVerified
            {
                user!.sendEmailVerification(completion: nil)
                
                // alert
                let alertController = UIAlertController(title: "Alert", message: "Your registration is successful. Please check your email and confirm your registration. ", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    
                    // Code in this block will trigger when OK button tapped.
                    FBSDKLoginManager().logOut()
                    try! Auth.auth().signOut()
                }
                
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion:nil)
                // take user back to sign in
            } else {
                let mainPage = self.storyboard?.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = mainPage
            }
            
        }
    
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User signed out")
    }

}
