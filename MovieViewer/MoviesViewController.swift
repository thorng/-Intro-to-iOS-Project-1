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

class MoviesViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    
    var movies: [NSDictionary]?
    
    var movieDataTitle: [String] = []
    var movieDataOverview: [String] = []
    var movieDataPosterPath: [String] = []
    
    var movieDict: [String:String] = [:]
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var filteredDataTitle: [String]! {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var filteredDataOverview: [String]! {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var filteredDataPosterPath: [String]! {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // Change status bar text to white
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.blackColor()

        refreshControl()
        
        networkErrorView.hidden = true
        
        searchBar.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        networkRequest()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func hideKeyboardTap(sender: AnyObject) {
        searchBar.endEditing(true)
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
        
        collectionView.reloadData()
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
                            
                            //NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            for var i = 0; i < self.movies!.count; i++ {
                                let movie = self.movies![i]
                                let title = movie["title"] as! String
                                let overview = movie["overview"] as! String
                                let posterPath = movie["poster_path"] as! String
                                
                                self.movieDataTitle.append(title)
                                self.movieDataOverview.append(overview)
                                self.movieDataPosterPath.append(posterPath)
                                
                                self.movieDict[title] = posterPath
                            }
                            
                            self.filteredDataTitle = self.movieDataTitle
                            self.filteredDataOverview = self.movieDataOverview
                            self.filteredDataPosterPath = self.movieDataPosterPath
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            self.collectionView.reloadData()
                        
                    }
                } else {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.networkErrorView.hidden = false
                }
        });
        task.resume()
    }
    
    @IBAction func networkErrorRefreshButton(sender: UIButton) {
        
        refreshControl()
        networkRequest()
    }
    
    
    func refreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.blackColor()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        networkRequest()
        
        self.collectionView.reloadData()
        refreshControl.endRefreshing()
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)

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

extension MoviesViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredData = filteredDataTitle {
            return filteredData.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath) as! MovieCollectionViewCell
        
        cell.frame.size.width = screenWidth
        
        let posterPath = filteredDataPosterPath[indexPath.row]
        let baseUrl = "http://image.tmdb.org/t/p/w500/"
        
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        let imageRequest = NSURLRequest(URL: imageUrl!)
        
        cell.posterImageView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.posterImageView.alpha = 0.0
                    cell.posterImageView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterImageView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.posterImageView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
        cell.movieTitle.text = filteredDataTitle[indexPath.row]
        cell.posterImageView.setImageWithURL(imageUrl!)
        
        print("row \(indexPath.row)")
        
        // for search bar
        // cell.titleLabel.text = filteredData[indexPath.row]
        
        return cell

    }
}
