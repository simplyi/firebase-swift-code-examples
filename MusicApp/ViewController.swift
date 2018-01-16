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

class ViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
                var databaseReference: DatabaseReference!
                databaseReference = Database.database().reference()
                
                let userDetails:[String:String] = ["firstName":firstName, "lastName":lastName]
                
         databaseReference.child("users").child(user.uid).setValue(["userDetails":userDetails])
                
                
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

