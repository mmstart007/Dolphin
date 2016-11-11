//
//  PostDetailsTopicsAndViewsTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/21/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PostDetailsTopicsAndViewsTableViewCellDelegate {
    optional func tapTopic(topic: Topic?)
    optional func likeButtonPressed()
}

class PostDetailsTopicsAndViewsTableViewCell : CustomFontTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var delegate: PostDetailsTopicsAndViewsTableViewCellDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var likedImageView: UIImageView!
    @IBOutlet weak var topicsView: UIView!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var verticalLayoutConstraint: NSLayoutConstraint!
    var post: Post!
    
    override func awakeFromNib() {
         super.awakeFromNib()
        collectionView?.registerNib(UINib(nibName: "TopicCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "TopicCollectionViewCell")
        let layout = LeftAlignCollectionViewLayout()
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 4;
        collectionView.collectionViewLayout = layout

        likedImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PostDetailsTopicsAndViewsTableViewCellDelegate.likeButtonPressed)))
        likedImageView.userInteractionEnabled = true

        self.backgroundColor = UIColor.clearColor()
    }
    
    func likeButtonPressed() {
        self.delegate?.likeButtonPressed!()
    }
    
    func configureWithPost(post: Post) {
        self.post = post
        numberOfLikesLabel.text = "0"
        if (post.postNumberOfLikes != nil) {
            numberOfLikesLabel.text = String(post.postNumberOfLikes!)
        }
        
        if post.isLikedByUser {
            likedImageView.image = UIImage(named: "ViewsGlassIcon")
        } else {
            likedImageView.image = UIImage(named: "SunglassesIconNotLiked")
        }
        
        collectionView.reloadData()
        verticalLayoutConstraint.constant = collectionView.contentSize.height;
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (post?.postTopics!.count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: TopicCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("TopicCollectionViewCell", forIndexPath: indexPath) as? TopicCollectionViewCell
        if cell == nil {
            cell = TopicCollectionViewCell()
        }
        cell?.configureWithName((post?.postTopics![indexPath.row].name!.uppercaseString)!, color: UIColor.topicsColorsArray()[indexPath.row % UIColor.topicsColorsArray().count])
        collectionView.userInteractionEnabled = true
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let text = post?.postTopics![indexPath.row].name!.uppercaseString
        let font = UIFont.systemFontOfSize(16)
        let textString = text! as NSString
        
        let textAttributes = [NSFontAttributeName: font]
        var size = textString.boundingRectWithSize(CGSizeMake(topicsView.frame.size.width - 20, 35), options: .UsesLineFragmentOrigin, attributes: textAttributes, context: nil).size
        if size.width < topicsView.frame.size.width / 4 {
            size = CGSize(width: topicsView.frame.size.width / 4, height: size.height)
        }
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let topic = post?.postTopics![indexPath.row]
        self.delegate?.tapTopic!(topic)
    }

}