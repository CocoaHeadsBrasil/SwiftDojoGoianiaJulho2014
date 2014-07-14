//
//  FotoCellView.swift
//  CocoaFlickr
//
//  Created by George Henrique Villasboas on 7/10/14.
//  Copyright (c) 2014 CocoaHeads Goiânia. All rights reserved.
//

import UIKit

class FotoCellView: UICollectionViewCell {
    
    @IBOutlet var fotoImageView: UIImageView
    @IBOutlet var spinner: UIActivityIndicatorView
    
    var _miniaturaURL:String = ""
    var miniaturaURL:String {
        get {
            return _miniaturaURL
        }
        set {
            _miniaturaURL = newValue
            
            // download image
            let url:NSURL = NSURL.URLWithString(_miniaturaURL)
            var session:NSURLSession = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url,
                completionHandler:{ (data, response, error) in
                    if error {
                        println(error.localizedDescription)
                    }
                    else {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            let image = UIImage(data: data)
                            self.fotoImageView.image = image
                            self.spinner.stopAnimating()
                        })
                    }
                })
            
            task.resume()
        }
    }
}