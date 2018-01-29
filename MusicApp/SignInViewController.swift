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

class SignInViewController: UIViewController {
    @IBOutlet weak var userEmailAddressTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

}
