//
//  MapViewController.swift
//  TwitterDisplay
//
//  Created by Marcus Hughes on 5/19/16.
//  Copyright © 2016 Marcus Hughes. All rights reserved.
//

import UIKit
import MapKit
import Accounts
import Social
import CoreData


class MapViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var Radius: UITextField!
 
    @IBOutlet weak var search: UITextField!
 
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    @IBAction func showSearchBar(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
        
    }
    
    @IBOutlet var mapView: MKMapView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Radius.delegate = self
        self.search.delegate = self

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Handle searchViewController segue and save user searchterm
        if(segue!.identifier == "LocationTweets"){
            let searchVC = segue!.destinationViewController as! LocationSearchTable
            searchVC.searchTerm = search.text!
            searchVC.radius = Radius.text!
            searchVC.latitude = self.pointAnnotation.coordinate.latitude.description
            searchVC.longitude = self.pointAnnotation.coordinate.longitude.description
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    

    @IBAction func SearchTweets(sender: UIButton) {
        // if(Radius.text == ""){
        // Only segue to searchViewController if the search field isn't empty
        self.performSegueWithIdentifier("LocationTweets", sender: self)
        //  }
    }
    //MARK: UISearchBar Delegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            print(self.pointAnnotation.coordinate.latitude)
            print(self.pointAnnotation.coordinate.longitude)
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    

}