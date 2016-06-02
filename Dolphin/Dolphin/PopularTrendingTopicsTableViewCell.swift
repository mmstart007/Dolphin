//
//  PopularTrendingTopicsTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/2/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import KTCenterFlowLayout

class PopularTrendingTopicsTableViewCell : CustomFontTableViewCell {
    var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        collectionView = UICollectionView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), collectionViewLayout: layout)
        collectionView.registerNib(UINib(nibName: "TopicCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "TopicCollectionViewCell")
        self.backgroundColor = UIColor.clearColor()
        collectionView.tag        = 0
        collectionView.scrollEnabled = false
        collectionView.backgroundColor = UIColor.clearColor()
        self.addSubview(collectionView!)
        self.backgroundColor = UIColor.clearColor()

    }
    
    func configureWithDataSource(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate, centerAligned: Bool) {
        collectionView.dataSource = dataSource
        collectionView.delegate   = delegate
    }
    
    override func layoutSubviews() {
        collectionView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
}
