//
//  SpotInfoController.swift
//  RideWorld
//
//  Created by Владислав Пуличев on 30.04.17.
//  Copyright © 2017 Владислав Пуличев. All rights reserved.
//

import UIKit
import Kingfisher
import SVProgressHUD
import Gallery
import Photos

class SpotInfoController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
   
   weak var delegateFollowTaps: FollowTappedFromSpotInfo?
   weak var spotInfoOnMapDelegate: SpotInfoOnMapDelegate?
   
   var spotInfo: SpotItem!
   var user: UserItem!
   @IBOutlet weak var modifyButton: UIButtonX!
   
   @IBOutlet weak var photosCollection: UICollectionView!
   
   var photosURLs = [String]()
   
   @IBOutlet weak var name: UILabel!
   @IBOutlet weak var desc: UILabel!
   
   @IBOutlet weak var addedByUser: UIButton!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      name.text = spotInfo.name
      desc.text = spotInfo.description
      
      initializePhotos()
      initUserLabel()
      initFollowButton()
   }
   
   // MARK: - Photo collection part
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return photosURLs.count
   }
   
   func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(
         withReuseIdentifier: "ImageCollectionViewCell", for: indexPath as IndexPath)
         as! ImageCollectionViewCell
      let photoURL = URL(string: photosURLs[indexPath.row])
      cell.postPicture.kf.setImage(with: photoURL!)
      cell.postPicture.clipsToBounds = true
      cell.postPicture.layer.cornerRadius = 10
      
      return cell
   }
   
   private func initializePhotos() {
      self.photosURLs.append(self.spotInfo.mainPhotoRef)
      Spot.getAllPhotosURLs(for: spotInfo.key) { photoURLs in
         self.photosURLs.append(contentsOf: photoURLs)
         self.photosCollection.reloadData()
      }
   }
   
   // MARK: - initialize user
   private func initUserLabel() {
      UserModel.getItemById(for: spotInfo.addedByUser) { user in
         self.user = user
         self.addedByUser.setTitle(user.login, for: .normal)
      }
   }
   
   @IBAction func userButtonTapped(_ sender: Any) {
      if user.uid == UserModel.getCurrentUserId() {
         self.performSegue(withIdentifier: "goToUserProfileFromSpotInfo", sender: self)
      } else {
         self.performSegue(withIdentifier: "goToRidersProfileFromSpotInfo", sender: self)
      }
   }
   
   //MARK: - follow part
   @IBOutlet weak var followSpotButton: UIButton!
   
   private func initFollowButton() {
      Spot.isCurrentUserFollowingSpot(with: spotInfo.key) { isFollowing in
         if isFollowing {
            self.followSpotButton.setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
         } else {
            self.followSpotButton.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)
         }
         
         self.followSpotButton.isEnabled = true
      }
   }
   
   @IBAction func followSpotButtonTapped(_ sender: Any) {
      if followSpotButton.currentTitle == NSLocalizedString("Follow", comment: "") { // add or remove like
         Spot.addFollowingToSpot(with: spotInfo.key)
      } else {
         Spot.removeFollowingToSpot(with: spotInfo.key)
      }
      
      swapFollowButtonTittle()
      
      if let del = delegateFollowTaps {
         del.followTapped(on: spotInfo.key)
      }
   }
   
   private func swapFollowButtonTittle() {
      if followSpotButton.currentTitle == NSLocalizedString("Follow", comment: "") {
         followSpotButton.setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
      } else {
         followSpotButton.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)
      }
   }
   
   @IBAction func goToPostsButtonTapped(_ sender: UIButton) {
      performSegue(withIdentifier: "fromSpotInfoToSpotPosts", sender: self)
   }
   
   @IBAction func modifyButtonTapped(_ sender: Any) {
      performSegue(withIdentifier: "modifySpot", sender: self)
   }
   
   // MARK: - prepare for segue
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      switch segue.identifier! {
      case "goToRidersProfileFromSpotInfo":
         let newRidersProfileController = segue.destination as! RidersProfileController
         newRidersProfileController.ridersInfo = user
         newRidersProfileController.title = user.login
         
      case "goToUserProfileFromSpotInfo":
         let userProfileController = segue.destination as! UserProfileController
         userProfileController.cameFromSpotDetails = true
         
      case "fromSpotInfoToSpotPosts":
         let postsStripController = segue.destination as! PostsStripController
         postsStripController.spotDetailsItem = spotInfo
         postsStripController.cameFromSpotOrMyStrip = true // came from spot
         
      case "modifySpot":
         let newSpotController = segue.destination as! NewSpotController
         newSpotController.spot = spotInfo
         newSpotController.cameForNewSpot = false
         newSpotController.spotInfoOnMapDelegate = self
         
      default: break
      }
   }
}

extension SpotInfoController: SpotInfoOnMapDelegate {
   func placeSpotOnMap(_ spot: SpotItem) {
      // send updated spot info on map
      spotInfoOnMapDelegate?.placeSpotOnMap(spot)
      // also update info in spotInfo
      spotInfo = spot
      name.text = spotInfo.name
      desc.text = spotInfo.description
      // update main photo (first in array)
      photosURLs[0] = spot.mainPhotoRef
      self.photosCollection.reloadData()
   }
}

// MARK: - Camera extension
extension SpotInfoController : GalleryControllerDelegate {
   
   @IBAction func addPhotoButtonTapped(_ sender: Any) {
      let gallery = GalleryController()
      gallery.delegate = self
      
      Config.Camera.imageLimit = 1
      Config.showsVideoTab = false
      
      present(gallery, animated: true, completion: nil)
   }
   
   func galleryController(_ controller: GalleryController, didSelectImages images: [Gallery.Image]) {
      let img = images[0]
      
      SVProgressHUD.show()
      SpotMedia.uploadForInfo(img.uiImage(ofSize: PHImageManagerMaximumSize)!, for: self.spotInfo.key, with: 270.0) { url in
         if url != nil {
            self.photosURLs.append(url!)
            
            self.photosCollection.reloadData()
         }
         
         SVProgressHUD.dismiss()
      }
      
      controller.dismiss(animated: true, completion: nil)
   }
   
   func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
   }
   
   func galleryController(_ controller: GalleryController, requestLightbox images: [Gallery.Image]) {
   }
   
   func galleryControllerDidCancel(_ controller: GalleryController) {
      controller.dismiss(animated: true, completion: nil)
   }
}
