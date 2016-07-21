//
//  searchViewController.swift
//  TwitterDisplay
//
//  Created by Marcus Hughes on 5/16/16.
//  Copyright © 2016 Marcus Hughes. All rights reserved.
//

import UIKit
import Accounts
import Social
import CoreData



enum UYLTwitterSearchState {
    case UYLTwitterSearchStateLoading
    case UYLTwitterSearchStateNotFound
    case UYLTwitterSearchStateRefused
    case UYLTwitterSearchStateFailed
    case UYLTwitterSearchStateComplete
    
}

class searchViewController: UITableViewController {
    
    
    // MARK: Vars initialization
    var searchTerm = ""
    var count = ""
    var type = ""
    
    // Twitter search vars

   
  
 
    var account : ACAccount?
    let accountStore = ACAccountStore()
    var searchState:UYLTwitterSearchState!
    var connection:NSURLConnection!
    var buffer:NSMutableData!
    var results:NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadQuery()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // Transfer saved tweets into core data stack
       
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view handler funcs
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Set numberOfRows for count of results
        
        if(self.results != nil){
            // Check of tweet search has concluded
            
            var count:Int? = self.results.count
            
            if(count < 1){
                // Ensure atleast 1 row
                count = 1
            }
            return count!
            
        }
        else{
            return 1
        }
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
              let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath:indexPath) as! TableViewCell
        var count:Int
       
        if(self.results != nil){
            // Handle case where query is incomplete
            count = self.results.count
        }
        else{
            count = 0;
        }
        
        if(count == 0 && indexPath.row == 0){
            // Query has not completed yet, display loading for user
            cell.textL.text  = "Loading"
            return cell
        }
             //cell.textV?.text = "lol"
        
        // Query is complete, process all found tweets from search
        let tweet:NSDictionary = self.results[indexPath.row] as! NSDictionary
     
        cell.textL?.text = tweet["text"] as? String
        cell.nameT?.text = tweet["user"]?.valueForKey("name") as? String
       // cell.textLabel?.text = tweet["user"]?.valueForKey("location") as? String
       
            //Parse through JSON data for profile pic and display
     let imageURL:NSURL? = NSURL(string: tweet["user"]?.valueForKey("profile_image_url") as! String)
    
       let data:NSData? = NSData(contentsOfURL: imageURL!)
       let image:UIImage? = UIImage(data: data!)
      cell.imageL?.image = image
        
     
        
        return cell
    }
    
    
    
    // MARK: Twitter search handler funcs
    
    func loadQuery(){
        // Initialize search state
        searchState = UYLTwitterSearchState.UYLTwitterSearchStateLoading
        
        //let encodedSearch = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        // Prompt the user for permission to their twitter account stored in the phone's settings
        self.accountStore.requestAccessToAccountsWithType(accountType, options: nil) {
            granted, error in
            if granted {
                // Load user twitter account
                let twitterAccounts = self.accountStore.accountsWithAccountType(accountType)
                
                if twitterAccounts?.count == 0
                {
                    // Twitter is not logged in
                    self.searchState = UYLTwitterSearchState.UYLTwitterSearchStateNotFound
                    print("User not logged into twitter")
                }
                else {
                    // User is logged into twitter on device
                    let twitterAccount = twitterAccounts[0] as! ACAccount
                    
                    // Load twitter search url
                    let url = "https://api.twitter.com/1.1/search/tweets.json"
                    // Define parameters for search as defined by twitter API
                    let param = [
                        "q": self.searchTerm,
                        "result_type": self.type,
                        "count": self.count
                    ]
                    
                    // Load request
                    let slRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: NSURL(string: url), parameters: param)
                    // Load twitter account into request
                    slRequest.account = twitterAccount
                    
                    // Prepare request for connection
                    let request = slRequest .preparedURLRequest()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        // Define connection and initalize
                        self.connection = NSURLConnection(request: request, delegate: self)
                        [UIApplication .sharedApplication().networkActivityIndicatorVisible = true]
                    });
                    
                    
                }
                
            }
            else {
                self.searchState = UYLTwitterSearchState.UYLTwitterSearchStateRefused
                print("Access denied by user")
                
            }
        }
        
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        // Connection successful and response is recieved!
        self.buffer = NSMutableData()
        
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        // Transfer data into local buffer array
        self.buffer .appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        
        // Tweet search completed. Load JSON results
        var jsonError: NSError?
        let jsonResults = (try! NSJSONSerialization.JSONObjectWithData(self.buffer, options: [])) as! NSDictionary
        
        
        
        // Save statuses for table use
        self.results = jsonResults["statuses"] as! NSMutableArray
        if(self.results.count == 0){
            print("No results found")
        }
        
        // Reload table data
        self.tableView .reloadData()
        self.tableView .flashScrollIndicators()
        
        // Reset connection vars
        self.searchState = UYLTwitterSearchState.UYLTwitterSearchStateComplete
        self.connection = nil
        
        
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        // Search failed
        self.searchState = UYLTwitterSearchState.UYLTwitterSearchStateFailed
    }
    
    
    
    
}
    

