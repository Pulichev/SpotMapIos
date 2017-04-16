//
//  PostModel.swift
//  SpotMap
//
//  Created by Владислав Пуличев on 15.04.17.
//  Copyright © 2017 Владислав Пуличев. All rights reserved.
//

import FirebaseDatabase

struct Post {
    static var refToPostsNode = FIRDatabase.database().reference(withPath: "MainDataBase/spotpost")
    
    static func getItemById(for postId: String,
                            completion: @escaping (_ postItem: PostItem?) -> Void) {
        let refToPost = self.refToPostsNode.child(postId)
        
        refToPost.observeSingleEvent(of: .value, with: { snapshot in
            let postItem = PostItem(snapshot: snapshot)
            
            completion(postItem)
        })
        
        completion(nil) // if no post with this id
    }
    
    static func delete(with postId: String) {
        let refToPostNode = self.refToPostsNode.child(postId)
        refToPostNode.removeValue()
    }
    
    static func getLikesCount(for postId: String,
                              completion: @escaping (_ likesCount: Int) -> Void) {
        let refToPostLikes = self.refToPostsNode.child(postId).child("likes")
        
        // catch if user liked this post
        refToPostLikes.observeSingleEvent(of: .value, with: { snapshot in
            let likesCountInt = snapshot.children.allObjects.count
            completion(likesCountInt)
        })
    }
    
    static func isLikedByUser(_ postId: String,
                              completion: @escaping (_ isLiked: Bool) -> Void) {
        let currentUserId = User.getCurrentUserId()
        
        let refToCurrentUserLikeOnPost = self.refToPostsNode.child(postId).child("likes").child(currentUserId)
        
        refToCurrentUserLikeOnPost.observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.value as? [String : Any]) != nil {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}
