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
    
    var moviesObject = Movie()
    var moviesObjectArray = [Movie]()
    var filteredObjectArray = [Movie]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
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
    
    func arraySetup() {
        for var i = 0; i < self.movies!.count; i++ {
            
            let movie = self.movies![i]
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            let posterPath = movie["poster_path"] as! String
            
            self.moviesObject.movieDataTitle = title
            self.moviesObject.movieDataOverview = overview
            self.moviesObject.movieDataPosterPath = posterPath
            
            self.moviesObjectArray.append(self.moviesObject)
            self.filteredObjectArray.append(self.moviesObject)
            
            print("\(i) object in filteredObjectArray: \(self.filteredObjectArray[i].movieDataTitle)")
            print("\(i) object in moviesObjectArray: \(self.moviesObjectArray[i].movieDataTitle)")
            
            collectionView.reloadData()
        }
        
        for movieObject in moviesObjectArray {
            print("movieObject: \(movieObject.movieDataTitle)")
        }
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

        filteredObjectArray = searchText.isEmpty ? moviesObjectArray : moviesObjectArray.filter({(data: Movie) -> Bool in
            
            return data.movieDataTitle.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            
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
                            
//                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            self.arraySetup()
                            
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
        return filteredObjectArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath) as! MovieCollectionViewCell
        
        cell.frame.size.width = screenWidth
        
        let baseUrl = "http://image.tmdb.org/t/p/w500/"
        
        cell.movieTitle.text = filteredObjectArray[indexPath.row].movieDataTitle
        
        let posterPath = filteredObjectArray[indexPath.row].movieDataPosterPath
        print("\(posterPath)")
        
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        let imageRequest = NSURLRequest(URL: imageUrl!)
        
        cell.posterImageView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
//                    print("Image was NOT cached, fade in image")
                    cell.posterImageView.alpha = 0.0
                    cell.posterImageView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterImageView.alpha = 1.0
                    })
                } else {
//                    print("Image was cached so just update the image")
                    cell.posterImageView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
        
        print("row \(indexPath.row)")
        
        // for search bar
        // cell.titleLabel.text = filteredData[indexPath.row]
        
        return cell

    }
}
