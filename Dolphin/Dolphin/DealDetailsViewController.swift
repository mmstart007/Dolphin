//
//  DealDetailsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/17/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class DealDetailsViewController: DolphinViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableViewDealDetails: UITableView!
    
    var deal: Deal?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackButton()
        title = "Dolphin Deal"
        registerCells()
        
        tableViewDealDetails.delegate = self
        tableViewDealDetails.dataSource = self
        tableViewDealDetails.separatorStyle = .None
        tableViewDealDetails.estimatedRowHeight = 700
        tableViewDealDetails.rowHeight = UITableViewAutomaticDimension;
        tableViewDealDetails.backgroundColor = UIColor.lightGrayBackground()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableViewDealDetails.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark: - Auxiliary methods
    
    func registerCells() {
        tableViewDealDetails.registerNib(UINib(nibName: "DealDetailsHeaderTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "DealDetailsHeaderTableViewCell")
        tableViewDealDetails.registerNib(UINib(nibName: "DealDetailsCodeSectionTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "DealDetailsCodeSectionTableViewCell")        
    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("DealDetailsHeaderTableViewCell") as? DealDetailsHeaderTableViewCell
            if cell == nil {
                cell = DealDetailsHeaderTableViewCell()
            }
            (cell as? DealDetailsHeaderTableViewCell)?.configureWithDeal(deal!)
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("DealDetailsCodeSectionTableViewCell") as? DealDetailsCodeSectionTableViewCell
            if cell == nil {
                cell = DealDetailsCodeSectionTableViewCell()
            }
            (cell as? DealDetailsCodeSectionTableViewCell)!.configureWithDeal(deal!)
        }
        
        cell?.selectionStyle = .None
        return cell!
    }
    
    // MARK: Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    

}
