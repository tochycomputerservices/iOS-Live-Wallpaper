//
//  GalleryViewController.swift
//  iLiveWallpapers
//
//  Created by Apps4World on 12/4/19.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import GoogleMobileAds

// This is the gallery with all live wallpapers from the app
class GalleryViewController: LibraryAccessViewController, UIScrollViewDelegate {

    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var saveButton: UIButton!
    @IBOutlet weak private var closeButton: UIButton!
    private let manager = LivePhotoManager()
    private var livePhotoView = PHLivePhotoView()
    private var currentWallpaperIndex = 0
    
    @IBOutlet weak var primImg: UIImageView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var bannerView: UIView!
    /// Initial logic when the screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSaveButtonStyle()
        setupLiveWallpapersScrollView()
        shareButton.applyCornerRadius()
        saveButton.applyCornerRadius()
         view.bringSubviewToFront(bannerView)
//        FacebookAds.sharedInstance.initBannerView(view: bannerView)
       showInstruction(uicontroll: self)
        
    }
    
    /// Setup save button style
    private func setupSaveButtonStyle() {
        saveButton.layer.borderWidth = 1.5
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.cornerRadius = saveButton.frame.height/2
    }
    
    /// Setul live wallpapers into a scroll view
    private func setupLiveWallpapersScrollView() {
        for livePhotoIndex in 0..<INT_MAX {
            if let image = UIImage(named: "\(livePhotoIndex).JPG") {
                let frame = CGRect(x: CGFloat(livePhotoIndex)*view.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
                let imageView = UIImageView(frame: frame)
                imageView.contentMode = .scaleAspectFill
                imageView.image = image
                scrollView.addSubview(imageView)
            } else { break }
        }
        let count = scrollView.subviews.count
        scrollView.contentSize = CGSize(width: view.frame.width*CGFloat(count), height: view.frame.height)
        livePhotoView = PHLivePhotoView(frame: view.frame)
        scrollView.addSubview(livePhotoView)
        loadLivePhoto()
    }
    
    /// Load live photos
    private func loadLivePhoto() {
        
        print("current \(currentWallpaperIndex)")
        if(currentWallpaperIndex>8){
            // create the alert
           
        }
        
        guard let photoURL = Bundle.main.url(forResource: "\(currentWallpaperIndex)", withExtension: "JPG"),
            let liveURL = Bundle.main.url(forResource: "\(currentWallpaperIndex)", withExtension: "MOV")
        else { return }
        manager.loadLivePhoto(photoURL: photoURL, videoURL: liveURL) { (livePhoto) in
            DispatchQueue.main.async {
                LoadingView.removeLoadingView()
                if let photo = livePhoto {
                    self.livePhotoView.frame = CGRect(x: self.scrollView.contentOffset.x, y: 0, width: self.livePhotoView.frame.width, height: self.livePhotoView.frame.height)
                    self.livePhotoView.livePhoto = photo
                    self.livePhotoView.startPlayback(with: .full)
                }
            }
        }
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
        if currentWallpaperIndex % AppConfig.adsDisplayInterval == 0{
            FacebookAds.sharedInstance.showInterstitial(viewcontroll: self)
        }
      
//        premiumImg.isHidden = !data.isPremium
        
        if(currentWallpaperIndex%2 == 0){
            primImg.isHidden = false
        }
         primImg.isHidden = true
    }
    
    /// Invoke save action
    @IBAction private func saveAction(_ sender: UIButton) {
       
        requestPhotoLibraryAuthorization { (success) in
            if success { self.saveCurrentLiveWallpaper() }
        }
    }
    @IBAction func shareAction(_ sender: Any) {
        let photoURL = Bundle.main.url(forResource: "\(currentWallpaperIndex)", withExtension: "JPG")
        share(filepath: "\(photoURL?.path)")
    }
    
    /// Hide/Show save button
    @IBAction private func showHideSaveButton(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.saveButton.alpha = self.saveButton.alpha == 0 ? 1 : 0
            self.closeButton.alpha = self.saveButton.alpha
            self.shareButton.alpha = self.saveButton.alpha
            self.primImg.alpha = self.saveButton.alpha
        }
    }
    
    /// Close gallery and go back to main screen
    @IBAction private func closeGallery(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func share(filepath:String){
             
    //         let fileName = wallpaperData[currentWallpaperNumber]["fileName"]
    //         let pathImage = Bundle.main.path(forResource: fileName, ofType: "JPG")
            let imageURl = URL(fileURLWithPath: filepath)
             
            let appStoreURLPath = "https://itunes.apple.com/app/id/\(AppConfig.APPID)"
            let shareText = AppConfig.SHARE_TEXT + appStoreURLPath
             let activityViewController = UIActivityViewController(activityItems: [imageURl,shareText], applicationActivities: nil)
             activityViewController.setValue("Live Wallpapers", forKey: "subject")
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
             
             if UIDevice.current.userInterfaceIdiom == .pad {
                 // iPad
                 let popOver = UIPopoverController(contentViewController: activityViewController)
                 popOver.present(from: self.view.frame, in: self.view, permittedArrowDirections: .any, animated: true)
                 
             } else {
                 // iPhone
                 present(activityViewController, animated: true, completion: nil)
             }
         }
    
    /// Present purchase controller if user didn't buy the PRO Version
    private func presentPurchaseController() {
        let controller = A4WPurchaseViewController()
        controller.didPurchaseProduct = { success in
            if !success {
                let alertController = UIAlertController(title: "Oops! Something went wrong.",
                                                        message: "Failed to complete transaction. Try again later.",
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        present(controller, animated: true, completion: nil)
    }
    
}
