//
//  FlickrFetcher.swift
//  CocoaFlickr
//
//  Created by George Villasboas on 7/3/14.
//  Copyright (c) 2014 CocoaHeads Goiânia. All rights reserved.
//

import Foundation

/**
 * Chaves para o servico de albuns
 */

let ALBUM_ID_KEY                = "br.com.cocoaheads.flickrfetcher.album.id"
let ALBUM_TITULO_KEY            = "br.com.cocoaheads.flickrfetcher.album.titulo"
let ALBUM_CONTAGEM_FOTOS_KEY    = "br.com.cocoaheads.flickrfetcher.album.contagem_fotos"
let ALBUM_DESCRICAO_KEY         = "br.com.cocoaheads.flickrfetcher.album.descricao"
let ALBUM_FARM_KEY              = "br.com.cocoaheads.flickrfetcher.album.farm"
let ALBUM_PRIMARY_KEY           = "br.com.cocoaheads.flickrfetcher.album.primary"
let ALBUM_SECRET_KEY            = "br.com.cocoaheads.flickrfetcher.album.secret"
let ALBUM_SERVER_KEY            = "br.com.cocoaheads.flickrfetcher.album.server"

/**
 * Chaves para o servico de fotos
 */

let FOTO_ID_KEY                 = "br.com.cocoaheads.flickrfetcher.foto.id"
let FOTO_TITULO_KEY             = "br.com.cocoaheads.flickrfetcher.foto.titulo"
let FOTO_ORIGINAL_URL_KEY       = "br.com.cocoaheads.flickrfetcher.foto.url_original"
let FOTO_ORIGINAL_WIDTH_KEY     = "br.com.cocoaheads.flickrfetcher.foto.width_original"
let FOTO_ORIGINAL_HEIGHT_KEY    = "br.com.cocoaheads.flickrfetcher.foto.height_original"
let FOTO_MINIATURA_URL_KEY      = "br.com.cocoaheads.flickrfetcher.foto.url_thumb"
let FOTO_MINIATURA_WIDTH_KEY    = "br.com.cocoaheads.flickrfetcher.foto.width_thumb"
let FOTO_MINIATURA_HEIGHT_KEY   = "br.com.cocoaheads.flickrfetcher.foto.height_thumb"
let FOTO_FARM_KEY               = "br.com.cocoaheads.flickrfetcher.foto.farm"
let FOTO_SECRET_KEY             = "br.com.cocoaheads.flickrfetcher.foto.secret"
let FOTO_SERVER_KEY             = "br.com.cocoaheads.flickrfetcher.foto.server"



class FlickrFetcher{
    
    var apiKey = ""
    
    convenience init(comChave apikey:NSString){
        self.init()
        self.apiKey = apikey
    }
    
