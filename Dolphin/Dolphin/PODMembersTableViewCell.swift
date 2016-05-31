//
//  PODMembersTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/16/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class PODMembersTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    
    @IBOutlet weak var imageViewAdd: UIImageView!
    @IBOutlet weak var collectionViewMembers: UICollectionView!
    var members: [User] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithPOD(pod: POD) {
        
        collectionViewMembers.delegate = self
        collectionViewMembers.dataSource = self
        collectionViewMembers.backgroundColor = UIColor.lightGrayBackground()
        var scalingTransform : CGAffineTransform!
        scalingTransform = CGAffineTransformMakeScale(-1, 1);
        collectionViewMembers.transform = scalingTransform
        imageViewAdd.backgroundColor = UIColor.whiteColor()
        imageViewAdd.layer.cornerRadius = imageViewAdd.frame.size.width / 2
        registerCells()
        members = pod.users!
        collectionViewMembers.reloadData()
        
    }
    
    func registerCells() {
        collectionViewMembers.registerNib(UINib(nibName: "UserImagePODMemberCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "UserImagePODMemberCollectionViewCell")
    
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (members.count > 4) {
            return 4;
        }
        else {
            return members.count;
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserImagePODMemberCollectionViewCell", forIndexPath: indexPath) as? UserImagePODMemberCollectionViewCell
        if cell == nil {
            cell = UserImagePODMemberCollectionViewCell()
        }
        if (members.count > 4 && indexPath.row == 0) {
            cell?.configureAsMoreUsers(members.count - 3)
        }
        else {
            cell?.configureAsUser(members[members.count - 1 - indexPath.row].userAvatarImageURL!)
        }
        var scalingTransform : CGAffineTransform!
        scalingTransform = CGAffineTransformMakeScale(-1, 1);
        cell?.transform = scalingTransform
        
        return cell!
    }
    
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 54, height: 54)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 0, 0, 0);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    


    
}
