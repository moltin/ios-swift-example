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
    
    fileprivate let CELL_REUSE_IDENTIFIER = "ProductCell"
    
    fileprivate let LOAD_MORE_CELL_IDENTIFIER = "ProductsLoadMoreCell"
    
    fileprivate let PRODUCT_DETAIL_VIEW_SEGUE_IDENTIFIER = "productDetailSegue"
    
    fileprivate var products:NSMutableArray = NSMutableArray()
    
    fileprivate var paginationOffset:Int = 0
    
    fileprivate var showLoadMore:Bool = true
    
    fileprivate let PAGINATION_LIMIT:Int = 3
    
    fileprivate var selectedProductDict:NSDictionary?
    
    var collectionId:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadProducts(true)
        
    }
    
    fileprivate func loadProducts(_ showLoadingAnimation: Bool){
        assert(collectionId != nil, "Collection ID is required!")
        
        // Load in the next set of products...
        
        // Show loading if neccesary?
        if showLoadingAnimation {
            SwiftSpinner.show("Loading products")
        }
        
        
        Moltin.sharedInstance().product.listing(withParameters: ["collection": collectionId!, "limit": NSNumber(value: PAGINATION_LIMIT), "offset": paginationOffset], success: { (response) -> Void in
            // Let's use this response!
            SwiftSpinner.hide()
            
            
            if let newProducts:NSArray = response?["result"] as? NSArray {
                self.products.addObjects(from: newProducts as [AnyObject])
                
            }
            
            
            let responseDictionary = NSDictionary(dictionary: response!)
            
            if let newOffset:NSNumber = responseDictionary.value(forKeyPath: "pagination.offsets.next") as? NSNumber {
                self.paginationOffset = newOffset.intValue
                
            }
            
            if let totalProducts:NSNumber = responseDictionary.value(forKeyPath: "pagination.total") as? NSNumber {
                // If we have all the products already, don't show the 'load more' button!
                if totalProducts.intValue >= self.products.count {
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if showLoadMore {
            return (products.count + 1)
        }
        
        return products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (showLoadMore && (indexPath as NSIndexPath).row > (products.count - 1)) {
            // it's the last item - show a 'Load more' cell for pagination instead.
            let cell = tableView.dequeueReusableCell(withIdentifier: LOAD_MORE_CELL_IDENTIFIER, for: indexPath) as! ProductsLoadMoreTableViewCell

            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_REUSE_IDENTIFIER, for: indexPath) as! ProductsListTableViewCell
        
        let row = (indexPath as NSIndexPath).row
        
        let product:NSDictionary = products.object(at: row) as! NSDictionary
        
        cell.configureWithProduct(product)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (showLoadMore && (indexPath as NSIndexPath).row > (products.count - 1)) {
            // Load more products!
            loadProducts(false)
            return
        }
        
        
        // Push a product detail view controller for the selected product.
        let product:NSDictionary = products.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        selectedProductDict = product
        
        performSegue(withIdentifier: PRODUCT_DETAIL_VIEW_SEGUE_IDENTIFIER, sender: self)
        
    }
    
    override func tableView(_ _tableView: UITableView,
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
        
        if segue.identifier == PRODUCT_DETAIL_VIEW_SEGUE_IDENTIFIER {
            // Set up product detail view
            let newViewController = segue.destination as! ProductDetailViewController
            
            newViewController.title = selectedProductDict!.value(forKey: "title") as? String
            newViewController.productDict = selectedProductDict
            
        }
    }

    
}
