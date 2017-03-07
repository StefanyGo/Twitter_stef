//
//  TwitterClient.swift
//  Twitter
//
//  Created by Stefany Felicia on 27/2/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import SwiftyJSON

class TwitterClient: BDBOAuth1SessionManager {
    
    // Singleton for using TwitterClient
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "dfXosGt7CsSKXytrk7NYUZuWU", consumerSecret: "x5YSKcoRNVCDyCNGCybBexGlE1PgILrxtAu38AV0tgRB15wJJ0")
    
    // Login and failure callbacks for login
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    // Login user using OAuth flow
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        // Get token and then ask user to authorize otherwise return error using completion handler
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "tweeter://oauth"), scope: nil, success: { (credential) in
            guard let credential = credential else {
                return
            }
            
            // Create and open URL for authentication
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(credential.token!)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }) { (error) in
            guard let error = error else {
                return
            }
            
            // Return error
            failure(error)
        }
    }
    
    // Handle returning to app from authentication
    func handleOpenURL(url: URL) {
        // Save request token into variable
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        // Get access token using request token otherwise print error
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (credential) in
            guard credential != nil else {
                return
            }
            
            // Get current user information and save it to persistant storage
            self.currentAccount(success: { (user) in
                User.currentUser = user
                self.loginSuccess!()
            }, failure: { (error) in
                // Return error
                self.loginFailure!(error)
            })
        }) { (error) in
            guard let error = error else {
                return
            }
            
            // Return error
            self.loginFailure!(error)
        }
    }
    
    // Get current user information
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        // Get request to endpoint for user information given that application is authorized
        self.get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task, response) in
            guard let response = response as? NSDictionary else {
                return
            }
            
            // Create user using information
            let user = User(info: response)
            success(user)
        }) { (task, error) in
            // Return error
            failure(error)
        }
    }
    
    // Logout user 
    func logout() {
        // Clear current user
        UserDefaults.standard.set(nil, forKey: "currentUser")
        UserDefaults.standard.synchronize()
        User.currentUser = nil
        deauthorize()
        
        // Post notification to logout
        NotificationCenter.default.post(name: User.userDidLogoutNotification, object: nil)
    }
    
    // Get user's timeline
    func getHomeTimeline(parameters: [String: Int]?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        // Get request using token
        self.get("1.1/statuses/home_timeline.json", parameters: parameters, progress: nil, success: { (task, response) in
            guard let response = response as? [NSDictionary] else {
                return
            }
            
            print(JSON(response))
            // Parse tweets and return
            let tweets = Tweet.tweetsWithArray(infos: response)
            success(tweets)
        }) { (task, error) in
            
            //Return error
            failure(error)
        }
        
    }
    
    func retweet(id: Int, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        self.post("https://api.twitter.com/1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task, response) in
            success()
        }) { (task, error) in
            failure(error)
        }
    }
    
    func unRetweet(id: Int, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        self.post("https://api.twitter.com/1.1/statuses/unretweet/\(id).json", parameters: nil, progress: nil, success: { (task, response) in
            success()
        }) { (task, error) in
            failure(error)
        }
    }
    
    func favorite(id: Int, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        self.post("https://api.twitter.com/1.1/favorites/create.json?id=\(id)", parameters: nil, progress: nil, success: { (task, response) in
            success()
        }) { (task, error) in
            failure(error)
        }
    }
    
    func unFavorite(id: Int, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        self.post("https://api.twitter.com/1.1/favorites/destroy.json?id=\(id)", parameters: nil, progress: nil, success: { (task, response) in
            success()
        }) { (task, error) in
            failure(error)
        }
    }
}
