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
        tableViewDealDetails.separatorStyle = .none
        tableViewDealDetails.estimatedRowHeight = 700
        tableViewDealDetails.rowHeight = UITableViewAutomaticDimension;
        tableViewDealDetails.backgroundColor = UIColor.lightGrayBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableViewDealDetails.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark: - Auxiliary methods
    
    func registerCells() {
        tableViewDealDetails.register(UINib(nibName: "DealDetailsHeaderTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "DealDetailsHeaderTableViewCell")
        tableViewDealDetails.register(UINib(nibName: "DealDetailsCodeSectionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "DealDetailsCodeSectionTableViewCell")        
    }
    
    // MARK: TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "DealDetailsHeaderTableViewCell") as? DealDetailsHeaderTableViewCell
            if cell == nil {
                cell = DealDetailsHeaderTableViewCell()
            }
            (cell as? DealDetailsHeaderTableViewCell)?.configureWithDeal(deal!)
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "DealDetailsCodeSectionTableViewCell") as? DealDetailsCodeSectionTableViewCell
            if cell == nil {
                cell = DealDetailsCodeSectionTableViewCell()
            }
            (cell as? DealDetailsCodeSectionTableViewCell)!.configureWithDeal(deal!)
        }
        
        cell?.selectionStyle = .none
        return cell!
    }
    
    // MARK: Tableview delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

}
