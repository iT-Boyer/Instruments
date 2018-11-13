//
//  FlickrSearcher.swift
//  flickrSearch
//
//  Created by Richard Turton on 31/07/2014.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import UIKit
//apiKey一天有效期：获取方法参看readme.md介绍
let apiKey = "8343a630cdd7b965cf0cf265fb93fe0b"

struct FlickrSearchResults {
  let searchTerm : String
  let searchResults : [FlickrPhoto]
}

//定义下载器
//初始化必要的下载属性组装下载路径，定义图片下载完成的处理方法属性，
class FlickrPhoto : Equatable {
  let photoID : String
  let title: String
  fileprivate let farm : Int
  fileprivate let server : String
  fileprivate let secret : String
  
  //定义在图片下载完成后处理的方法属性
  typealias ImageLoadCompletion = (_ image: UIImage?, _ error: NSError?) -> Void
  
  //初始化下载过程中需要的所有属性
  init (photoID:String, title:String, farm:Int, server:String, secret:String) {
    self.photoID = photoID
    self.title = title
    self.farm = farm
    self.server = server
    self.secret = secret
  }
  
  func flickrImageURL(_ size:String = "m") -> URL {
    return URL(string: "http://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg")!
  }
  
    //下载预览图
  func loadThumbnail(_ completion: @escaping ImageLoadCompletion) {
        loadImageFromURL(flickrImageURL("m")) { image, error in
        completion(image, error)
    }
  }

    //下载原图
  func loadLargeImage(_ completion: @escaping ImageLoadCompletion) {
    loadImageFromURL(flickrImageURL("b"), completion: completion)
  }
  
  func loadImageFromURL(_ URL: Foundation.URL, completion: @escaping ImageLoadCompletion) {
    let loadRequest = URLRequest(url: URL)
    //开启网络访问，下载图片
    NSURLConnection.sendAsynchronousRequest(loadRequest,
      queue: OperationQueue.main) {
        response, data, error in
        
        if error != nil {
          completion(nil, error as NSError?)
          return
        }
        
        if data != nil {
          completion(UIImage(data: data!), nil)
          return
        }
        
        completion(nil, nil)
    }
  }
}

//点赞
extension FlickrPhoto {
  var isFavourite: Bool {
    get {
      return UserDefaults.standard.bool(forKey: photoID)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: photoID)
    }
  }
}

//Equatable:
//该协议要求任何遵循的类型实现等式符(==)和不等符(!=)对任何两个该类型进行比较。所有的Swift标准类型自动支持Equatable协议
func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
  return lhs.photoID == rhs.photoID
}

//MARK: 通过搜索关键字，解析APIKey数据信息，显示搜索结果信息
class Flickr {
  
  let processingQueue = OperationQueue()
    
  func searchFlickrForTerm(_ searchTerm: String, completion : @escaping (_ results: FlickrSearchResults?, _ error : NSError?) -> Void){
    
    let searchURL = flickrSearchURLForSearchTerm(searchTerm)
    let searchRequest = URLRequest(url: searchURL)
    
    NSURLConnection.sendAsynchronousRequest(searchRequest, queue: processingQueue) {response, data, error in
      if error != nil {
        completion(nil,error as NSError?)
        return
      }
      //json结构数据解析
      var JSONError : NSError?
      let resultsDictionary = try! JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary
      if JSONError != nil {
        completion(nil, JSONError)
        return
      }
      
      switch (resultsDictionary!["stat"] as! String) {
          case "ok":
            print("Results processed OK")
          case "fail":
            let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:resultsDictionary!["message"]!])
            completion(nil, APIError)
            return
          default:
            let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, APIError)
            return
      }
      
      let photosContainer = resultsDictionary!["photos"] as! NSDictionary
      let photosReceived = photosContainer["photo"] as! [NSDictionary]
      
      let flickrPhotos : [FlickrPhoto] = photosReceived.map {
        photoDictionary in
        
        let photoID = photoDictionary["id"] as? String ?? ""
        let title = photoDictionary["title"] as? String ?? ""
        let farm = photoDictionary["farm"] as? Int ?? 0
        let server = photoDictionary["server"] as? String ?? ""
        let secret = photoDictionary["secret"] as? String ?? ""
        
        let flickrPhoto = FlickrPhoto(photoID: photoID, title: title, farm: farm, server: server, secret: secret)
        
        return flickrPhoto
      }
      
      //主线程执行闭包更新UI
      DispatchQueue.main.async(execute: {
        completion(FlickrSearchResults(searchTerm: searchTerm, searchResults: flickrPhotos), nil)
      })
    }
  }
  
    fileprivate func flickrSearchURLForSearchTerm(_ searchTerm:String) -> URL {
        let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=30&format=json&nojsoncallback=1"
        return URL(string: URLString)!
    }
  
}
