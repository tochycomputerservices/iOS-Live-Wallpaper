//
//  LoadLiveWallpaperFromServer.swift
//  iLiveWallpapers
//
//  Created by siddharth on 20/08/20.
//  Copyright © 2020 Kayla Tucker. All rights reserved.
//

import Foundation
import UIKit
import Photos
import PhotosUI
import GoogleMobileAds



class LoadLiveWallpaperFromServer_NotUsed: LibraryAccessViewController,UIScrollViewDelegate {
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var saveButton: UIButton!
    @IBOutlet weak private var closeButton: UIButton!
    private let manager = LivePhotoManager()
    private var livePhotoView = PHLivePhotoView()
    private var currentWallpaperIndex = 0
    private let adsDisplayInterval = 20
    private var interstitial: GADInterstitial!
    var filePath :String = ""
//    var livePhotoArray :[PHLivePhoto] = []
    var livePhotoArray = [PHLivePhoto]()
    var videoURLArray = [String]()
    
    /// Initial logic when the screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSaveButtonStyle()
        setupLiveWallpapersScrollView()
        prepareInterstitialAd()
    }
    
    /// Prepare the AdMob interstitial and load the ad request
    private func prepareInterstitialAd() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        interstitial.load(request)
    }
    
    /// Setup save button style
    private func setupSaveButtonStyle() {
        saveButton.layer.borderWidth = 1.5
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.cornerRadius = saveButton.frame.height/2
    }
    
    /// Setul live wallpapers into a scroll view
    private func setupLiveWallpapersScrollView() {
  
        print("data count \(wallpaperItems.count)")
        
        for livePhotoIndex in 0..<wallpaperItems.count {
            var data:ModelData = wallpaperItems[livePhotoIndex]
            
            let frame = CGRect(x: CGFloat(livePhotoIndex)*view.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
        
            let uiview = UIView(frame: frame)
            
//            imageView.contentMode = .scaleAspectFill
//            scrollView.addSubview(imageView)
             let count = scrollView.subviews.count
            scrollView.contentSize = CGSize(width: view.frame.width*CGFloat(count), height: view.frame.height)
            livePhotoView = PHLivePhotoView(frame: view.frame)
      
           
            scrollView.addSubview(livePhotoView)
             print("scrollview count \(count)")
        }
        
        loadLivePhoto()
    }
    
    /// Load live photos
    private func loadLivePhoto() {
        var data:ModelData = wallpaperItems[currentWallpaperIndex]
 
        if (self.livePhotoArray.count > 0 && self.videoURLArray.indices.contains(currentWallpaperIndex)){
//            self.livePhotoView.frame = CGRect(x: self.scrollView.contentOffset.x, y: 0, width: self.livePhotoView.frame.width, height: self.livePhotoView.frame.height)
//                       self.livePhotoView.livePhoto = self.livePhotoArray[currentWallpaperIndex]
//                       self.livePhotoView.startPlayback(with: .full)
            loadVideoWithVideoURL(URL(fileURLWithPath: self.videoURLArray[currentWallpaperIndex]))
            
        }else{
            
             loadVideoFromUrl(urlString:data.video);
        }
           // do stuff
//        if(self.livePhotoArray.count > 0 && (self.livePhotoArray[currentWallpaperIndex] != nil)){
         
        
        print("Items \(data.image) \(currentWallpaperIndex)")
        
    }
    
    
    /// Save current live wallpaper to the gallery
    private func saveCurrentLiveWallpaper() {
        guard let photoURL = Bundle.main.url(forResource: "\(currentWallpaperIndex)", withExtension: "JPG"),
            let liveURL = Bundle.main.url(forResource: "\(currentWallpaperIndex)", withExtension: "MOV") else { return }
        manager.saveLivePhoto(photoURL: photoURL, videoURL: liveURL) { (success) in
            DispatchQueue.main.async {
                LoadingView.removeLoadingView()
                if success { self.presentLivePhotoSavedAlert() }
                else { self.presentGenericErrorAlert() }
            }
        }
    }
    
    /// When scroll view ends animation
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentWallpaperIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        loadLivePhoto()
      
    }
    
    /// Invoke save action
    @IBAction private func saveAction(_ sender: UIButton) {
        requestPhotoLibraryAuthorization { (success) in
            if success { self.saveCurrentLiveWallpaper() }
        }
    }
    
    /// Hide/Show save button
    @IBAction private func showHideSaveButton(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.saveButton.alpha = self.saveButton.alpha == 0 ? 1 : 0
            self.closeButton.alpha = self.saveButton.alpha
        }
    }
    
    /// Close gallery and go back to main screen
    @IBAction private func closeGallery(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func loadVideoWithVideoURL(_ videoURL: URL) {
        manager.loadVideoFromVideoURL(videoURL) { (livePhoto) in
            DispatchQueue.main.async {
                LoadingView.removeLoadingView()
                
                if let photo = livePhoto {
                    self.livePhotoArray.append(photo)
                    self.livePhotoView.livePhoto =  photo
                    self.livePhotoView.startPlayback(with: .full)
                }
                             
                print("video count\(self.livePhotoArray.count)")
              
                do {
                    try FileManager.default.removeItem(atPath: self.filePath)
                    print("video DELETE\(self.filePath)")
              
                    LivePhotoManager.removeImageLocalPath(localPathName: self.filePath)
                    
                } catch {
                    
                }
            }
        }
    }
    
    @IBAction func swipeRight(_ sender: Any) {
         print("swipeLeft ")
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
         print("swipeLeft ")
    }
    
    func loadVideoFromUrl(urlString:String){
        LoadingView.showLoadingView()
        print("Video is loading!")
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.localDomainMask,true)[0] as AnyObject
        filePath="\(documentsPath)/unique_\(currentWallpaperIndex).MOV"
        
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async { LoadingView.showLoadingView() }
            
            if let url = URL(string: urlString),
                let urlData = NSData(contentsOf: url) {
                print("Video is loading! \(self.filePath.description)")
                DispatchQueue.main.async {
                    urlData.write(toFile: self.filePath, atomically: true)
                    print("Video is saved! \(self.filePath)")
                    self.loadVideoWithVideoURL(URL(fileURLWithPath: self.filePath))
                    self.videoURLArray.append(self.filePath)
                }
            }
        }
    }
}


