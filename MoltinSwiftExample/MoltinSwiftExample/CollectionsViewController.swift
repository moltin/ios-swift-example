//
//  CollectionsViewController.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 15/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin

class CollectionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:UITableView?
    
    fileprivate var collections:NSArray?
    
    fileprivate let COLLECTION_CELL_REUSE_IDENTIFIER = "CollectionCell"
    
    fileprivate let PRODUCTS_LIST_SEGUE_IDENTIFIER = "productsListSegue"
    
    fileprivate var selectedCollectionDict:NSDictionary?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Collections"
        
        // Show loading UI
        SwiftSpinner.show("Loading Collections")
        
        // Get collections, async
        Moltin.sharedInstance().collection.listing(withParameters: ["status": NSNumber(value: 1), "limit": NSNumber(value: 20)], success: { (response) -> Void in
            // We have collections - show them!
            SwiftSpinner.hide()
            
            self.collections = response?["result"] as? NSArray
            
            self.tableView?.reloadData()
            
        }) { (response, error) -> Void in
            // Something went wrong; hide loading UI and display warning.
            SwiftSpinner.hide()

            AlertDialog.showAlert("Error", message: "Couldn't load collections", viewController: self)
            print("Something went wrong...")
            print(error)
        }
        
        
    }
    
    
    // MARK: - TableView Data source & Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collections != nil {
            return collections!.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: COLLECTION_CELL_REUSE_IDENTIFIER, for: indexPath) as! CollectionTableViewCell
        
        let row = (indexPath as NSIndexPath).row
        
        let collectionDictionary = collections?.object(at: row) as! NSDictionary
        
        cell.setCollectionDictionary(collectionDictionary)
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedCollectionDict = collections?.object(at: (indexPath as NSIndexPath).row) as? NSDictionary

        performSegue(withIdentifier: PRODUCTS_LIST_SEGUE_IDENTIFIER, sender: self)

        
    }
    
    func tableView(_ _tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
            
            if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
                cell.separatorInset = UIEdgeInsets.zero
            }
            if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
                cell.layoutMargins = UIEdgeInsets.zero
            }
            if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
                cell.preservesSuperviewLayoutMargins = false
            }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == PRODUCTS_LIST_SEGUE_IDENTIFIER {
            // Set up products list view!
            let newViewController = segue.destination as! ProductListTableViewController
            
            newViewController.title = selectedCollectionDict!.value(forKey: "title") as? String
            newViewController.collectionId = selectedCollectionDict!.value(forKeyPath: "id") as? String
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

