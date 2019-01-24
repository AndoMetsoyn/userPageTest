//
//  ServiceAccsesPhoto.swift
//  testproject
//
//  Created by metso on 1/24/19.
//  Copyright © 2019 metso. All rights reserved.
//

import UIKit
import Photos

struct ImagesInfo {
    var image:UIImage
    var isLivePhoto:Bool
}

protocol ChangeMsg {
    func newImages(images:[ImagesInfo])
    func showAlert()
}

class ServiceAccsesPhoto:NSObject {
    
    static var AccsesPhoto = ServiceAccsesPhoto()
    
    private var allPhotos: PHFetchResult<PHAsset>!
    private var imageMeneger = PHImageManager()
    private var images = [ImagesInfo]()
    private var size = CGSize(width: 0, height: 0)
    var delegate:ChangeMsg?
    
    private override init() {
        super.init()
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with:allPhotosOptions)
        PHPhotoLibrary.shared().register(self)
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func checkStatus() {
        if PHPhotoLibrary.authorizationStatus().rawValue == 2 {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status.rawValue == 2 {
                    if self.delegate != nil {
                        print("mtav")
                        self.delegate?.showAlert()
                    }
                }
            }
        }
    }
    
    private func fetckPhotos(allPhotos:PHFetchResult<PHAsset>!) {
       print(PHPhotoLibrary.authorizationStatus().rawValue)
        //allPhotos.c
        if let asset = allPhotos {
            for i in 0..<asset.count {
                let assetObj = asset.object(at: i)
                var isLivePhoto = false
                if assetObj.mediaSubtypes.contains(.photoLive) {
                    isLivePhoto = true
                }
                imageMeneger.requestImage(for: assetObj, targetSize: self.size, contentMode: .aspectFit, options: nil) { (image, _) in
                    if let img = image {
                        self.images.append(ImagesInfo(image: img, isLivePhoto: isLivePhoto))
                    }
                }
            }
        }
    }
    
    func getPhotos(size:CGSize) -> [ImagesInfo] {
        checkStatus()
        self.size = size
        fetckPhotos(allPhotos: self.allPhotos)
        return images
    }
  
}

extension ServiceAccsesPhoto:PHPhotoLibraryChangeObserver {
     func photoLibraryDidChange(_ changeInstance: PHChange) {
        if delegate != nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotos = PHAsset.fetchAssets(with:allPhotosOptions)
            self.fetckPhotos(allPhotos: allPhotos)
                delegate!.newImages(images: images)
        }
    }
}
