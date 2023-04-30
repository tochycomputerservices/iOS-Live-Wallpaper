//
//  LivePhotoManager.swift
//  iLiveWallpapers
//
//  Created by Apps4World on 12/4/19.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

// Image/Video assets will be stored temporarily at this path
struct FilePaths {
    static let documentsPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask,true)[0] as AnyObject
    static var liveAssetPath = FilePaths.documentsPath.appending("/")
    static var liveAssetPathFolder = FilePaths.documentsPath.appending("/LIVEWALPAPER/")
    static var uniquename = "uniquename"
    
}

// Main Live Photo manager to save/load live phoots
class LivePhotoManager: NSObject {
    
    /// Load video from URL (gallery), convert it, take a screenshot of it, save both image/video at file paths
    func loadVideoWithVideoURL(_ videoURL: URL, completion: @escaping (_ livePhoto: PHLivePhoto?) -> Void) {
        DispatchQueue.main.async { LoadingView.showLoadingView() }
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = NSValue(time: CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration)/2, preferredTimescale: asset.duration.timescale))
        generator.generateCGImagesAsynchronously(forTimes: [time]) { _, image, _, _, _ in
            if let image = image, let data = UIImage(cgImage: image).pngData() {
                let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let imageURL = urls[0].appendingPathComponent("image.jpg")
                try? data.write(to: imageURL, options: [.atomic])
                print("imageURL \(imageURL.absoluteString)")
                
                let image = imageURL.path
                let mov = videoURL.path
                let output = FilePaths.liveAssetPath
                let assetIdentifier = UUID().uuidString
                
                let _ = try? FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true, attributes: nil)
                do {
                    try FileManager.default.removeItem(atPath: output + "/IMG.JPG")
                    try FileManager.default.removeItem(atPath: output + "/IMG.MOV")
                    try FileManager.default.removeItem(atPath: videoURL.absoluteString)
                    
                } catch { }
                
                ImageAssetManager(path: image).write(output + "/IMG.JPG", assetIdentifier: assetIdentifier)
                VideoAssetManager(path: mov).write(output + "/IMG.MOV", assetIdentifier: assetIdentifier)
                
                self.loadLivePhoto(photoURL: URL(fileURLWithPath: FilePaths.liveAssetPath + "/IMG.JPG"),
                                   videoURL: URL(fileURLWithPath: FilePaths.liveAssetPath + "/IMG.MOV"),
                                   completion: completion)
                
            } else { LoadingView.removeLoadingView(); completion(nil) }
        }
    }
    
    
   
    func loadVideoFromVideoURL(_ videoURL: URL, completion: @escaping (_ livePhoto: PHLivePhoto?) -> Void) {
        DispatchQueue.main.async { LoadingView.showLoadingView() }
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        
        let uniqufilepath = videoURL.deletingPathExtension().lastPathComponent
//        URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
        let checkUrlImage = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(uniqufilepath).JPG");
        let checkUrlVideo = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(uniqufilepath).MOV");
           
        print(" unique111 loadVideoFromVideoURL \(checkUrlVideo) \(fileAvaibleOrNot(string: uniqufilepath))")
        if (FileManager.default.fileExists(atPath: checkUrlImage.path) && FileManager.default.fileExists(atPath: checkUrlVideo.path))   {
            self.loadLivePhoto(photoURL: checkUrlImage,videoURL: checkUrlVideo,                                                               completion: completion)
            return
        }
             
        if(fileAvaibleOrNot(string: uniqufilepath)){  // just use String when you have to check for existence of your file
           print("unique111 file available \(fileAvaibleOrNot(string: uniqufilepath))")
           self.loadLivePhoto(photoURL: URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(uniqufilepath).JPG"),
                                                       videoURL: URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(uniqufilepath).MOV"),
                                                       completion: completion)
        }else{
            
            generator.appliesPreferredTrackTransform = true
            let time = NSValue(time: CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration)/2, preferredTimescale: asset.duration.timescale))
            generator.generateCGImagesAsynchronously(forTimes: [time]) { _, image, _, _, _ in
                if let image = image, let data = UIImage(cgImage: image).pngData() {
                    let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                    let imageURL = urls[0].appendingPathComponent("image.jpg")
                    try? data.write(to: imageURL, options: [.atomic])
                    print("imageURL \(imageURL.absoluteString)")
                    
                    let image = imageURL.path
                    let mov = videoURL.path
                    let output = FilePaths.liveAssetPathFolder
                    let assetIdentifier = UUID().uuidString
                    print("image \(image)")
                    print("image \(mov)")
                    print("image \(output)")
                    
                    let _ = try? FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true, attributes: nil)
                    do {
                        try FileManager.default.removeItem(atPath: output + "/\(uniqufilepath).JPG")
                        try FileManager.default.removeItem(atPath: output + "/\(uniqufilepath).MOV")
//                        try FileManager.default.removeItem(atPath: mov)
//                        LivePhotoManager.removeImageLocalPath(localPathName: mov)
//                        LivePhotoManager.newDeletFile(filePath: mov)
                    } catch { }
                    
                    ImageAssetManager(path: image).write(output + "/\(uniqufilepath).JPG", assetIdentifier: assetIdentifier)
                    VideoAssetManager(path: mov).write(output + "/\(uniqufilepath).MOV", assetIdentifier: assetIdentifier)
                    
                    self.loadLivePhoto(photoURL: URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(uniqufilepath).JPG"),
                                       videoURL: URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(uniqufilepath).MOV"),
                                       completion: completion)
                    
                } else { LoadingView.removeLoadingView(); completion(nil) }
            }
            
        }
    }
    
    /// Loads a live photo from two given URLs
    func loadLivePhoto(photoURL: URL, videoURL: URL, completion: @escaping (_ livePhoto: PHLivePhoto?) -> Void) {
        DispatchQueue.main.async {
            PHLivePhoto.request(withResourceFileURLs: [photoURL, videoURL], placeholderImage: nil, targetSize: UIScreen.main.bounds.size, contentMode: PHImageContentMode.aspectFit, resultHandler: { (livePhoto, info) -> Void in completion(livePhoto) })
        }
    }
    
    /// Save live photo to gallery
    func saveLivePhoto(photoURL imageURL: URL? = nil, videoURL: URL? = nil, completion: @escaping (_ success: Bool) -> Void) {
        DispatchQueue.main.async {
            LoadingView.showLoadingView()
            let photoURL = imageURL ?? URL(fileURLWithPath: FilePaths.liveAssetPath + "/IMG.JPG")
            let liveURL = videoURL ?? URL(fileURLWithPath: FilePaths.liveAssetPath + "/IMG.MOV")
            PHPhotoLibrary.shared().performChanges({ () -> Void in
                let creationRequest = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: liveURL, options: options)
                creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: photoURL, options: options)
            }, completionHandler: { (success, error) -> Void in LoadingView.removeLoadingView(); completion(success) })
        }
    }
    
    func saveLivePhotoFromServer(_ videoURL: URL,completion: @escaping (_ success: Bool) -> Void) {
           DispatchQueue.main.async {
               LoadingView.showLoadingView()
              let uniqufilepath = videoURL.deletingPathExtension().lastPathComponent
                       print("unique \(uniqufilepath)")
                       let checkUrlImage = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(uniqufilepath).JPG");
                       let checkUrlVideo = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(uniqufilepath).MOV");
               PHPhotoLibrary.shared().performChanges({ () -> Void in
                   let creationRequest = PHAssetCreationRequest.forAsset()
                   let options = PHAssetResourceCreationOptions()
                   creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: checkUrlVideo, options: options)
                   creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: checkUrlImage, options: options)
               }, completionHandler: { (success, error) -> Void in LoadingView.removeLoadingView(); completion(success) })
           }
       }
    
    public static func removeImageLocalPath(localPathName:String) {
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent(localPathName)
        do {
            try filemanager.removeItem(atPath: destinationPath)
            print("Local path removed successfully")
        } catch let error as NSError {
            print("------Error",error.debugDescription)
        }
        
        let fileManager = FileManager.default
        do {
            let url = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil) {
                while let fileURL = enumerator.nextObject() as? URL {
                    try fileManager.removeItem(at: fileURL)
                }
            }
        }  catch  {
            print(error)
            print("------Error 222",error.localizedDescription)
        }
    }
    
    public func fileAvaibleOrNot(string:String)->Bool{
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
          let url = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(string).MOV");
        
        if (FileManager.default.fileExists(atPath: url.path))   {
              print("FILE AVAILABLE")
              return true
          }else        {
              print("FILE NOT AVAILABLE")
              return false;
          }
    }
    
    func clearCache(){
//        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheURL1 = URL(fileURLWithPath: FilePaths.liveAssetPathFolder)
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL1, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }

            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

}
