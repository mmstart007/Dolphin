//
//  MyPODPreviewCollectionViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/14/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class MyPODPreviewCollectionViewCell : CustomFontCollectionViewCell {
    
    @IBOutlet weak var podImageView: UIImageView!
    @IBOutlet weak var podTitleLabel: UILabel!
    @IBOutlet weak var unreadLabel: UILabel!
    @IBOutlet weak var otherUsersLabel: UILabel!
    @IBOutlet weak var lastPostDateLabel: UILabel!
    @IBOutlet weak var createPODView: UIView!
   
  
    
    var pod: POD?
    var triangleView: TriangleView?
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            let separation: CGFloat = 6.0
            frame.origin.x          += separation
            frame.origin.y          += separation
            frame.size.width        = frame.size.width - (separation * 2.0)
            frame.size.height       = frame.size.height - (separation * 2.0)
            super.frame             = frame
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
        unreadLabel.isHidden = true
        self.refreshLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.refreshLayout()
    }
    
    func refreshLayout(){
        
        otherUsersLabel.layer.cornerRadius = otherUsersLabel.frame.size.height / 2
        otherUsersLabel.clipsToBounds = true
        otherUsersLabel.layer.masksToBounds = true
        otherUsersLabel.backgroundColor = UIColor.lightGray
        otherUsersLabel.textColor = UIColor.lightText
        otherUsersLabel.textAlignment = .center
        otherUsersLabel.font = UIFont.systemFont(ofSize: 12)
        
        unreadLabel.layer.cornerRadius = unreadLabel.frame.size.height / 2
        unreadLabel.layer.masksToBounds = true
        unreadLabel.backgroundColor = Utils.hexStringToUIColor("#CC0000")//UIColor.redColor()
        unreadLabel.textColor = UIColor.lightText
        unreadLabel.textAlignment = .center
        unreadLabel.font = UIFont.systemFont(ofSize: 12)

    }
    
    func configureWithPOD(_ pod: POD?) {
        self.pod = pod
        self.layer.cornerRadius          = 5
        if pod != nil {
            //podImageView.layer.cornerRadius  = 5
            podImageView.layer.masksToBounds = true
            podImageView.sd_setImage(with: URL(string: self.convertURL(pod!.imageURL!)), placeholderImage: UIImage(named: "PostImagePlaceholder"))
            podTitleLabel.text = pod!.name
            if let lastPostDate = pod?.lastPostDate {
                lastPostDateLabel.text = lastPostDate.formattedAsTimeAgo()
            } else {
                lastPostDateLabel.text = "No posts yet"
            }
            
            createPODView.isHidden = true
            
            addUserImages(pod!)
        } else {
            createPODView.isHidden = false
            unreadLabel.isHidden = true
            triangleView?.isHidden = true
        }
        
        self.refreshLayout()
                
    }
    
    func addUserImages(_ pod: POD) {
        
        unreadLabel.isHidden = true
        
        //let otherUsersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: userContainerLastPost.frame.size.width, height: userContainerLastPost.frame.size.height))
        self.otherUsersLabel.text = String(format: "+%li", arguments: [(pod.users?.count)!])
        //userImagesContainerView.addSubview(otherUsersLabel)
        
        if(pod.total_unread != 0)
        {
            unreadLabel.isHidden = false
            
            unreadLabel.text = String(format: "+%li", arguments: [(pod.total_unread)!])
            //userContainerLastPost.addSubview(unreadLabel)
        }
        
        if pod.isPrivate == 1 {
            if triangleView == nil {
                triangleView        = TriangleView()
                triangleView!.frame = CGRect(x: self.frame.size.width - 50, y: 0, width: 50, height: 50)
            }
            triangleView?.isHidden             = false
            triangleView!.color              = pod.podColor()
            triangleView!.backgroundColor    = UIColor.clear
            //triangleView!.layer.cornerRadius = 5
            self.addSubview(triangleView!)
            triangleView!.addImage("PrivatePODIcon")
        } else {
            if triangleView != nil {
                triangleView?.isHidden = true
            }
        }
        
    }
    
    func convertURL(_ urlString: String) -> String {
        if urlString.contains("http") {
            return urlString
        } else {
            return Constants.RESTAPIConfig.Developement.BaseUrl + urlString
        }
    }
}
