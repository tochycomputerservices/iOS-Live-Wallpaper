//
//  LoadLiveWallpaperFromUrl.swift
//  iLiveWallpapers
//
//  Created by siddharth on 20/08/20.
//  Copyright © 2020 Kayla Tucker. All rights reserved.
//

import Foundation
import Photos
import PhotosUI

class LoadLiveWallpaperFromUrl : LibraryAccessViewController {
    
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var premiumImg: UIImageView!
    
    private let manager = LivePhotoManager()
    private var livePhotoView: PHLivePhotoView!
    private var didSaveWallpaper = false
    var videoURL: URL!
    var filePath :String = ""
     var data:ModelData!
    @IBOutlet weak var bannerAds: UIView!
    
    /// Initial logic when the screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView = PHLivePhotoView(frame: view.frame)
        view.addSubview(livePhotoView)
        view.bringSubviewToFront(closeButton)
        view.bringSubviewToFront(saveButton)
        view.bringSubviewToFront(shareButton)
        view.bringSubviewToFront(premiumImg)
        view.bringSubviewToFront(bannerAds)
        currentWallpaper = 0
        saveButton.applyCornerRadius()
        shareButton.applyCornerRadius()
       
//         FacebookAds.sharedInstance.initBannerView(view:bannerAds)
        
        let photoURL = Bundle.main.url(forResource: "1", withExtension: "JPG")
        if(wallpaperItems.count < 2){
             data = wallpaperItems[0]
            self.navigationController?.popViewController(animated: true)
              LoadingView.removeLoadingView()
        }
        
        loadLivePhoto()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        
        view.addGestureRecognizer(swipeLeft)
        
        showInstruction(uicontroll: self)
        
        
    }
    
    @objc func handleSwipe(sender:UISwipeGestureRecognizer){
        
        print("handleSwipe\(sender.direction)")
        
        if sender.state == .ended {
            
            switch sender.direction {
            case .right:
                swipeGestureRight(sender)
                break
            case .left:
                swipeGestureLeft(sender)
                break
            case .up: break
            case .down: break
            default:
                swipeGestureRight(sender)
            }
        }
    }
    
    /// Close build mode and go back to home/main screen
    @IBAction func closeBuild(_ sender: UIButton) {
        //        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Save custom built live photo to library
    @IBAction func saveAction(_ sender: UIButton) {
        //        let uniqufilepath = videoURL.deletingPathExtension().lastPathComponent
        print("unique \(data.isPremium) \(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)))")
        
        if(data.isPremium){
            if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
                let photoURL = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(FilePaths.uniquename)\(currentWallpaper).JPG");
                let videoURL = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(FilePaths.uniquename)\(currentWallpaper).MOV");
                print("unique \(photoURL)")
                manager.saveLivePhoto(photoURL: photoURL, videoURL: videoURL) { (success) in
                    DispatchQueue.main.async {
                        LoadingView.removeLoadingView()
                        if success { self.presentLivePhotoSavedAlert() }
                        else { self.presentGenericErrorAlert() }
                    }
                }
                
            }else{
                presentPurchaseController()
            }
        }else{
            let photoURL = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(FilePaths.uniquename)\(currentWallpaper).JPG");
                           let videoURL = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(FilePaths.uniquename)\(currentWallpaper).MOV");
                           print("unique \(photoURL)")
                           manager.saveLivePhoto(photoURL: photoURL, videoURL: videoURL) { (success) in
                               DispatchQueue.main.async {
                                   LoadingView.removeLoadingView()
                                   if success { self.presentLivePhotoSavedAlert() }
                                   else { self.presentGenericErrorAlert() }
                               }
                           }
        }
        
        
    }
    
    /// Hide/Show save button
    @IBAction private func showHideSaveButton(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.saveButton.alpha = self.saveButton.alpha == 0 ? 1 : 0
            self.closeButton.alpha = self.saveButton.alpha
            self.shareButton.alpha = self.saveButton.alpha
            self.premiumImg.alpha = self.saveButton.alpha
        }
    }
    
//    919010057618928
    
    /// Load video from URL and prepare the live photo
    private func loadVideoWithVideoURL(_ videoURL: URL) {
     
        manager.loadVideoFromVideoURL(videoURL) { (livePhoto) in
            DispatchQueue.main.async {
                LoadingView.removeLoadingView()
                if let photo = livePhoto {
                    self.livePhotoView.livePhoto = photo
                    self.livePhotoView.startPlayback(with: .full)
                }
                do {
                    try FileManager.default.removeItem(atPath: self.filePath)
                    
                    LivePhotoManager.removeImageLocalPath(localPathName: self.filePath)
                    
                } catch {
                    
                }
            }
        }
    }
    
    @IBAction func swipeGestureRight(_ sender: Any) {
        print("Video is RIGHT!")
        showNext()
    }
    
    @IBAction func swipeGestureLeft(_ sender: Any) {
        print("Video is LEFT!")
        showPrevious()
    }
    
    func showNext(){
        
        currentWallpaper += 1
        if currentWallpaper > wallpaperItems.count - 1 {
            currentWallpaper = 0
        }
        
        loadLivePhoto()
        
    }
    
    func showPrevious(){
        currentWallpaper -= 1
        if currentWallpaper < 0 {
            currentWallpaper = wallpaperItems.count - 1
        }
        loadLivePhoto()
    }
    
    private func loadLivePhoto() {
        
        if currentWallpaper % AppConfig.adsDisplayInterval == 0{
                 FacebookAds.sharedInstance.showInterstitial()
        }
        data = wallpaperItems[currentWallpaper]
        
        premiumImg.isHidden = !data.isPremium
        
        let photoURL = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(FilePaths.uniquename)\(currentWallpaper).JPG");
        let videoURL = URL(fileURLWithPath: FilePaths.liveAssetPathFolder + "/\(FilePaths.uniquename)\(currentWallpaper).MOV");
        
        if(FileManager.default.fileExists(atPath: photoURL.path)){
            manager.loadLivePhoto(photoURL: photoURL, videoURL: videoURL) { (livePhoto) in
                DispatchQueue.main.async {
                    LoadingView.removeLoadingView()
                    if let photo = livePhoto {
                        
                        self.livePhotoView.livePhoto = photo
                        self.livePhotoView.startPlayback(with: .full)
                    }
                }
            }
            
        }else{
            loadVideoFromUrl(urlString:data.video);
        }
        
        print("Items \(wallpaperItems.count) \(currentWallpaper)")
        
    }
    
    func loadVideoFromUrl(urlString:String){
        LoadingView.showLoadingView()
        print("Video is loading!")
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
        filePath="\(documentsPath)/\(FilePaths.uniquename)\(currentWallpaper).MOV"
        
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async { LoadingView.showLoadingView() }
            
            if let url = URL(string: urlString),
                let urlData = NSData(contentsOf: url) {
                print("Video is loading! \(self.filePath.description)")
                DispatchQueue.main.async {
                    urlData.write(toFile: self.filePath, atomically: true)
                    print("Video is saved! \(self.filePath)")
                    self.loadVideoWithVideoURL(URL(fileURLWithPath: self.filePath))
                    videoURLArray.append(self.filePath)
                }
            }
        }
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
