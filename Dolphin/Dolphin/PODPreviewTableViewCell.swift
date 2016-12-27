//
//  PODPreviewTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/1/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//
import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PODPreviewTableViewCell : CustomFontTableViewCell {
    
    @IBOutlet weak var userLastPost: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var podImageView: UIImageView!
    @IBOutlet weak var podNameLabel: UILabel!
    @IBOutlet weak var podLastPostDateLabel: UILabel!
    @IBOutlet weak var podUsersContainerView: UIView!
    @IBOutlet weak var podImageHeight: NSLayoutConstraint!
    @IBOutlet weak var btnDelete: UIButton!
    
    var pod: POD?
    var triangleView: TriangleView?
//    var delegate : DeletePodProtocol?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Set round border only top.
        let path = UIBezierPath(roundedRect:containerView.bounds, byRoundingCorners:[.topRight, .topLeft], cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        containerView.layer.mask = maskLayer
        
        if pod != nil {
            if pod!.isPrivate == 1 {
                if triangleView == nil {
                    triangleView        = TriangleView()
                }
                triangleView!.frame = CGRect(x: self.containerView.frame.size.width - 60, y: 0, width: 60, height: 60)
                triangleView?.isHidden             = false
                triangleView!.color              = pod!.podColor()
                triangleView!.backgroundColor    = UIColor.clear
                triangleView!.layer.cornerRadius = 5
                self.containerView.addSubview(triangleView!)
                triangleView!.addImage("PrivatePODIcon")
            } else {
                if triangleView != nil {
                    triangleView?.isHidden = true
                }
            }
            
            //Adjust Image Size,
            let image_width = self.pod!.image_width
            let image_height = self.pod!.image_height
            
            adjustImageSize(CGFloat(image_width!), image_height: CGFloat(image_height!))
        }
    }
    
    func configureWithPOD(_ pod: POD) {
        self.backgroundColor = UIColor.clear
        
        containerView.layer.cornerRadius = 5
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 3
        
        self.pod = pod
        //let data = NSData(contentsOfURL: NSURL(string: pod.imageURL!)!)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let urlString = self.convertURL(pod.imageURL!)
            self.podImageView.sd_setImage(with: URL(string: (urlString)), placeholderImage: UIImage(named: "PostImagePlaceholder"))
            /*let data = try? Data(contentsOf: URL(string: urlString)!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            DispatchQueue.main.async(execute: {
                if(data != nil)
                {
                    self.podImageView.image = UIImage(data: data!)
                } else{
                    self.podImageView.sd_setImage(with: URL(string: (pod.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
                }
            }); */
        }
        
        podImageView.contentMode = .scaleAspectFill
        podImageView.layer.masksToBounds = true
        podNameLabel.text                = pod.name
        if let lastPostDate = pod.lastPostDate {
            podLastPostDateLabel.text    = lastPostDate.formattedAsTimeAgo()
        } else {
            podLastPostDateLabel.text    = "No posts yet"
        }
        
        //Adjust Image Size,
        let image_width = self.pod!.image_width
        let image_height = self.pod!.image_height
        
        adjustImageSize(CGFloat(image_width!), image_height: CGFloat(image_height!))
    }
    
    func adjustImageSize(_ image_width: CGFloat, image_height: CGFloat) {
        //        if image_width == 0 || image_height == 0 {
        //            podImageHeight.constant = 130.0
        //        }
        //        else {
        //            let real_width = podImageView.frame.size.width
        //            let real_height = real_width * image_height / image_width
        //            podImageHeight.constant = real_height
        //        }
    }
    
    func addUserImages(_ pod: POD) {
        for userView in podUsersContainerView.subviews {
            userView.removeFromSuperview()
        }
        
        if pod.isPrivate != nil && pod.isPrivate! == 0 {
            
            var count = pod.users?.count
            let offset = CGFloat(6.0)
            let w = podUsersContainerView.frame.size.width / 6
            var x = podUsersContainerView.frame.size.width - offset - w
            
            if count > 5 {
                count = 4
                
                // Add Label that shows number of remaining users in POD
                let otherUsersLabel = UILabel(frame: CGRect(x: x, y: 0, width: w, height: w))
                otherUsersLabel.backgroundColor = UIColor.lightGray
                otherUsersLabel.textColor = UIColor.lightText
                otherUsersLabel.layer.cornerRadius = otherUsersLabel.frame.size.width / 2.0
                otherUsersLabel.layer.masksToBounds = true
                otherUsersLabel.text = String(format: "+%li", arguments: [(pod.users?.count)! - 4])
                otherUsersLabel.textAlignment = .center
                otherUsersLabel.font = UIFont.systemFont(ofSize: 12)
                podUsersContainerView.addSubview(otherUsersLabel)
                
                x = x - w - offset
            }
            
            if count != nil {
                for i in 0 ..< count! {
    //            for var i = count! - 1; i >= 0; i=i-1 {
                    // Sow image of user in POD
                    let index = count! - i - 1
                    let userAvatarImageView = UIImageView(frame: CGRect(x: x, y: 0, width: w, height: w))
                    userAvatarImageView.sd_setImage(with: URL(string: self.convertURL((pod.users![index].userAvatarImageURL)!)), placeholderImage: UIImage(named: "UserPlaceholder"))
                    userAvatarImageView.layer.cornerRadius  = userAvatarImageView.frame.size.width / 2.0
                    userAvatarImageView.layer.masksToBounds = true
                    userAvatarImageView.contentMode         = .scaleAspectFill
                    podUsersContainerView.addSubview(userAvatarImageView)
                    
                    x = x - w - offset
                }
            }
        }
        
        userLastPost.isHidden = true;
        btnDelete.isHidden = true;
        if(pod.isMyFeed != nil && pod.isMyFeed! && pod.total_unread != 0)
        {
            userLastPost.isHidden = false
            //btnDelete.hidden = false;
        }
        
        if(pod.isMyFeed != nil)
        {
            //btnDelete.hidden = false;
        }
        
        if self.pod != nil {
            
            let otherUsersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: userLastPost.frame.size.width, height: userLastPost.frame.size.height))
            otherUsersLabel.backgroundColor = Utils.hexStringToUIColor("#CC0000")//UIColor.redColor()
            otherUsersLabel.textColor = UIColor.white
            otherUsersLabel.layer.cornerRadius = otherUsersLabel.frame.size.width / 2.0
            otherUsersLabel.layer.masksToBounds = true
            otherUsersLabel.text = String(format: "+%li", arguments: [(pod.total_unread)!])
            otherUsersLabel.textAlignment = .center
            otherUsersLabel.font = UIFont.systemFont(ofSize: 12)
            userLastPost.addSubview(otherUsersLabel)
            
        }
        
    }
    
    func convertURL(_ urlString: String) -> String {
        if urlString.contains("http") {
            return urlString
        } else {
            return Constants.RESTAPIConfig.Developement.BaseUrl + urlString
        }
    }
    
//    @IBAction func deleteTapped(sender: AnyObject) {
//        if(delegate != nil)
//        {
//            delegate?.deleteMyPod(self.pod!)
//        }
//    }
    
}
