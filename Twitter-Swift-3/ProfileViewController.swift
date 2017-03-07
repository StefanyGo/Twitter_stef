//
//  ProfileViewController.swift
//  Twitter-Swift-3
//
//  Created by Stefany Felicia on 7/3/17.
//

import UIKit



class ProfileViewController: UIViewController {
    var user: User?

    @IBOutlet weak var verifiedView: UIImageView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if user == nil {
            user = User.currentUser!
        }
        nameLabel.text = user?.name
        nameLabel.sizeToFit()
        if (user?.verified)! {
            verifiedView.isHidden = false
        }
        nameLabel.text = user?.name
        handleLabel.text = "@\((user?.screenName)!)"
        followersLabel.text = "\((user?.followerCount)!)"
        followingLabel.text = "\((user?.followingCount)!)"
        tweetsLabel.text = "\((user?.tweetCount)!)"
        if let profileURL = user?.profileURL {
            avatarView.sd_setImage(with: profileURL)
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
