//
//  PopularTrendingTopicsTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/2/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PopularTrendingTopicsTableViewCell : UITableViewCell {
    
    var collectionView: UICollectionView!
    
    func configureWithDataSource(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate, centerAligned: Bool) {
        if !centerAligned {
            if collectionView == nil {
                let collectionViewFlowControl = UICollectionViewFlowLayout()
                collectionViewFlowControl.scrollDirection = UICollectionViewScrollDirection.Horizontal
                collectionView = UICollectionView(frame: CGRect(x: 0, y: 00, width: 0, height: 0), collectionViewLayout: collectionViewFlowControl)
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
        } else {
            if collectionView == nil {
                let layout = KTCenterFlowLayout()
                layout.minimumInteritemSpacing = 10.0
                layout.minimumLineSpacing = 10.0
                collectionView = UICollectionView(frame: CGRect(x: 0, y: 00, width: 0, height: 0), collectionViewLayout: layout)
                collectionView.registerNib(UINib(nibName: "TopicCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "TopicCollectionViewCell")
                self.backgroundColor = UIColor.clearColor()
                collectionView.dataSource = dataSource
                collectionView.delegate   = delegate
                collectionView.tag        = 0
                collectionView.collectionViewLayout = layout
                collectionView.scrollEnabled = false
                collectionView.backgroundColor = UIColor.clearColor()
                self.addSubview(collectionView!)
                self.backgroundColor = UIColor.clearColor()
            }
        }
        
        
    }
    
    override func layoutSubviews() {
        collectionView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
}
