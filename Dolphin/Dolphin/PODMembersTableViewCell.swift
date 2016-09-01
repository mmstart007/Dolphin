//
//  PODMembersTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/16/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

@objc protocol PODMembersTableViewCellDelegate {
    optional func tapAddMember()
}

class PODMembersTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewMembers: UICollectionView!
    @IBOutlet weak var emptyLable: UILabel!
    
    var members: [User] = []
    var delegate: PODMembersTableViewCellDelegate?
    let cols = 5
    
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
        
        registerCells()
        if pod.users != nil {
            members = pod.users!
        }
        
        emptyLable.hidden = true
        if members.count == 0 {
            emptyLable.hidden = false
        }
        collectionViewMembers.reloadData()
    }
    
    func didTapAdd() {
        self.delegate?.tapAddMember!()
    }
    
    func registerCells() {
        collectionViewMembers.registerNib(UINib(nibName: "UserImagePODMemberCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "UserImagePODMemberCollectionViewCell")
    
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (members.count > cols) {
            return cols;
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
        if (members.count > cols && indexPath.row == cols - 1) {
            cell?.configureAsMoreUsers(members.count - cols + 1)
        }
        else {
            cell?.configureAsUser(members[indexPath.row].userAvatarImageURL!)
        }
        
        return cell!
    }
    
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let offset = 2;
        let width = (collectionView.frame.width - CGFloat(offset * (cols - 1))) / CGFloat(cols)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 0, 0, 0);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    


    
}
