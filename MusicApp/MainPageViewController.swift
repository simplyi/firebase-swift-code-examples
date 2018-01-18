//
//  MainPageViewController.swift
//  MusicApp
//
//  Created by Sergey Kargopolov on 2018-01-16.
//  Copyright © 2018 Sergey Kargopolov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MainPageViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
      
        let currentUser = Auth.auth().currentUser
        if currentUser == nil
        {
            self.showMessage(messageToDisplay: "Could not read user details")
            
            return
        }
        
        print("User id = \(String(describing: currentUser?.uid))")
        print("User email \(String(describing: currentUser?.email))")
        print("Is email verified \(String(describing: currentUser?.isEmailVerified))")
        
        var databaseReference:DatabaseReference!
        databaseReference = Database.database().reference()
       
    databaseReference.child("users").child((currentUser?.uid)!).child("userDetails").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            
            let userDetailsData = snapshot.value as? NSDictionary
            let firstName = userDetailsData?["firstName"] as? String ?? ""
            let lastName = userDetailsData?["lastName"] as? String ?? ""
            
            
            self.welcomeLabel.text = self.welcomeLabel.text! + " " + firstName + " " + lastName
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
           try Auth.auth().signOut()
            
            let signInPage  = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            
            let appDelegate = UIApplication.shared.delegate
            appDelegate?.window??.rootViewController = signInPage
            
        } catch{
            self.showMessage(messageToDisplay: "Could not sign out at this time")
        }
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
