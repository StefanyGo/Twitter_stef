//
//  FeedViewController.swift
//  Twitter-Swift-3
//
//  Created by Stefany Felicia on 27/2/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import MBProgressHUD
import SDWebImage

protocol FeedViewControllerDelegate {
    func reload()
}
class FeedViewController: UITableViewController, FeedViewControllerDelegate {
    var tweets: [Tweet] = []
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let image : UIImage = UIImage(named: "TwitterLogoBlue.png")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toTop)))
        self.navigationItem.titleView = imageView
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        self.navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toTop)))
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        refreshControl = UIRefreshControl()
        tableView.insertSubview(refreshControl!, at: 0)
        refreshControl?.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
        MBProgressHUD.showAdded(to: self.view, animated: true)
        loadTweets()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweet = tweets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        
        
        // Configure the cell...
        cell.nameLabel.text = tweet.user?.name
        cell.handleLabel.text = "@" + (tweet.user?.screenName)!
        cell.postLabel.text = tweet.text
        cell.retweetLabel.text = "\(tweet.retweetCount!)"
        cell.favoriteLabel.text = "\(tweet.favoriteCount!)"
        cell.retweetLabel.adjustsFontSizeToFitWidth = true
        cell.favoriteLabel.adjustsFontSizeToFitWidth = true
        cell.tweet = tweet
        if (tweet.user?.verified)! {
            print("verified")
            cell.nameLeft.constant = 23.0
            let verifiedView = UIImageView()
            cell.verifiedView.isHidden = false
            print("hi")
        }
        cell.delegate = self
        var time = (tweet.timestamp?.timeIntervalSinceNow)! / -1
        var letter = "s"
        if time > 60 {
            time /= 60
            letter = "m"
            if time > 60 {
                time /= 60
                letter = "h"
                if time > 24 {
                    time /= 24
                    letter = "d"
                    if time > 365 {
                        time /= 365
                        letter = "y"
                    }
                }
                
            }
        }
        cell.timeLabel.text = "\(Int(round(time)))\(letter)"
        if let rt = tweet.retweeted {
            if (rt == true) {
                cell.retweetButton.imageView?.image = UIImage(named: "retweet-icon-green.png")
                
            }
        }
        if let avatarUrl = tweet.user?.profileURL {
            cell.avatarView.sd_setImage(with: avatarUrl, completed: { (image, error, cache, url) in
                cell.avatarView.layer.cornerRadius = 5
            })
        }
        
        return cell
        
    }
    
    func loadTweets() {
        self.view.isUserInteractionEnabled = false
        var parameters: [String: Int] = [:]
        
        if (refreshControl?.isRefreshing)! {
            self.tweets = []
        } else if tweets.count > 0 {
            parameters["max_id"] = tweets[tweets.count - 1].id!
        }
        TwitterClient.sharedInstance?.getHomeTimeline(parameters: parameters, success: { (tweets) in
            let remover = self.tweets.count
            self.tweets += tweets
            if self.tweets.count > remover {
                self.tweets.remove(at: remover)
                
            }
            self.tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
            self.view.isUserInteractionEnabled = true
            self.refreshControl?.endRefreshing()
            self.loadingMoreView?.stopAnimating()
            self.isMoreDataLoading = false
        }, failure: { (error) in
            print(error.localizedDescription)
            MBProgressHUD.hide(for: self.view, animated: true)
            self.view.isUserInteractionEnabled = true
            self.refreshControl?.endRefreshing()
            self.loadingMoreView?.stopAnimating()
            self.isMoreDataLoading = false
        })
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadTweets()
            }
        }
    }
    
    func toTop() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
    }
    
    internal func reload() {
        loadTweets()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detailSegue" {
            let indexPath = sender as! IndexPath
            let vc = segue.destination as! DetailsTableViewController
            vc.tweet = tweets[indexPath.row]
        } else if segue.identifier == "feedtoProfileSegue" {
            let user = sender as! User
            let vc = segue.destination as! ProfileViewController
            vc.user = user
        }

    }
    
    
}
