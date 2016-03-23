//
//  CreateURLPostChooseImageViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/10/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class CreateURLPostChooseImageViewController : DolphinViewController, UICollectionViewDataSource {
    
    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageURLs: [String]?
    var urlLoaded: String?
    
    init(images: [String]) {
        super.init(nibName: "CreateURLPostChooseImageViewController", bundle: nil)
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
    
    // MARK: - CollectionView Datasource
    
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
    
    // MARK: - CollectionView delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedImageURL = imageURLs![indexPath.row]
        let link = Link(url: urlLoaded!, imageURL: selectedImageURL)
        // crate the pod
        let post = Post(user: nil, image: nil, imageData: nil, type: PostType(name: "link"), topics: nil, link: link, imageUrl: nil, title: nil, text: nil, date: nil, numberOfLikes: nil, numberOfComments: nil, comments: nil)
        SVProgressHUD.showWithStatus("Posting")
        networkController.createPost(post, completionHandler: { (post, error) -> () in
            if error == nil {
                
                if post?.postId != nil {
                    // everything worked ok
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    // there was an error saving the post
                }
                SVProgressHUD.dismiss()
                
            } else {
                SVProgressHUD.dismiss()
                let errors: [String]? = error!["errors"] as? [String]
                var alert: UIAlertController
                if errors != nil && errors![0] != "" {
                    alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .Alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .Alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        
    }

    
}
