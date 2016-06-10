//
//  CreateImagePostViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/14/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import Photos

class CreateImagePostViewController : DolphinViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var tapToChooseImageLabel: UILabel?
    
    var chosenImage: UIImage? = nil
    var images: [UIImage]! = []
    // if this var is set, I'm creating a text post from a POD
    var podId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerNib(UINib(nibName: "CreatePostChooseImageCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "CreatePostChooseImageCollectionViewCell")
        title = "New Post"
        navigationItem.rightBarButtonItem?.enabled = false
        self.edgesForExtendedLayout = .None
        setBackButton()
        fetchPhotos()
    }
    
    // Fetch Images from Camera Roll
    
    func fetchPhotos () {
        
        let imgManager = PHImageManager.defaultManager()
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        // Sort the images by creation date
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
            
            for (var i = 0; i < fetchResult.count; i++) {
                
                autoreleasepool {
                    
                    let asset = fetchResult.objectAtIndex(i)
                    // Perform the image request
                    let options = PHImageRequestOptions()
                    options.resizeMode = .Fast
                    options.synchronous = true
                    
                    let width = (UIScreen.mainScreen().bounds.width - 10.0) / 3.0 - 10.0
                    imgManager.requestImageForAsset(asset as! PHAsset, targetSize: CGSizeMake(width, width), contentMode: PHImageContentMode.AspectFit, options: requestOptions, resultHandler: { (image, _) in
                        
                        // Add the returned image to your array
                        self.images.append(image!)
                    })
                }
            }
        }
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images!.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: CreatePostChooseImageCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("CreatePostChooseImageCollectionViewCell", forIndexPath: indexPath) as? CreatePostChooseImageCollectionViewCell
        if cell == nil {
            cell = CreatePostChooseImageCollectionViewCell()
        }
        if indexPath.row == 0 {
            cell?.configureWithImage(UIImage(named: "CameratakePictureImage")!)
        } else {
            cell?.configureWithImage(images![indexPath.row - 1])
        }
        return cell!
    }
    

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (UIScreen.mainScreen().bounds.width - 10.0) / 3.0 - 10.0
        return CGSizeMake(width, width)
    }
    
    // MARK: CollectionView Delegate
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            
            if indexPath.row == 0 {
                if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                    let finishImagePostVC = CreateImagePostFinishPostingViewController(image: nil)
                    self.navigationController?.pushViewController(finishImagePostVC, animated: true)
                }
            } else {
                let imgManager = PHImageManager.defaultManager()
                
                // Note that if the request is not set to synchronous
                // the requestImageForAsset will return both the image
                // and thumbnail; by setting synchronous to true it
                // will return just the thumbnail
                let requestOptions = PHImageRequestOptions()
                requestOptions.synchronous = true
                
                // Sort the images by creation date
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                
                if let fetchResult: PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
                    
                    let options = PHImageRequestOptions()
                    options.resizeMode = .None
                    options.synchronous = true
                    imgManager.requestImageDataForAsset(fetchResult.objectAtIndex(indexPath.row - 1) as! PHAsset, options: options, resultHandler: { (data, dataUTI, orientation, info) -> Void in
                        let image = UIImage(data: data!)!
                        let finishImagePostVC = CreateImagePostFinishPostingViewController(image: image)
                        finishImagePostVC.podId = self.podId
                        self.navigationController?.pushViewController(finishImagePostVC, animated: true)
                    })
                }
            }
    }
    
}