//
//  ViewController.swift
//  MusicApp
//
//  Created by Sergey Kargopolov on 2018-01-13.
//  Copyright © 2018 Sergey Kargopolov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isRegisteredButtonEnabled = RemoteConfig.remoteConfig().configValue(forKey: "isRegisteredButtonEnabled").boolValue
        
        signupButton.isEnabled = isRegisteredButtonEnabled
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func signupButtonTapped(_ sender: Any) {
     guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
            self.showMessage(messageToDisplay: "First name is required!")
            return;
        }
     guard let lastName = lastNameTextField.text, !lastName.isEmpty else {
            self.showMessage(messageToDisplay: "Last name is required!")
            return;
        }
    guard let userEmailAddress = emailAddressTextField.text, !userEmailAddress.isEmpty else {
            self.showMessage(messageToDisplay: "Email is required!")
            return;
        }
        
    guard let userPassword = passwordTextField.text, !userPassword.isEmpty else {
            self.showMessage(messageToDisplay: "User password is required!")
            return;
        }
    guard let userRepeatPassword = repeatPassword.text, !userRepeatPassword.isEmpty else {
            self.showMessage(messageToDisplay: "User repeat password is required!")
            return;
        }
        
        
        if userPassword != userRepeatPassword
        {
            self.showMessage(messageToDisplay: "User provided passwords do not match")
            return
        }
        
        Auth.auth().createUser(withEmail: userEmailAddress, password: userPassword) { (user, error) in
            
            if let error = error
            {
                print(error.localizedDescription)
                self.showMessage(messageToDisplay: error.localizedDescription)
                return
            }
            
            if let user = user {
               
              Analytics.logEvent(AnalyticsEventSignUp, parameters: nil)
                
                var databaseReference: DatabaseReference!
                databaseReference = Database.database().reference()
                
                let userDetails:[String:String] = ["firstName":firstName, "lastName":lastName]
         databaseReference.child("users").child(user.uid).setValue(["userDetails":userDetails])
                
             user.sendEmailVerification(completion: nil)
                
            // Subscribe to topic
            Messaging.messaging().subscribe(toTopic: "Canada")
            //Messaging.messaging().unsubscribe(fromTopic: "Canada")
                
 
             self.showMessage(messageToDisplay: "We have sent you an email message. Please check your email and click on the link to verify your email address and complete your registration")
 
             let signInPage  = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = signInPage
                
            }
            
        }
     
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
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
 
}

