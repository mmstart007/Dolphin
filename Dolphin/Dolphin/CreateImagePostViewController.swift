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
        
        collectionView.register(UINib(nibName: "CreatePostChooseImageCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CreatePostChooseImageCollectionViewCell")
        title = "New Post"
        navigationItem.rightBarButtonItem?.isEnabled = false
        self.edgesForExtendedLayout = UIRectEdge()
        setBackButton()
        fetchPhotos()
    }
    
    // Fetch Images from Camera Roll
    
    func fetchPhotos () {
        
        let imgManager = PHImageManager.default()
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        // Sort the images by creation date
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions) {
            
            for i in (0..<fetchResult.count) {
                
                autoreleasepool {
                    
                    let asset = fetchResult.object(at: i)
                    // Perform the image request
                    let options = PHImageRequestOptions()
                    options.resizeMode = .fast
                    options.isSynchronous = true
                    
                    let width = (UIScreen.main.bounds.width - 10.0) / 3.0 - 10.0
                    imgManager.requestImage(for: asset , targetSize: CGSize(width: width, height: width), contentMode: PHImageContentMode.aspectFit, options: requestOptions, resultHandler: { (image, _) in
                        
                        // Add the returned image to your array
                        self.images.append(image!)
                    })
                }
            }
        }
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images!.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: CreatePostChooseImageCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "CreatePostChooseImageCollectionViewCell", for: indexPath) as? CreatePostChooseImageCollectionViewCell
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
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 10.0) / 3.0 - 10.0
        return CGSize(width: width, height: width)
    }
    
    // MARK: CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
            
            if indexPath.row == 0 {
                if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
                    let finishImagePostVC = CreateImagePostFinishPostingViewController(image: nil)
                    self.navigationController?.pushViewController(finishImagePostVC, animated: true)
                }
            } else {
                let imgManager = PHImageManager.default()
                
                // Note that if the request is not set to synchronous
                // the requestImageForAsset will return both the image
                // and thumbnail; by setting synchronous to true it
                // will return just the thumbnail
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                
                // Sort the images by creation date
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                
                if let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions) {
                    
                    let options = PHImageRequestOptions()
                    options.resizeMode = .none
                    options.isSynchronous = true
                    imgManager.requestImageData(for: fetchResult.object(at: indexPath.row - 1) , options: options, resultHandler: { (data, dataUTI, orientation, info) -> Void in
                        let image = UIImage(data: data!)!
                        let finishImagePostVC = CreateImagePostFinishPostingViewController(image: image)
                        finishImagePostVC.podId = self.podId
                        self.navigationController?.pushViewController(finishImagePostVC, animated: true)
                    })
                }
            }
    }
    
}
