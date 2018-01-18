//
//  PasswordResetViewController.swift
//  MusicApp
//
//  Created by Sergey Kargopolov on 2018-01-18.
//  Copyright © 2018 Sergey Kargopolov. All rights reserved.
//

import UIKit
import FirebaseAuth

class PasswordResetViewController: UIViewController {
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        guard let emailAddress = emailAddressTextField.text, !emailAddress.isEmpty else {return}
        
        Auth.auth().sendPasswordReset(withEmail: emailAddress) { (error) in
            if error != nil {
                self.showMessage(messageToDisplay: (error?.localizedDescription)!)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
