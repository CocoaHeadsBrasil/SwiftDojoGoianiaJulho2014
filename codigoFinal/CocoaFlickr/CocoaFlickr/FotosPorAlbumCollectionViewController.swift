//
//  FotosPorAlbumCollectionViewController.swift
//  CocoaFlickr
//
//  Created by George Henrique Villasboas on 7/10/14.
//  Copyright (c) 2014 CocoaHeads Goiânia. All rights reserved.
//

import UIKit

class FotosPorAlbumCollectionViewController: UICollectionViewController {
    
    var album:String = ""
    var fotos:NSArray = []
    
    override func viewDidLoad() {
        var fetcher = FlickrFetcher(comChave: FLICKR_API_KEY)
        
        fetcher.pegarFotosDoAlbum(album){
            (fotos: [[String : AnyObject]], erro:NSError!) -> () in
            
            if erro == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.fotos = fotos;
                    self.collectionView.reloadData()
                    })
            }
            else{
                let alert = UIAlertController(title: "Oops", message: erro.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return fotos.count
    }
    
    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell:FotoCellView = collectionView.dequeueReusableCellWithReuseIdentifier("FotoCell", forIndexPath: indexPath) as FotoCellView
        
        let foto = fotos[indexPath.row] as NSDictionary
        cell.miniaturaURL = foto[FOTO_MINIATURA_URL_KEY] as String
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize
    {
        let foto = fotos[indexPath.row] as NSDictionary
        let width = foto[FOTO_MINIATURA_WIDTH_KEY] as String
        let height = foto[FOTO_MINIATURA_HEIGHT_KEY] as String
        
        return CGSize(width: width.toInt()!/3, height: height.toInt()!/3)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!){
        if segue.identifier == "fotoSegue" {
            let destino:FotoViewController = segue.destinationViewController as FotoViewController
            
            let path = collectionView.indexPathsForSelectedItems()[0] as NSIndexPath
            let foto = fotos[path.row] as NSDictionary
            
            destino.fotoURL = foto[FOTO_ORIGINAL_URL_KEY] as String
            destino.title = "Foto: \(foto[FOTO_TITULO_KEY] as String)"
        }
    }
}
