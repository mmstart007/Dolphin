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
        super.init(nibName: "DealsListViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        title = "Dolphin Deals"
        dealsCollectionView.register(UINib(nibName: "DealCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "DealCollectionViewCell")
        dealsCollectionView.register(UINib(nibName: "DealCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "DealCollectionViewHeaderCell")
        dealsCollectionView.dataSource = self
        dealsCollectionView.delegate   = self
    }
 
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
//            return networkController.deals.count
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: DealCollectionViewCell?
        if indexPath.section == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DealCollectionViewHeaderCell", for: indexPath) as? DealCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DealCollectionViewCell", for: indexPath) as? DealCollectionViewCell
        }
        if cell == nil {
            cell = DealCollectionViewCell()
        }
        if indexPath.section == 0 {
            cell?.configureAsDealsHeader()
        } else {
//            cell?.configureWithDeal(networkController.deals[indexPath.row])
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: (self.view.frame.size.width) - 15, height: (self.view.frame.size.width / 2) - 15)
        } else {
            return CGSize(width: (self.view.frame.size.width / 2) - 15, height: (self.view.frame.size.width / 2) - 15)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let dealDetailsVC = DealDetailsViewController()
//        dealDetailsVC.deal = networkController.deals[indexPath.row];
//        navigationController?.pushViewController(dealDetailsVC, animated: true)
    }
}
