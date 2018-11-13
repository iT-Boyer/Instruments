//
//  ImageUtilities.swift
//  InstrumentsTutorial
//
//  Created by James Frost on 11/03/2015.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

private let _sharedCache = ImageCache()

class ImageCache {
  var images = [String:UIImage]()
  
  class var sharedCache: ImageCache {
    return _sharedCache
  }
  
  func setImage(_ image: UIImage, forKey key: String) {
    images[key] = image
  }
  
  func imageForKey(_ key: String) -> UIImage? {
    return images[key]
  }
}

//黑白滤镜
//[Core Image Programming Guide--图像编程指南 ](http://supershll.blog.163.com/blog/static/370704362012513113447720/ )
//The biggest thing you want to do is reuse the CIContext whenever you need to use it. If you recreate it each time, your program will run very slowly. 
extension UIImage {
  func applyTonalFilter() -> UIImage? {
    let context = CIContext(options:nil)
    let filter = CIFilter(name:"CIPhotoEffectTonal")
    let input = CoreImage.CIImage(image: self)
    filter!.setValue(input, forKey: kCIInputImageKey)
    let outputImage = filter!.outputImage
    
    let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
    let returnImage = UIImage(cgImage: outImage!)
    return returnImage
  }
}
