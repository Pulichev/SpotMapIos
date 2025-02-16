//
//  FollowerFBItem.swift
//  RideWorld
//
//  Created by Владислав Пуличев on 13.05.17.
//  Copyright © 2017 Владислав Пуличев. All rights reserved.
//

class FollowerFBItem: FeedbackItem {
  
  var userId: String!
  var dateTime: String!
  var userItem: UserItem!
  
  init(snapshot: [String: Any], _ key: String,
       completion: @escaping (_ followerFBItem: FollowerFBItem) -> Void) {
    super.init()
    self.type = 1
    self.key = key
    isViewed = snapshot["isViewed"] as! Bool
    userId   = snapshot["userId"  ] as! String
    dateTime = snapshot["datetime"] as! String
    
    UserModel.getItemById(for: userId) { userItem in
      self.userItem = userItem
      completion(self)
    }
  }
}
