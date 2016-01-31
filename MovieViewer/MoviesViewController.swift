//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Timothy Horng on 1/18/16.
//  Copyright © 2016 Timothy Horng. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    
    var movieDataTitle: [String] = []
    var movieDataOverview: [String] = []
    var movieDataPosterPath: [String] = []
    
    var filteredDataTitle: [String]! {
        didSet {
            tableView.reloadData()
        }
    }
    
    var filteredDataOverview: [String]! {
        didSet {
            tableView.reloadData()
        }
    }
    
    var filteredDataPosterPath: [String]! {
        didSet {
            tableView.reloadData()
        }
    }
    
    // Change status bar text to white
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        networkErrorView.hidden = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.darkGrayColor()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        
        tableView.backgroundColor = UIColor.darkGrayColor()
        
        networkRequest()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func hideKeyboardTap(sender: AnyObject) {
        searchBar.endEditing(true)
    }
    
    // MARK: For default table
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filteredData = filteredDataTitle {
            return filteredData.count
        } else {
            return 0
        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        
        let posterPath = filteredDataPosterPath[indexPath.row]
        
        let baseUrl = "http://image.tmdb.org/t/p/w500/"
        
        //dataOrganizer(title, overview: overview, posterPath: posterPath)
        
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        cell.titleLabel.text = filteredDataTitle[indexPath.row]
        cell.overviewLabel.text = filteredDataOverview[indexPath.row]
        cell.posterView.setImageWithURL(imageUrl!)
        
        cell.posterView.alpha = 0.0

        UIView.animateWithDuration(0.5, animations: {
            cell.posterView.alpha = 1
        })
        
        print("row \(indexPath.row)")
        
        // for search bar
        // cell.titleLabel.text = filteredData[indexPath.row]
        
        return cell
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.setShowsCancelButton(true, animated: true)

        filteredDataTitle = searchText.isEmpty ? movieDataTitle : movieDataTitle.filter({(dataString: String) -> Bool in
            return dataString.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        
        tableView.reloadData()
    }
    
    func networkRequest() {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            self.networkErrorView.hidden = true
                            
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            for var i = 0; i < self.movies!.count; i++ {
                                let movie = self.movies![i]
                                let title = movie["title"] as! String
                                let overview = movie["overview"] as! String
                                let posterPath = movie["poster_path"] as! String
                                
                                self.movieDataTitle.append(title)
                                self.movieDataOverview.append(overview)
                                self.movieDataPosterPath.append(posterPath)
                            }
                            
                            self.filteredDataTitle = self.movieDataTitle
                            self.filteredDataOverview = self.movieDataOverview
                            self.filteredDataPosterPath = self.movieDataPosterPath
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            self.tableView.reloadData()
                        
                    }
                } else {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.networkErrorView.hidden = false
                }
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        networkRequest()
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
