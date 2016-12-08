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
    @objc optional func tapTopic(_ topic: Topic?)
    @objc optional func likeButtonPressed()
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
        collectionView?.register(UINib(nibName: "TopicCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TopicCollectionViewCell")
        let layout = LeftAlignCollectionViewLayout()
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 4;
        collectionView.collectionViewLayout = layout

        likedImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PostDetailsTopicsAndViewsTableViewCellDelegate.likeButtonPressed)))
        likedImageView.isUserInteractionEnabled = true

        self.backgroundColor = UIColor.clear
    }
    
    func likeButtonPressed() {
        self.delegate?.likeButtonPressed!()
    }
    
    func configureWithPost(_ post: Post) {
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (post?.postTopics!.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: TopicCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "TopicCollectionViewCell", for: indexPath) as? TopicCollectionViewCell
        if cell == nil {
            cell = TopicCollectionViewCell()
        }
        cell?.configureWithName((post?.postTopics![indexPath.row].name!.uppercased())!, color: UIColor.topicsColorsArray()[indexPath.row % UIColor.topicsColorsArray().count])
        collectionView.isUserInteractionEnabled = true
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let text = post?.postTopics![indexPath.row].name!.uppercased()
        let font = UIFont.systemFont(ofSize: 16)
        let textString = text! as NSString
        
        let textAttributes = [NSFontAttributeName: font]
        var size = textString.boundingRect(with: CGSize(width: topicsView.frame.size.width - 20, height: 35), options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil).size
        if size.width < topicsView.frame.size.width / 4 {
            size = CGSize(width: topicsView.frame.size.width / 4, height: size.height)
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let topic = post?.postTopics![indexPath.row]
        self.delegate?.tapTopic!(topic)
    }

}
