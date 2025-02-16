//
//  MainTabBarController.swift
//  RideWorld
//
//  Created by Владислав Пуличев on 25.05.17.
//  Copyright © 2017 Владислав Пуличев. All rights reserved.
//

import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging

class MainTabBarController: UITabBarController {
  
  var delegateFBItemsChanges: FeedbackItemsDelegate?
  
  // MARK: - Add badge to Feedback tab bar item and init FB
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadFeedbackItems()
    setupMiddleButton()
    requestAndRegisterForNotifications()
  }
  
  // MARK: - Middle button part
  var mapBackgroundView: UIViewX!
  var menuButton: MapButton!
  
  func setupMiddleButton() {
    mapBackgroundView = UIViewX(frame: CGRect(x: 0, y: 0, width: 54, height: 54))
    mapBackgroundView.backgroundColor = UIColor.myBlack()
    mapBackgroundView.cornerRadius = 27
    
    var mapBackgroundViewFrame = mapBackgroundView.frame
    mapBackgroundViewFrame.origin.y = view.bounds.height - mapBackgroundViewFrame.height
    mapBackgroundViewFrame.origin.x = view.bounds.width / 2 - mapBackgroundViewFrame.size.width / 2
    mapBackgroundView.frame = mapBackgroundViewFrame
    
    menuButton = MapButton(frame: CGRect(x: 0, y: 0, width: 54, height: 54))
    menuButton.layer.cornerRadius = mapBackgroundViewFrame.height / 2
    mapBackgroundView.addSubview(menuButton)
    view.addSubview(mapBackgroundView)
    
    menuButton.setImage(UIImage(named: "MapIcon"), for: .normal)
    menuButton.tintColor = UIColor.tabBarButtonInActive()
    menuButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
    
    view.layoutIfNeeded()
  }
  
  func showMapButton() {
    tabBar.isHidden            = false
    mapBackgroundView.isHidden = false
    menuButton.isHidden        = false
    menuButton.isEnabled       = true
  }
  
  func hideMapButton() {
    tabBar.isHidden            = true
    mapBackgroundView.isHidden = true
    menuButton.isHidden        = true
    menuButton.isEnabled       = false
  }
  
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    // to change color of map button on active/inActive
    if selectedViewController is MapController {
      menuButton.tintColor = UIColor.myLightBrown()
    } else {
      menuButton.tintColor = UIColor.tabBarButtonInActive()
    }
  }
  
  @objc private func menuButtonAction(sender: UIButton) {
    menuButton.tintColor = UIColor.tabBarButtonActive()
    selectedIndex = 2
  }
  
  // we will send it to FeedbackTab
  var feedbackItems = [FeedbackItem]() {
    didSet {
      addBadgeWithNewFBCount()
      
      if let del = self.delegateFBItemsChanges {
        del.lastUpdate(feedbackItems)
      }
    }
  }
  
  var haveWeFinishedLoading = false // using this parameter on first load of FeedbackController
  
  private func loadFeedbackItems() {
    Feedback.getArray() { fbItems in
      self.feedbackItems = fbItems
      
      self.haveWeFinishedLoading = true
      if let del = self.delegateFBItemsChanges {
        del.lastUpdate(fbItems)
      }
    }
  }
  
  private func addBadgeWithNewFBCount() {
    var countUnViewedFBItems = 0
    
    if feedbackItems.count != 0 {
      for fbItem in feedbackItems {
        if !fbItem.isViewed {
          countUnViewedFBItems += 1
        }
      }
    }
    
    if countUnViewedFBItems != 0 {
      self.tabBar.items![3].badgeValue = String(countUnViewedFBItems)
    } else {
      self.tabBar.items![3].badgeValue = nil
    }
  }
  
  override func viewWillLayoutSubviews() {
    // set height
    var tabFrame = self.tabBar.frame
    // - 40 is editable , the default value is 49 px,
    // below lowers the tabbar and above increases the tab bar size
    tabFrame.size.height = 43
    tabFrame.origin.y = self.view.frame.size.height - 43
    self.tabBar.frame = tabFrame
  }
}

// MARK: - Notifications part
extension MainTabBarController: UNUserNotificationCenterDelegate {
  func requestAndRegisterForNotifications() {
    let application = UIApplication.shared
    
    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
      // For iOS 10 data message (sent via FCM)
      Messaging.messaging().delegate = self
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    guard let token = Messaging.messaging().fcmToken else { return } // sometimes,
    // after reinstalling app or smth like this token sets to nil. Need to wait for
    // didRefreshRegistrationToken function.
    let currentUserId = UserModel.getCurrentUserId()
    UserModel.addFCMToken(to: currentUserId, token)
  }
}

extension MainTabBarController: MessagingDelegate {
  // The callback to handle data message received via FCM for devices running iOS 10 or above.
  func application(received remoteMessage: MessagingRemoteMessage) {
    print(remoteMessage.appData)
  }
  
  func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
    let currentUserId = UserModel.getCurrentUserId()
    
    UserModel.addFCMToken(to: currentUserId, fcmToken)
    // we dont need to delete old token from DB, it will do cloud-function
  }
  
  // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
  // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print("Received data message: \(remoteMessage.appData)")
  }
}
