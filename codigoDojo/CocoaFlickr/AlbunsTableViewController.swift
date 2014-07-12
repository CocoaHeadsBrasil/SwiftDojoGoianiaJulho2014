//
//  AlbunsTableViewController.swift
//  CocoaFlickr
//
//  Created by Swift Dojo on 12/07/14.
//  Copyright (c) 2014 Swift Dojo. All rights reserved.
//

import UIKit

let COCOAHEADS_BR_USUARIO_ID    = "123639495@N02"
let FLICKR_API_KEY              = "bac09d64b390438a148af5b15a7855a9"

class AlbunsTableViewController: UITableViewController {
    
    var albuns:NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let flickr = FlickrFetcher(comChave: FLICKR_API_KEY)
        
        flickr.pegarAlbuns(COCOAHEADS_BR_USUARIO_ID, concluido: {
            
            (albuns: [[String : AnyObject]], erro: NSError!) -> () in
                if erro == nil {
                    self.albuns = albuns
                    println(albuns)
                    dispatch_async(dispatch_get_main_queue(), { self.tableView.reloadData() })
                }
                else{
                    //Trata erro
                    println("Erro!")
                }
            }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.albuns.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("AlbumCell", forIndexPath: indexPath) as UITableViewCell

        
        var album:NSDictionary = self.albuns[indexPath.row] as NSDictionary
        cell.textLabel.text = album[ALBUM_TITULO_KEY] as String
        cell.detailTextLabel.text = "Fotos: \(album[ALBUM_CONTAGEM_FOTOS_KEY])" 
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // #pragma mark - Navigation

    /* In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier == "albunsParaListaFotosSegue" {
            let lfcvc = segue.destinationViewController as ListaFotosCollectionViewController
            
            let albumIndex = self.tableView.indexPathForSelectedRow().row

            let album = self.albuns[albumIndex] as NSDictionary

            lfcvc.title = album[ALBUM_TITULO_KEY] as String
            lfcvc.albumId = album[ALBUM_ID_KEY] as String

        }
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }


}
