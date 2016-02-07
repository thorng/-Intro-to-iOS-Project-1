//
//  DetailViewcontroller.swift
//  MovieViewer
//
//  Created by Timothy Horng on 2/1/16.
//  Copyright © 2016 Timothy Horng. All rights reserved.
//

import UIKit

class DetailViewcontroller: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        if let title = movie["title"] as? String {
            titleLabel.text = title
        }
        
        if let overview = movie["overview"] as? String {
            overviewLabel.text = overview
        }
        
        let baseUrl = "http://image.tmdb.org/t/p/w500/"
        
        if let posterPath = movie["poster_path"] as? String {
            let posterURL = NSURL(string: baseUrl + posterPath)
            posterImageView.setImageWithURL(posterURL!)
        }
        
        overviewLabel.sizeToFit()
        
        print(movie)
        
    }

    
    
}
