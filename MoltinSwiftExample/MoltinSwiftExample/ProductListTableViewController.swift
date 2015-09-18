//
//  ProductListTableViewController.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 16/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin
import SwiftSpinner

class ProductListTableViewController: UITableViewController {
    
    private let CELL_REUSE_IDENTIFIER = "ProductCell"
    
    private let LOAD_MORE_CELL_IDENTIFIER = "ProductsLoadMoreCell"
    
    private let PRODUCT_DETAIL_VIEW_SEGUE_IDENTIFIER = "productDetailSegue"
    
    private var products:NSMutableArray = NSMutableArray()
    
    private var paginationOffset:Int = 0
    
    private var showLoadMore:Bool = true
    
    private let PAGINATION_LIMIT:Int = 3
    
    private var selectedProductDict:NSDictionary?
    
    var collectionId:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadProducts(true)
        
    }
    
    private func loadProducts(showLoadingAnimation: Bool){
        assert(collectionId != nil, "Collection ID is required!")
        
        // Load in the next set of products...
        
        // Show loading if neccesary?
        if showLoadingAnimation {
            SwiftSpinner.show("Loading products")
        }
        
        
        Moltin.sharedInstance().product.listingWithParameters(["collection": collectionId!, "limit": NSNumber(integer: PAGINATION_LIMIT), "offset": paginationOffset], success: { (response) -> Void in
            // Let's use this response!
            SwiftSpinner.hide()
            
            
            if let newProducts:NSArray = response["result"] as? NSArray {
                self.products.addObjectsFromArray(newProducts as [AnyObject])
                
            }
            
            
            let responseDictionary = response as NSDictionary
            
            if let newOffset:NSNumber = responseDictionary.valueForKeyPath("pagination.offsets.next") as? NSNumber {
                self.paginationOffset = newOffset.integerValue
                
            }
            
            if let totalProducts:NSNumber = responseDictionary.valueForKeyPath("pagination.total") as? NSNumber {
                // If we have all the products already, don't show the 'load more' button!
                if totalProducts.integerValue >= self.products.count {
                    self.showLoadMore = false
                }
                
            }
            
            self.tableView.reloadData()
            
        }) { (response, error) -> Void in
            // Something went wrong!
            SwiftSpinner.hide()
            
            AlertDialog.showAlert("Error", message: "Couldn't load products", viewController: self)

            print("Something went wrong...")
            print(error)
        }
        
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (showLoadMore && indexPath.row > (products.count - 1)) {
            // Load more products!
            loadProducts(false)
            return
        }
        
        
        // Push a product detail view controller for the selected product.
        let product:NSDictionary = products.objectAtIndex(indexPath.row) as! NSDictionary
        selectedProductDict = product
        
        performSegueWithIdentifier(PRODUCT_DETAIL_VIEW_SEGUE_IDENTIFIER, sender: self)
        
    }
    
    override func tableView(_tableView: UITableView,
        willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            if cell.respondsToSelector("setSeparatorInset:") {
                cell.separatorInset = UIEdgeInsetsZero
            }
            if cell.respondsToSelector("setLayoutMargins:") {
                cell.layoutMargins = UIEdgeInsetsZero
            }
            if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
                cell.preservesSuperviewLayoutMargins = false
            }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == PRODUCT_DETAIL_VIEW_SEGUE_IDENTIFIER {
            // Set up product detail view
            let newViewController = segue.destinationViewController as! ProductDetailViewController
            
            newViewController.title = selectedProductDict!.valueForKey("title") as? String
            newViewController.productDict = selectedProductDict
            
        }
    }

    
}
