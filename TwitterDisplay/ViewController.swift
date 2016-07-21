//
//  ViewController.swift
//  TwitterDisplay
//
//  Created by Marcus Hughes on 5/16/16.
//  Copyright © 2016 Marcus Hughes. All rights reserved.
//


import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    var tweet_type  = "recent"
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var type: UISegmentedControl!
   
    @IBAction func segchange(sender: AnyObject) {
        switch type.selectedSegmentIndex
        {
        case 0:
            tweet_type = "recent"
        case 1:
            tweet_type = "popular"
        default:
            break; 
        }
    }
    @IBOutlet weak var count: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Handle searchViewController segue and save user searchterm
        if(segue!.identifier == "SearchTweets"){
            let searchVC = segue!.destinationViewController as! searchViewController
            searchVC.searchTerm = textField.text!
            searchVC.count = count.text!
            searchVC.type = tweet_type
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func searchTweets(sender: UIButton) {
        if(textField.text != ""){
            // Only segue to searchViewController if the search field isn't empty
            self.performSegueWithIdentifier("SearchTweets", sender: self)
        }
    }
    
    
}
