//
//  PostDetailsTopicsAndViewsTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/21/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PostDetailsTopicsAndViewsTableViewCell : UITableViewCell {
    
    var collectionView: UICollectionView!
    
    @IBOutlet weak var topicsView: UIView!
    @IBOutlet weak var numberOfViewsLabel: UILabel!
    @IBOutlet weak var viewLabelWidthConstraint: NSLayoutConstraint!
    var post: Post!
    
    func configureWithPost(post: Post, dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate) {
        self.post = post
        let collectionViewFlowControl = UICollectionViewFlowLayout()
        collectionViewFlowControl.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: topicsView.frame.size.width, height: topicsView.frame.size.height), collectionViewLayout: collectionViewFlowControl)
        collectionView?.registerNib(UINib(nibName: "TopicCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "TopicCollectionViewCell")
        collectionView.scrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView?.dataSource = dataSource
        collectionView?.delegate   = delegate
        collectionView?.tag        = 0
        self.addSubview(collectionView!)
        self.backgroundColor = UIColor.clearColor()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let attributedString = NSAttributedString(string: String(post.postNumberOfViews!), attributes: [NSFontAttributeName:numberOfViewsLabel.font])
        let size = attributedString.boundingRectWithSize(CGSize(width: 1000, height: 40), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        viewLabelWidthConstraint.constant = size.width
        numberOfViewsLabel.text = String(post.postNumberOfViews!)
        collectionView.frame = CGRect(x: 0, y: 0, width: topicsView.frame.size.width, height: topicsView.frame.size.height)
        self.setNeedsLayout()
        self.setNeedsUpdateConstraints()
    }
    
}