//
//  FotoViewController.swift
//  CocoaFlickr
//
//  Created by George Henrique Villasboas on 7/10/14.
//  Copyright (c) 2014 CocoaHeads Goiânia. All rights reserved.
//

import UIKit

class FotoViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet var scrollView: UIScrollView
    @IBOutlet var fotoImageView: UIImageView
    @IBOutlet var spinner: UIActivityIndicatorView
    
    var _fotoURL:String = ""
    
    var fotoURL:String {
        set{
            _fotoURL = newValue
            
            // download image
            let url:NSURL = NSURL.URLWithString(_fotoURL)
            var session:NSURLSession = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url,
                completionHandler:{ (data, response, error) in
                    if error {
                        println(error.localizedDescription)
                    }
                    else {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            let image = UIImage(data: data)
                            self.fotoImageView.frame.size = image.size
                            self.fotoImageView.image = image
                            self.spinner.stopAnimating()  
                        })
                    }
                })
            
            task.resume()
        }
        get{
            return _fotoURL
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView!{
        return self.fotoImageView
    }
}
