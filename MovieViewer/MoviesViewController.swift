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
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    
    var programNetworkErrorView: UIView! = UIView(frame: CGRectMake(0, 0, 320, 568))
    
    lazy var searchBar = UISearchBar(frame: CGRectMake(0, 0, 0, 0)) // add the search bar programmatically
    
    var endpoint: String! // movie endpoint
    
    var movies: [NSDictionary]?
    
    var moviesObjectArray = [Movie]()
    var filteredObjectArray = [Movie]() {
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
        
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar
        
        searchBar.barStyle = UIBarStyle.BlackTranslucent
        
        self.automaticallyAdjustsScrollViewInsets = false // prevents an annoying inset when using search bar
        
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.blackColor()

        refreshControl()
        
        searchBar.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        networkRequest()
        
        networkErrorViewSetup()
        
    }
    
    func networkErrorViewSetup() {
        
        programNetworkErrorView.hidden = false
        
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        programNetworkErrorView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(programNetworkErrorView)
        
        let networkErrorText = UILabel(frame: CGRectMake(0, screenHeight/2, screenWidth, 40))
        networkErrorText.text = "Network Error"
        networkErrorText.textAlignment = NSTextAlignment.Center
        networkErrorText.textColor = UIColor.grayColor()
        programNetworkErrorView.addSubview(networkErrorText)
        
        let errorImageName = "error.png"
        let errorImage = UIImage(named: errorImageName)
        let networkErrorImage = UIImageView(image: errorImage)
        networkErrorImage.image = networkErrorImage.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        networkErrorImage.tintColor = UIColor.grayColor()
        networkErrorImage.contentMode = UIViewContentMode.ScaleAspectFit
        networkErrorImage.frame = CGRectMake(0, (screenHeight/2) - 30, screenWidth, 40)
        programNetworkErrorView.addSubview(networkErrorImage)
        
        let networkErrorRefreshButton = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        programNetworkErrorView.addSubview(networkErrorRefreshButton)
        networkErrorRefreshButton.addTarget(self, action: "networkErrorRefreshButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func networkErrorRefreshButtonAction(sender: UIButton) {
        
        refreshControl()
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
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func hideKeyboardTap(sender: AnyObject) {
        searchBar.endEditing(true)
    }
    
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
                if error != nil {
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.programNetworkErrorView.hidden = false
                    //                    self.networkErrorView.hidden = false
                    
                } else {
                    
                    if let data = dataOrNil {
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                            data, options:[]) as? NSDictionary {
                                
                                
                                //                            self.networkErrorView.hidden = true
                                self.programNetworkErrorView.hidden = true
                                
                                
                                //                            NSLog("response: \(responseDictionary)")
                                
                                self.movies = responseDictionary["results"] as? [NSDictionary]
                                
                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                
                                self.arraySetup()
                                
                                self.collectionView.reloadData()
                                
                        }
                    } else {
                        
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        self.programNetworkErrorView.hidden = false
                        //                    self.networkErrorView.hidden = false
                        
                    }
                    
                }

        })
        
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

// search bar actions
extension MoviesViewController {
    
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
        
        let smallImageUrl = NSURL(string: lowresBaseUrl + posterPath)
        let largeImageUrl = NSURL(string: highresBaseUrl + posterPath)
        
        let smallImageRequest = NSURLRequest(URL: smallImageUrl!)
        let largeImageRequest = NSURLRequest(URL: largeImageUrl!)
        
        loadImages(smallImageRequest, largeImageRequest: largeImageRequest, cell: cell)
        
        return cell

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
    
}


