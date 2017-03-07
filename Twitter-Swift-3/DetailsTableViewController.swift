//
//  DetailsTableViewController.swift
//  Twitter-Swift-3
//
//  Created by Stefany Felicia on 7/3/17.
//

import UIKit

class DetailsTableViewController: UITableViewController {
    
    var tweet: Tweet!
    
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var verifiedView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight=UITableViewAutomaticDimension
        self.avatarView.sd_setImage(with: (tweet.user?.profileURL))
        self.nameLabel.text = tweet.user?.name
        self.nameLabel.sizeToFit()
        self.handleLabel.text = "@\((tweet.user?.screenName)!)"
        self.postLabel.text = tweet.text
        self.postLabel.sizeToFit()
        if tweet.user?.verified == true {
            self.verifiedView.isHidden = false
        }
        self.retweetsLabel.text = "\((tweet.retweetCount)!)"
        self.likesLabel.text = "\((tweet.favoriteCount)!)"
        self.avatarView.layer.cornerRadius = 5
        var dater = DateFormatter()
        dater.dateFormat = "M/d/YYYY, hh:mm a"
        self.timeLabel.text = dater.string(from: tweet.timestamp!)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return 3
    }

    @IBAction func onRetweet(_ sender: Any) {
        if (!(tweet?.retweeted)!) {
            TwitterClient.sharedInstance?.retweet(id: self.tweet!.id!, success: {
                print("retweeted \(self.tweet!.id!)")
                DispatchQueue.main.async {
                    self.retweetButton.imageView?.image = UIImage(named: "retweet-icon-green.png")
                    self.tweet?.retweeted = true
                    self.tweet?.retweetCount = (self.tweet?.retweetCount)! + 1
                    self.retweetsLabel.text = "\((self.tweet?.retweetCount)!)"
                }
                //self.delegate?.reload()
            }, failure: { (error) in
                print("error")
            })
        } else {
            TwitterClient.sharedInstance?.unRetweet(id: self.tweet!.id!, success: {
                print("unretweeted \(self.tweet!.id!)")
                DispatchQueue.main.async {
                    self.retweetButton.imageView?.image = UIImage(named: "retweet-icon.png")
                    self.tweet?.retweeted = true
                    self.tweet?.retweetCount = (self.tweet?.retweetCount)! - 1
                    self.retweetsLabel.text = "\((self.tweet?.retweetCount)!)"
                }
                //self.delegate?.reload()
            }, failure: { (error) in
                print("error")
            })
        }
    }
    
    
    @IBAction func onLike(_ sender: Any) {
        if (!(tweet?.favorited)!) {
            TwitterClient.sharedInstance?.favorite(id: self.tweet!.id!, success: {
                print("favorited \(self.tweet!.id!)")
                DispatchQueue.main.async {
                    self.likeButton.imageView?.image = UIImage(named: "favor-icon-red.png")
                    self.tweet?.favorited = true
                    self.tweet?.favoriteCount = (self.tweet?.favoriteCount)! + 1
                    self.likesLabel.text = "\((self.tweet?.favoriteCount)!)"
                }
            }, failure: { (error) in
                print("error")
            })
        } else {
            TwitterClient.sharedInstance?.unFavorite(id: self.tweet!.id!, success: {
                print("unfavorited \(self.tweet!.id!)")
                DispatchQueue.main.async {
                    self.likeButton.imageView?.image = UIImage(named: "favor-icon.png")
                    self.tweet?.favorited = true
                    self.tweet?.favoriteCount = (self.tweet?.favoriteCount)! - 1
                    self.likesLabel.text = "\((self.tweet?.favoriteCount)!)"
                }
            }, failure: { (error) in
                print("error")
            })
        }

    }
    


    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
