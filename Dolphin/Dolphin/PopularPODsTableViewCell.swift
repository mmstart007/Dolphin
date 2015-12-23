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
    
    @IBOutlet weak var podsCollectionView: UICollectionView!
    
    func configureWithDataSource(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate) {
        podsCollectionView.registerNib(UINib(nibName: "PODCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "PODCollectionViewCell")
        podsCollectionView.tag = 1
        self.backgroundColor = UIColor.clearColor()
        podsCollectionView.dataSource = dataSource
        podsCollectionView.delegate   = delegate
    }
    
}