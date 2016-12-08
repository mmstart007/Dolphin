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
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "TopicCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TopicCollectionViewCell")
        self.backgroundColor = UIColor.clear
        collectionView.tag        = 0
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor.clear
        self.addSubview(collectionView!)
        self.backgroundColor = UIColor.clear

    }
    
    func configureWithDataSource(_ dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate, centerAligned: Bool) {
        collectionView.dataSource = dataSource
        collectionView.delegate   = delegate
    }
    
    override func layoutSubviews() {
        collectionView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
}
