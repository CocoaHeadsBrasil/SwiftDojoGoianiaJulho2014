//
//  AlbunsTableViewController.swift
//  CocoaFlickr
//
//  Created by George Villasboas on 7/9/14.
//  Copyright (c) 2014 CocoaHeads Goiânia. All rights reserved.
//

import UIKit

/**
* Configuracoes globais usuario
*/

let COCOAHEADS_BR_USUARIO_ID    = "123639495@N02"
let FLICKR_API_KEY              = "bac09d64b390438a148af5b15a7855a9"

class AlbunsTableViewController: UITableViewController {
    
    var albuns:NSArray = []
    
    override func viewDidLoad() {
        var fetcher = FlickrFetcher(comChave: FLICKR_API_KEY)
        
        fetcher.pegarAlbuns(COCOAHEADS_BR_USUARIO_ID, concluido:{
            (albuns: [[String : AnyObject]], erro:NSError!) -> () in
            
            if erro == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.albuns = albuns
                    self.tableView.reloadData()
                    })
            }
            else{
                let alert = UIAlertController(title: "Oops", message: erro.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "fotosDoAlbumSegue" {
            let destino:FotosPorAlbumCollectionViewController = segue.destinationViewController as FotosPorAlbumCollectionViewController
            
            let path = tableView.indexPathForSelectedRow()
            let album = albuns[path.row] as NSDictionary
            
            destino.album = album[ALBUM_ID_KEY] as String
            destino.title = album[ALBUM_TITULO_KEY] as String
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int{
        return albuns.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("albumCell") as UITableViewCell
        let album = albuns[indexPath.row] as NSDictionary
        cell.textLabel.text = album[ALBUM_TITULO_KEY] as String
        cell.detailTextLabel.text = "\(album[ALBUM_CONTAGEM_FOTOS_KEY] as String) fotos"
        
        return cell
    }
}