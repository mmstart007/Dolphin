//
//  CreateURLPostChooseImageViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/10/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class CreateURLPostChooseImageViewController : DolphinViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageURLs: [String]?
    
    init (images: [String]) {
        super.init()
        self.imageURLs = images
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        title = "Pick an Image"
        collectionView.registerNib(UINib(nibName: "CreatePostChooseImageCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "CreatePostChooseImageCollectionViewCell")
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: CreatePostChooseImageCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("CreatePostChooseImageCollectionViewCell", forIndexPath: indexPath) as? CreatePostChooseImageCollectionViewCell
        if cell == nil {
            cell = CreatePostChooseImageCollectionViewCell()
        }
        cell?.configureWithImageURL(imageURLs![indexPath.row])
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().bounds.width / 3.0 - 30, view.frame.size.width / 3.0 - 30)
    }
    
}
