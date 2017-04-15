//
//  EditProfileController.swift
//  SpotMap
//
//  Created by Владислав Пуличев on 26.02.17.
//  Copyright © 2017 Владислав Пуличев. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import Fusuma

class EditProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var delegate: EditedUserInfoDelegate?
    
    var userInfo: UserItem!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userPhoto: UIImageView!
    
    var userPhotoTemp = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.userPhoto.image = userPhotoTemp
        self.userPhoto.layer.cornerRadius = self.userPhoto.frame.size.height / 2
        
        tableView.tableFooterView = UIView(frame: .zero) // deleting empty rows
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let bioDescription = (tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileCell).field.text!
        let login = (tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! EditProfileCell).field.text!
        let nameAndSename = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditProfileCell).field.text!
        
        // updating values
        UserModel.updateUserInfo(for: self.userInfo.uid, bioDescription, login, nameAndSename)
        
        self.uploadPhoto()
        
        self.returnToParentControllerOnSaveButtonTapped(bioDescription: bioDescription, login: login, nameAndSename: nameAndSename)
    }
    
    func uploadPhoto() {
        UserMainPhoto.upload(for: self.userInfo.uid, with: self.userPhoto.image!, withSize: 150.0)
        
        UserMainPhoto.upload(for: self.userInfo.uid, with: self.userPhoto.image!, withSize: 90.0)
    }
    
    func returnToParentControllerOnSaveButtonTapped(bioDescription: String, login: String, nameAndSename: String) {
        // change current user info and pass it and photo to user profile controller
        self.userInfo.bioDescription = bioDescription
        self.userInfo.login = login
        self.userInfo.nameAndSename = nameAndSename
        
        if let del = delegate {
            del.dataChanged(userInfo: self.userInfo, profilePhoto: self.userPhoto.image!)
        }
        
        // return to profile
        _ = navigationController?.popViewController(animated: true)
    }
    
    //Main table filling region
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCell", for: indexPath) as! EditProfileCell
        let row = indexPath.row
        
        let leftImageView = UIImageView()
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        cell.field.leftViewMode = .always
        
        switch row {
        case 0:
            cell.field.text = userInfo.nameAndSename
            cell.field.placeholder = "Enter new name and sename"
            leftImageView.image = UIImage(named: "nameAndSename.png")
            leftView.addSubview(leftImageView)
            cell.field.leftView = leftView
            break
            
        case 1:
            cell.field.text = userInfo.bioDescription
            cell.field.placeholder = "Enter new bio description"
            leftImageView.image = UIImage(named: "biography.png")
            leftView.addSubview(leftImageView)
            cell.field.leftView = leftView
            break
            
        case 2:
            cell.field.text = userInfo.login
            cell.field.placeholder = "Enter new nickname"
            leftImageView.image = UIImage(named: "login.png")
            leftView.addSubview(leftImageView)
            cell.field.leftView = leftView
            break
            
        case 3:
            cell.field.text = userInfo.email
            cell.field.placeholder = "Enter new email"
            leftImageView.image = UIImage(named: "email.ico")
            leftView.addSubview(leftImageView)
            cell.field.leftView = leftView
            cell.field.isEnabled = false
            break
            
        default:
            break
        }
        
        return cell
    }
    
    var keyBoardAlreadyShowed = false //using this to not let app to scroll view
    //if we tapped UITextField and then another UITextField
}

//Fusuma
extension EditProfileController: FusumaDelegate {
    @IBAction func changeProfilePhotoButtonTapped(_ sender: Any) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = false // If you want to let the users allow to use video.
        self.present(fusuma, animated: true, completion: nil)
    }
    
    // MARK: FusumaDelegate Protocol
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        switch source {
        case .camera:
            print("Image captured from Camera")
        case .library:
            print("Image selected from Camera Roll")
        default:
            print("Image selected")
        }
        
        userPhoto.image = image
        userPhoto.layer.cornerRadius = userPhoto.frame.size.height / 2
        userPhoto.layer.masksToBounds = true
        userPhoto.layer.borderWidth = 0
    }
    
    func fusumaImageSelected(_ image: UIImage) {
        //look example on https://github.com/ytakzk/Fusuma
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        //If u want to use video in future - add code here. You can watch code in NewPostController.swift
    }
    
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        switch source {
        case .camera:
            print("Called just after dismissed FusumaViewController using Camera")
        case .library:
            print("Called just after dismissed FusumaViewController using Camera Roll")
        default:
            print("Called just after dismissed FusumaViewController")
        }
    }
    
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func fusumaClosed() {
        print("Called when the FusumaViewController disappeared")
    }
    
    func fusumaWillClosed() {
        print("Called when the close button is pressed")
    }
}

extension EditProfileController {
    func keyboardWillShow(notification: NSNotification) {
        if !keyBoardAlreadyShowed {
            self.view.frame.origin.y -= 100
            keyBoardAlreadyShowed = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += 100
        keyBoardAlreadyShowed = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
