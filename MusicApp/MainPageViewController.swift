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
import MobileCoreServices
import FirebaseStorage
import FirebaseStorageUI
import Firebase

class MainPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
      
        
        print("Full name = \(self.welcomeLabel.text!)")
        let storageReference = Storage.storage().reference()
        // Create a reference to the file you want to download
        let profileImageDownloadUrlReference = storageReference.child("users/\(currentUser!.uid)/profileImage.jpg")
 
        // Placeholder image
        let placeholderImage = UIImage(named: "placeholder.jpg")
 
        // Load the image using SDWebImage
        self.userProfileImageView.sd_setImage(with: profileImageDownloadUrlReference, placeholderImage: placeholderImage)
        
  
        // Fetch the download URL
        
        profileImageDownloadUrlReference.downloadURL { url, error in
            if let error = error {
                // Handle any errors
                print("Error took place \(error.localizedDescription)")
            } else {
                // Get the download URL for 'images/stars.jpg'
                print("Profile image download URL \(String(describing: url!))")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
      
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            
            Analytics.logEvent("signout", parameters: nil)
            
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
    
    @IBAction func setProfileImageButtonTapped(_ sender: Any) {
        let profileImagePicker = UIImagePickerController()
        profileImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        profileImagePicker.mediaTypes = [kUTTypeImage as String]
        profileImagePicker.delegate = self
        present(profileImagePicker, animated: true, completion: nil)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let optimizedImageData = UIImageJPEGRepresentation(profileImage, 0.6)
        {
            // upload image from here
            uploadProfileImage(imageData: optimizedImageData)
        }
        picker.dismiss(animated: true, completion:nil)
    }
    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func uploadProfileImage(imageData: Data)
    {
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        
        let storageReference = Storage.storage().reference()
        let currentUser = Auth.auth().currentUser
        let profileImageRef = storageReference.child("users").child(currentUser!.uid).child("profileImage.jpg")
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
           
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            
            if error != nil
            {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return
            } else {
                
                self.userProfileImageView.image = UIImage(data: imageData)
                
                print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
            }
        }
    }
    
}
