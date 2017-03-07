//
//  Tweet.swift
//  Twitter
//
//  Created by Stefany Felicia on 27/2/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import SwiftyJSON
class Tweet: NSObject {
    
    var info: NSDictionary?
    var user: User?
    var reUser: User?
    var isRetweet = false
    var text: String?
    var timestamp: Date?
    var retweetCount: Int?
    var favoriteCount: Int?
    var id: Int?
    var favorited: Bool? = false
    var retweeted: Bool? = false
    
    init(info: NSDictionary) {
        self.info = info
        user = User(info: info["user"] as! NSDictionary)
        text = info["text"] as? String
        retweetCount = info["retweet_count"] as? Int
        favoriteCount = info["favorite_count"] as? Int
        id = info["id"] as? Int
        if let favorited = info["favorited"] as? Bool {
            print(info)
            self.favorited = favorited
        }
        if let retweeted = info["retweeted"] as? Bool {
            self.retweeted = retweeted
        }
        let timestampString = info["created_at"] as? String
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
            timestamp = formatter.date(from: timestampString)
        }
    }
    
    class func tweetsWithArray(infos: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for info in infos {
            let tweet = Tweet(info: info)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
