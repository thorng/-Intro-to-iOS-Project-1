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
//    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    
    lazy var searchBar = UISearchBar(frame: CGRectMake(0, 0, 0, 0))
    
    var endpoint: String!
    
    var movies: [NSDictionary]?
    
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
        
//        let leftNavBarButton = UIBarButtonItem(customView: searchBar)
//        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar
        
        searchBar.barStyle = UIBarStyle.BlackTranslucent
        
        self.automaticallyAdjustsScrollViewInsets = false // prevents an annoying inset when using search bar
        
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
            
            let moviesObject = Movie()

            let movie = self.movies![i]
            
            if let title = movie["title"] as? String {
                moviesObject.movieDataTitle = title

            }
            
            if let overview = movie["overview"] as? String {
                moviesObject.movieDataOverview = overview
            }
            
            if let posterPath = movie["poster_path"] as? String {
                moviesObject.movieDataPosterPath = posterPath
            }
            
            self.moviesObjectArray.append(moviesObject)
            self.filteredObjectArray.append(moviesObject)
            
//            print("\(i) object in filteredObjectArray: \(self.filteredObjectArray[i].movieDataTitle)")
//            print("\(i) object in moviesObjectArray: \(self.moviesObjectArray[i].movieDataTitle)")
            
//            collectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func hideKeyboardTap(sender: AnyObject) {
        searchBar.endEditing(true)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.setShowsCancelButton(true, animated: true)

        filteredObjectArray = searchText.isEmpty ? moviesObjectArray : moviesObjectArray.filter({(data: Movie) -> Bool in
            
            let movieSearch = data.movieDataTitle.rangeOfString(searchText, options: .CaseInsensitiveSearch)
            
            return movieSearch != nil
            
        })
        
        collectionView.reloadData()
    }
    
//    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//        
//        let barButton = UIBarButtonItem(title: "Button Title", style: UIBarButtonItemStyle.Done, target: self, action: "here")
//        self.navigationItem.rightBarButtonItem = barButton
//        
//    }
    
    func networkRequest() {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewcontroller
        detailViewController.movie = movie
    }
    

}

extension MoviesViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredObjectArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath) as! MovieCollectionViewCell
                
//        let baseUrl = "http://image.tmdb.org/t/p/w500/"
        let lowresBaseUrl = "https://image.tmdb.org/t/p/w45"
        let highresBaseUrl = "https://image.tmdb.org/t/p/original"
        
        cell.movieTitle.text = filteredObjectArray[indexPath.row].movieDataTitle
        
        let posterPath = filteredObjectArray[indexPath.row].movieDataPosterPath
        
//        let imageUrl = NSURL(string: baseUrl + posterPath)
        let smallImageUrl = NSURL(string: lowresBaseUrl + posterPath)
        let largeImageUrl = NSURL(string: highresBaseUrl + posterPath)
        
//        let imageRequest = NSURLRequest(URL: imageUrl!)
        
//        cell.posterImageView.setImageWithURLRequest(
//            imageRequest,
//            placeholderImage: nil,
//            success: { (imageRequest, imageResponse, image) -> Void in
//                
//                // imageResponse will be nil if the image is cached
//                if imageResponse != nil {
////                    print("Image was NOT cached, fade in image")
//                    cell.posterImageView.alpha = 0.0
//                    cell.posterImageView.image = image
//                    UIView.animateWithDuration(0.3, animations: { () -> Void in
//                        cell.posterImageView.alpha = 1.0
//                    })
//                } else {
////                    print("Image was cached so just update the image")
//                    cell.posterImageView.image = image
//                }
//            },
//            failure: { (imageRequest, imageResponse, error) -> Void in
//                // do something for the failure condition
//        })
        
        let smallImageRequest = NSURLRequest(URL: smallImageUrl!)
        let largeImageRequest = NSURLRequest(URL: largeImageUrl!)
        
        loadImages(smallImageRequest, largeImageRequest: largeImageRequest, cell: cell)
        
        return cell

    }
}

func loadImages (smallImageRequest: NSURLRequest, largeImageRequest: NSURLRequest, cell: MovieCollectionViewCell) {
    
    
    cell.posterImageView.setImageWithURLRequest(
        smallImageRequest,
        placeholderImage: nil,
        success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
            
            //image fading when cached/not cached
            if smallImageResponse != nil {
                //                    print("Image was NOT cached, fade in image")
                cell.posterImageView.alpha = 0.0
                cell.posterImageView.image = smallImage
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    cell.posterImageView.alpha = 1.0
                    }, completion: { (success) -> Void in
                        
                        cell.posterImageView.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                cell.posterImageView.image = largeImage
                                
                            },
                            failure: { (request, response, error) -> Void in
                                print("Couldn't retrieve large image at \(cell)")
                        })
                })
                
            }
            else {
                //                    print("Image was cached so just update the image")
                cell.posterImageView.setImageWithURLRequest(
                    largeImageRequest,
                    placeholderImage: smallImage,
                    success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                        
                        cell.posterImageView.image = largeImage
                        
                    },
                    failure: { (request, response, error) -> Void in
                        print("Couldn't retrieve large image at \(cell)")
                })
            }
            
    
        }, failure: { (request, response, error) -> Void in
            print("Couldn't retrieve small image at \(cell)")
    })
    
}
