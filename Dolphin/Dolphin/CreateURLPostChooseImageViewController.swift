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

class CreateURLPostChooseImageViewController : DolphinViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var imageURLs: [String]?
    var urlLoaded: String?
    var podId: Int?
    var mPost : Post?
    var comment : PostCommentRequest?
    
    init(images: [String]) {
        super.init(nibName: "CreateURLPostChooseImageViewController", bundle: nil)
        self.imageURLs = images
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackButton()
        title = "Pick an Image"
        photoCollectionView.register(UINib(nibName: "CreatePostChooseImageCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CreatePostChooseImageCollectionViewCell")
    }
    
    // MARK: - CollectionView Datasource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: CreatePostChooseImageCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "CreatePostChooseImageCollectionViewCell", for: indexPath) as? CreatePostChooseImageCollectionViewCell
        if cell == nil {
            cell = CreatePostChooseImageCollectionViewCell()
        }
        cell?.configureWithImageURL(imageURLs![indexPath.row])
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 10.0) / 3.0 - 10.0
        return CGSize(width: width, height: width)
    }
    
    // MARK: - CollectionView delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImageURL = imageURLs![indexPath.row]
        let addDescriptionVC = CreateURLPostAddDescriptionViewController()
        addDescriptionVC.postImageURL = selectedImageURL
        addDescriptionVC.postURL      = urlLoaded
        addDescriptionVC.podId        = podId
        addDescriptionVC.mPost = self.mPost
        self.comment?.postImageUrl = selectedImageURL
        addDescriptionVC.comment = self.comment
        navigationController?.pushViewController(addDescriptionVC, animated: true)
    }
}





