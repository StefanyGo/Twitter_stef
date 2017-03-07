//
//  User.swift
//  Twitter
//
//  Created by Stefany Felicia on 27/2/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class User: NSObject {
    
    static var _currentUser: User? // Current user
    static let userDidLogoutNotification = NSNotification.Name(rawValue: "UserDidLogout") // Notifcation name for logging out
    var info: NSDictionary? // JSON of user information
    var name: String? // Name of user
    var screenName: String? // Username
    var bio: String? // User biography
    var friendCount: Int? // Number of friends
    var followerCount: Int? // Number of followers
    var location: String? // User location
    var profileURL: URL? // Profile image URL
    var verified = false // User verification status
    var followingCount: Int?
    var tweetCount: Int?
    
    init(info: NSDictionary) {
        // Initialize user information
        self.info = info
        name = info["name"] as? String
        screenName = info["screen_name"] as? String
        bio = info["description"] as? String
        friendCount = info["friends_count"] as? Int
        tweetCount = info["statuses_count"] as? Int
        followerCount = info["followers_count"] as? Int
        followingCount = info["friends_count"] as? Int
        bio = info["description"] as? String
        location = info["location"] as? String
        verified = info["verified"] as! Bool
        guard let profileURLString = info["profile_image_url"] as? String else {
            return
        }
        profileURL = URL(string: profileURLString)
    }
    
    // Class variable that allows for setting and gettting current user
    class var currentUser: User? {
        get {
            // Get current user info from user defaults if not loaded
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let data = defaults.object(forKey: "currentUser") as? Data
                if let info = data {
                    let json = try! JSONSerialization.jsonObject(with: info, options: []) as! NSDictionary
                    _currentUser = User(info: json)
                }
            }
            // Return current user
            return _currentUser
        }
        
        set(user) {
            let defaults = UserDefaults.standard
            // Set current user
            guard let user = user else {
                defaults.set(nil, forKey: "currentUser")
                defaults.synchronize()
                return
            }
            
            let info = try! JSONSerialization.data(withJSONObject: user.info!, options: [])
            defaults.set(info, forKey: "currentUser")
            defaults.synchronize()
        }
    }
}
