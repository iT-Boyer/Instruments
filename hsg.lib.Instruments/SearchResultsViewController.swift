//
//  SearchResultsViewController.swift
//  InstrumentsTutorial
//
//  Created by James Frost on 28/02/2015.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

//／图片缩略图页面
//单个cell的实现：包括收藏按钮的状态检测，当cell自身被重用时，先置image为nil
class SearchResultsCollectionViewCell : UICollectionViewCell {
  
  @IBOutlet weak var heartButton: UIButton!
  @IBOutlet weak var imageView: UIImageView!
  
  //观察属性：当图片属性为被收藏状态，改变收藏按钮颜色
  var flickrPhoto: FlickrPhoto! {
    didSet {
      if flickrPhoto.isFavourite {
        heartButton.tintColor = UIColor(red:1, green:0, blue:0.517, alpha:1)
      } else {
        heartButton.tintColor = UIColor.white
      }
    }
  }
  //定义闭包型属性，reloadItems刷新cell
  var heartToggleHandler: ((_ isFavourite: Bool) -> Void)?
  //
  override func prepareForReuse() {
    imageView.image = nil
  }
  
  @IBAction func heartTapped(_ sender: AnyObject) {
    flickrPhoto.isFavourite = !flickrPhoto.isFavourite
    
    heartToggleHandler?(flickrPhoto.isFavourite)
  }
}

class SearchResultsViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  var searchResults: FlickrSearchResults?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let resultsCount = searchResults!.searchResults.count
    
    title = "\(searchResults!.searchTerm) (\(resultsCount))"
  }
}

extension SearchResultsViewController : UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return searchResults!.searchResults.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! SearchResultsCollectionViewCell
    
    if let flickrPhoto = searchResults?.searchResults[(indexPath as NSIndexPath).item] {
      cell.flickrPhoto = flickrPhoto
      
      cell.heartToggleHandler = { isStarred in
        self.collectionView.reloadItems(at: [ indexPath ])
      }
      
      flickrPhoto.loadThumbnail { image, error in
        if cell.flickrPhoto == flickrPhoto {
          if flickrPhoto.isFavourite {
            cell.imageView.image = image
          } else {
            if let filteredImage = image?.applyTonalFilter() {
              cell.imageView.image = filteredImage
            }
          }
        }
      }
    }
    
    return cell
  }
  
}

//MARK: UICollectionViewDelegateFlowLayout
//通过代码实现layout布局控制
extension SearchResultsViewController : UICollectionViewDelegateFlowLayout
{
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // 3 images across
    let width = view.bounds.width / 3
    
    // each image has a ratio of 4:3
    let height = (width / 4) * 3
    return CGSize(width: width, height: height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
  }
}


