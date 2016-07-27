//
//  OtherProfileViewController.swift
//  Dolphin
//
//  Created by star on 7/27/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class OtherProfileViewController: DolphinViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var postCollectionView: UICollectionView!
    
    var selectedUser: User!
    
    let networkController = NetworkController.sharedInstance
    let kPageQuantity: Int = 15
    var allPosts: [Post] = []
    var isDataLoaded: Bool = false
    var page: Int = 0

    init(userInfo: User!) {
        self.selectedUser = userInfo
        super.init(nibName: "OtherProfileViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackButton()
        
        postCollectionView!.registerNib(UINib(nibName: "GridPostCell", bundle: nil), forCellWithReuseIdentifier: "GridPostCell")
        postCollectionView.registerNib(UINib(nibName: "UserInfoReusableView", bundle: nil), forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "UserInfoReusableView")
        
        postCollectionView.addPullToRefreshWithActionHandler { () -> Void in
            self.loadData(true)
        }
        
        postCollectionView.addInfiniteScrollingWithActionHandler { () -> Void in
            self.loadNextPosts()
        }
        
        loadData(false)
    }
    
    func loadData(pullToRefresh: Bool) {
        page = 0
        if !pullToRefresh {
            SVProgressHUD.showWithStatus("Loading")
        }
        
        networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId: selectedUser.id, quantity: kPageQuantity, page: 0, podId: nil, filterByUserInterests: false, sort_by: nil, completionHandler: { (posts, error) -> () in
            if error == nil {
                self.isDataLoaded = true
                self.allPosts = posts
                if self.allPosts.count > 0 {
                    //                    self.removeTableEmtpyMessage()
                } else {
                    //                    self.addTableEmptyMessage("No content has been posted\n\nwhy don't post someting?")
                }
                self.postCollectionView.reloadData()
                
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
                //self.deletePost(4)
                
            } else {
                self.isDataLoaded = false
                let errors: [String]? = error!["errors"] as? [String]
                let alert: UIAlertController
                if errors != nil && errors![0] != "" {
                    alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .Alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
            }
            self.postCollectionView.pullToRefreshView.stopAnimating()
        })
    }
    
    func loadNextPosts() {
        page = page + 1
        networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId: selectedUser.id, quantity: kPageQuantity, page: page, podId: nil, filterByUserInterests: false, sort_by: nil, completionHandler: { (posts, error) -> () in
            if error == nil {
                self.allPosts.appendContentsOf(posts)
                self.postCollectionView.reloadData()
                
                
            } else {
                let errors: [String]? = error!["errors"] as? [String]
                let alert: UIAlertController
                if errors != nil && errors![0] != "" {
                    alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .Alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.postCollectionView.infiniteScrollingView.stopAnimating()
        })
    }
    
    // MARK: CollectionView Datasource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPosts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: GridPostCell? = collectionView.dequeueReusableCellWithReuseIdentifier("GridPostCell", forIndexPath: indexPath) as? GridPostCell
        if cell == nil {
            cell = GridPostCell()
        }
        cell?.configurePost(allPosts[indexPath.row])
        return cell!
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,atIndexPath indexPath: NSIndexPath) ->UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                                                                                   withReuseIdentifier:"UserInfoReusableView", forIndexPath: indexPath) as! UserInfoReusableView
            
            headerView.nameLabel.text = selectedUser.userName
            headerView.usernameLabel.text = selectedUser.userEmail
            if let userImageUrl = selectedUser?.userAvatarImageURL {
                headerView.avatarImageView.sd_setImageWithURL(NSURL(string: (userImageUrl)), placeholderImage: UIImage(named: "UserPlaceholder"))
            } else {
                headerView.avatarImageView.image = UIImage(named: "PostImagePlaceholder")
            }
            
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.frame.width, 190.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10.0) / 3.0 - 10.0
        return CGSizeMake(width, width)
    }
    
    // MARK: CollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let postDetailsVC = PostDetailsViewController()
        postDetailsVC.post = allPosts[indexPath.row]
        navigationController?.pushViewController(postDetailsVC, animated: true)
    }

}
