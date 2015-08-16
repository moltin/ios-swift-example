//
//  ProductListTableViewController.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 16/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit

class ProductListTableViewController: UITableViewController {
    
    private let CELL_REUSE_IDENTIFIER = "ProductListCell"
    
    private let LOAD_MORE_CELL_IDENTIFIER = "ProductsLoadMoreCell"
    
    private var products:NSMutableArray = NSMutableArray()
    
    private var paginationOffset:Int = 0
    
    private var showLoadMore:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    private func loadProducts(showLoadingAnimation: Bool){
        // Load in the next set of products...
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if showLoadMore {
            return (products.count + 1)
        }
        
        return products.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (showLoadMore && indexPath.row > (products.count - 1)) {
            // it's the last item - show a 'Load more' cell for pagination instead.
            let cell = tableView.dequeueReusableCellWithIdentifier(LOAD_MORE_CELL_IDENTIFIER, forIndexPath: indexPath) as! ProductsLoadMoreTableViewCell

            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! ProductsListTableViewCell
        
        let row = indexPath.row
        
        let product:NSDictionary = products.objectAtIndex(row) as! NSDictionary
        
        cell.configureWithProduct(product)

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Push a product detail view controller for the selected product.
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
