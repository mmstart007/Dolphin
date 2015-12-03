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
    
    
    @IBOutlet weak var trendingTopicsCollectionView: UICollectionView!
    
    func configureWithDataSource(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate) {
        trendingTopicsCollectionView.registerNib(UINib(nibName: "TopicCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "TopicCollectionViewCell")
        let layout = KTCenterFlowLayout()
        
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        trendingTopicsCollectionView.collectionViewLayout = layout
        
        self.backgroundColor = UIColor.clearColor()
        trendingTopicsCollectionView.dataSource = dataSource
        trendingTopicsCollectionView.delegate   = delegate
        trendingTopicsCollectionView.tag        = 0
    }
    
}
