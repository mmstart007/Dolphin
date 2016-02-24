//
//  DealsListViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/9/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class DealsListViewController : DolphinViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var dealsCollectionView: UICollectionView!
    let networkController = NetworkController.sharedInstance
    
    required init() {
        super.init(nibName: "DealsListViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        dealsCollectionView.backgroundColor = UIColor.lightGrayBackground()
        title = "Dolphin Deals"
        dealsCollectionView.registerNib(UINib(nibName: "DealCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "DealCollectionViewCell")
        dealsCollectionView.registerNib(UINib(nibName: "DealCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "DealCollectionViewHeaderCell")
        dealsCollectionView.dataSource = self
        dealsCollectionView.delegate   = self
    }
 
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return networkController.deals.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell: DealCollectionViewCell?
        if indexPath.section == 0 {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("DealCollectionViewHeaderCell", forIndexPath: indexPath) as? DealCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("DealCollectionViewCell", forIndexPath: indexPath) as? DealCollectionViewCell
        }
        if cell == nil {
            cell = DealCollectionViewCell()
        }
        if indexPath.section == 0 {
            cell?.configureAsDealsHeader()
        } else {
            cell?.configureWithDeal(networkController.deals[indexPath.row])
        }
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: (self.view.frame.size.width) - 15, height: (self.view.frame.size.width / 2) - 15)
        } else {
            return CGSize(width: (self.view.frame.size.width / 2) - 15, height: (self.view.frame.size.width / 2) - 15)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let dealDetailsVC = DealDetailsViewController()
        dealDetailsVC.deal = networkController.deals[indexPath.row];
        navigationController?.pushViewController(dealDetailsVC, animated: true)
        
    }
    
    
}