    /**
    *  Preprocessa o resultado removendo as tags de JSONP inseridas pelo Flickr
    *
    *  @return NSData
    */
    func preprocessResult(result:NSData) -> NSData {
        var string = NSString(data: result, encoding: NSASCIIStringEncoding)
        string = string.substringFromIndex(14)
        string = string.substringToIndex(string.length - 1)
        return string.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    /**
    *  Gera objeto de erro dado alguns parametros
    *
    *  @param codigo:String   Codigo do erro
    *  @param mensagem:String Mensagem humanizada
    *  @param domain:String   Dominio do erro
    *
    *  @return Objeto de erro
    */
    func geraErro(codigo:Int, mensagem:String, domain:String) -> NSError{
        let errorDictionary = [ NSLocalizedDescriptionKey : "Erro ao processar resposta: \(codigo): \(mensagem)"]
        
        return NSError(domain: domain, code: codigo, userInfo: errorDictionary)
    }
    
    /**
    *  Pega os albuns dado um usuario. Ao processar executa o resultado no closure
    *
    *  @param user_id:String          ID do usuario no Flickr
    *  @param concluido:albuns:String Lamba a ser executado ao concluir
    *
    *  @return void
    */
    func pegarAlbuns(user_id:String, concluido:(albuns:[[String : AnyObject]], erro:NSError!) -> ()){
        let url:NSURL = NSURL.URLWithString("https://api.flickr.com/services/rest/?method=flickr.photosets.getList&api_key=" + apiKey + "&format=json&user_id=" + user_id)

        var session:NSURLSession = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url,
            completionHandler:{ (data, response, error) in
                if error {
                    concluido(albuns: [], erro: error)
                }
                else {
                    var err: NSError?
                    var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(self.preprocessResult(data), options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary

                    if jsonResult.count>0 {
                        var albuns:[[String : AnyObject]] = self.processaJSONDeAlbuns(jsonResult, erro:&err)
                        concluido(albuns:albuns, erro:err)
                    }
                }
            
            
            })
        
        task.resume()
    }
    
    /**
    *  Processa o JSON de albuns
    *
    *  @param json:NSDictionary JSON de albuns
    *
    *  @return Dicionario tratado com as chaves selecionadas
    */
    func processaJSONDeAlbuns(json:NSDictionary, inout erro:NSError?) -> [[String : AnyObject]] {
        var albumProcessado:[[String : AnyObject]] = []
        
        let possivelJson: NSDictionary? = json
        if let possuiJson = possivelJson{
            
            var resposta = json["stat"] as String
            
            if resposta == "ok" {
                var albuns = json["photosets"] as NSDictionary
                var album = albuns["photoset"] as NSArray
                
                
                var tituloAlbuns:[String] = []
                
                for object : AnyObject in album{
                    var newAlbum = [String: AnyObject]()
                    let data = object as NSDictionary
                    
                    newAlbum[ALBUM_ID_KEY] = data["id"] as? String
                    newAlbum[ALBUM_CONTAGEM_FOTOS_KEY] = data["photos"] as? String
                    newAlbum[ALBUM_TITULO_KEY] = data["title"].objectForKey("_content") as? String
                    newAlbum[ALBUM_DESCRICAO_KEY] = data["description"].objectForKey("_content") as? String
                    newAlbum[ALBUM_FARM_KEY] = data["farm"] as? String
                    newAlbum[ALBUM_PRIMARY_KEY] = data["primary"] as? String
                    newAlbum[ALBUM_SECRET_KEY] = data["secret"] as? String
                    newAlbum[ALBUM_SERVER_KEY] = data["server"] as? String
                    
                    albumProcessado += newAlbum
                }
            }
            else{
                // gera erro e devolve resultado vazio
                var codigoErro = json["code"] as Int
                var mensagem = json["message"] as String
                erro = geraErro(codigoErro, mensagem: mensagem, domain: "br.com.cocoaheads.flickrFetcher.erroAPI")
            }
        }
        
        return albumProcessado
    }

    /**
    *  Pega os albuns dado um usuario. Ao processar executa o resultado no closure
    *
    *  @param user_id:String          ID do usuario no Flickr
    *  @param concluido:albuns:String Lamba a ser executado ao concluir
    *
    *  @return void
    */
    func pegarFotosDoAlbum(album_id:String, concluido:(fotos:[[String : AnyObject]], erro:NSError!) -> ()){
        let url:NSURL = NSURL.URLWithString("https://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=" + apiKey + "&format=json&extras=url_s,url_o,url_m&media=photos&photoset_id=" + album_id)
        
        var session:NSURLSession = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url,
            completionHandler:{ (data, response, error) in
                if error {
                    // devolve falha
                    concluido(fotos: [], erro: error)
                }
                else {
                    var err: NSError?
                    var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(self.preprocessResult(data), options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                    
                    if jsonResult.count>0 {
                        var fotos:[[String : AnyObject]] = self.processaJSONDeFotos(jsonResult, erro:&err)
                        concluido(fotos:fotos, erro:err)
                    }
                }
            })
        task.resume()
        
    }
    
    /**
    *  Processa o JSON de fotos
    *
    *  @param json:NSDictionary JSON de fotos
    *
    *  @return Dicionario tratado com as chaves selecionadas
    */
    func processaJSONDeFotos(json:NSDictionary, inout erro:NSError?) -> [[String : AnyObject]] {
        var fotosProcessadas:[[String : AnyObject]] = []
        
        // flag de status vinda da api
        var resposta = json["stat"] as String
        
        if resposta == "ok" {
            var photoset:NSDictionary = json["photoset"] as NSDictionary
            var fotos:NSArray = photoset["photo"] as NSArray
            
            var tituloAlbuns:[String] = []
            
            // processa requisicao e extrai resultados
            for object in fotos{
                var newFoto = [String: AnyObject]()
                let data = object as NSDictionary
                
                newFoto[FOTO_ID_KEY] = data["id"] as? String
                newFoto[FOTO_TITULO_KEY] = data["title"] as? String
                newFoto[FOTO_ORIGINAL_URL_KEY] = data["url_m"] as? String
                newFoto[FOTO_MINIATURA_URL_KEY] = data["url_s"] as? String
                newFoto[FOTO_ORIGINAL_WIDTH_KEY] = data["width_m"] as? String
                newFoto[FOTO_ORIGINAL_HEIGHT_KEY] = data["height_m"] as? String
                newFoto[FOTO_MINIATURA_WIDTH_KEY] = data["width_s"] as? String
                newFoto[FOTO_MINIATURA_HEIGHT_KEY] = data["height_s"] as? String
                newFoto[FOTO_FARM_KEY] = data["farm"] as? String
                newFoto[FOTO_SECRET_KEY] = data["secret"] as? String
                newFoto[FOTO_SERVER_KEY] = data["server"] as? String
                
                fotosProcessadas += newFoto
            }
        }
        else{
            // gera erro e devolve resultado vazio
            var codigoErro = json["code"] as Int
            var mensagem = json["message"] as String
            erro = geraErro(codigoErro, mensagem: mensagem, domain: "br.com.cocoaheads.flickrFetcher.erroAPI")
        }
        
        return fotosProcessadas
    }
}

