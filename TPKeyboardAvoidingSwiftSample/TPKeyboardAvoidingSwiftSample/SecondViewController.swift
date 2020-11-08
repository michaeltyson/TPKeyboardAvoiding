//
//  SecondViewController.swift
//  TPKeyboardAvoidingSwiftSample
//
//  Created by Manuele Mion on 25/02/15.
//  Copyright (c) 2015 TPKeyboardAvoiding. All rights reserved.
//

import UIKit
import Foundation

class SecondViewController: UITableViewController {
    
    let cellIdentifier: String = "Cell"
    
    // MARK: Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            
            let textField = UITextField(frame: CGRectMake(0.0, 0.0, 150.0, 30.0))
            textField.borderStyle = .RoundedRect
            
            cell!.accessoryView = textField
            cell!.selectionStyle = .None
        }
        
        cell!.textLabel?.text = String(format: "Order %d", arguments: [indexPath.row])
        let textField = cell!.accessoryView as UITextField
        textField.placeholder = String(format: "%d bananas", arguments: [indexPath.row])
        
        return cell!
    }
    
}
