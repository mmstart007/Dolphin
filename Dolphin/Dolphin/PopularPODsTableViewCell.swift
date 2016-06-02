//
//  PopularPODsTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/2/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PopularPODsTableViewCell : CustomFontTableViewCell {
    
    var podsCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let collectionViewFlowControl = UICollectionViewFlowLayout()
        podsCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: collectionViewFlowControl)
        podsCollectionView.registerNib(UINib(nibName: "PODCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "PODCollectionViewCell")
        podsCollectionView.tag = 1
        podsCollectionView.scrollEnabled = false
        podsCollectionView.backgroundColor = UIColor.clearColor()
        
        self.addSubview(podsCollectionView)
        self.backgroundColor = UIColor.clearColor()
    }
    
    func configureWithDataSource(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate) {
        podsCollectionView.dataSource = dataSource
        podsCollectionView.delegate   = delegate
    }
    
    override func layoutSubviews() {
        podsCollectionView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
}