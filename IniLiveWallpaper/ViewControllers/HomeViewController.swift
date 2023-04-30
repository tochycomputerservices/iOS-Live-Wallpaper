//
//  HomeViewController.swift
//  iLiveWallpapers
//
//  Created by Apps4World on 12/4/19.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices
import StoreKit

// This is the main home screen that user see when app launches
class HomeViewController: LibraryAccessViewController,SKPaymentTransactionObserver {
    
    @IBOutlet weak var livePhotoContainer: UIView!
    @IBOutlet weak var buildButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var instructions: UILabel!
    private let manager = LivePhotoManager()
    private var livePhotoView = PHLivePhotoView()
    @IBOutlet weak var buildBtn: UIButton!
    
    @IBOutlet weak var primBtn: UIButton!
    @IBOutlet weak var clearCachesBtn: UIButton!
    
    @IBOutlet weak var bannerAds: UIView!
    let firebaseManager = FirebaseManager.shared
    
    /// Initial logic when the screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView = PHLivePhotoView(frame: view.frame)
        livePhotoContainer.addSubview(livePhotoView)
        buildBtn.applyCornerRadius()
        primBtn.applyCornerRadius()
        clearCachesBtn.applyCornerRadius()
        
        //        galleryButton.applyCornerRadius()
        loadLivePhoto()
//        wallpaperData()
        
        FacebookAds.sharedInstance.createInterstitial()
        GoogleAdMob.sharedInstance.createInterstitial()
        FacebookAds.sharedInstance.initBannerView(view:bannerAds)
//        firebaseManager.loadItems();
        firebaseManager.loadWallpaper{(wall) in
        }
        
      
        
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            LoadingView.removeLoadingView()
        })
        
        

    }
    
    @IBAction func clearCachesAction(_ sender: Any) {
        
        LoadingView.showLoadingView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            LoadingView.removeLoadingView()
               })
          manager.clearCache()
    }
    @IBAction func premiumAction(_ sender: Any) {
        presentPurchaseController()
    }
    
    @IBAction func liveWall2(_ sender: Any) {
        if let build = self.storyboard?.instantiateViewController(withIdentifier: "serverbuild") as? LoadLiveWallpaperFromServer_NotUsed {
            self.navigationController?.pushViewController(build, animated: true)//(build, animated: true, completion: nil)
        }
    }
    
    @IBAction func liveWallpaper(_ sender: Any) {
        print()
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "serverload") as? LoadLiveWallpaperFromUrl
        self.navigationController?.pushViewController(vc!, animated: true)
        FacebookAds.sharedInstance.showInterstitial()
        
        //
        
    }
    /// When user selects build option
    @IBAction func buildAction(_ sender: UIButton) {
        requestPhotoLibraryAuthorization { (success) in
            DispatchQueue.main.async { if success { self.presentImageVideoPicker() }}
        }
    }
    
    @IBAction func galleryAction(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "galleryview") as? GalleryViewController
        self.navigationController?.pushViewController(vc!, animated: true)
          FacebookAds.sharedInstance.showInterstitial()
    }
    
    /// Present image picker / gallery
    private func presentImageVideoPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .savedPhotosAlbum
        picker.mediaTypes = [kUTTypeMovie as String]
        present(picker, animated: true, completion: nil)
    }
    
    /// Load live photos
    @objc private func loadLivePhoto() {
        
        guard let photoURL = Bundle.main.url(forResource: "7", withExtension: "JPG"),
            let liveURL = Bundle.main.url(forResource: "7", withExtension: "MOV")
            else { return }
        manager.loadLivePhoto(photoURL: photoURL, videoURL: liveURL) { (livePhoto) in
            DispatchQueue.main.async {
                LoadingView.removeLoadingView()
                if let photo = livePhoto {
                    self.livePhotoView.livePhoto = photo
                    self.livePhotoView.startPlayback(with: .full)
                }
            }
        }
    }
    
    /// Launch build screen after user selected a video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                if let build = self.storyboard?.instantiateViewController(withIdentifier: "build") as? BuildViewController {
                    build.videoURL = url
                    self.present(build, animated: true, completion: nil)
                }
            }
        }
    }
    
    func wallpaperData() {
        
        if let path = Bundle.main.path(forResource: "alldata", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                    let data = jsonResult["datalist"] as? [Any] {
                    for dataResult in data {
                        let dictDataResult = dataResult as! NSDictionary
                        //                        WelcomeVC.arrYogaList.append(ModelYogaData.init(dict: dictDataResult))
                        wallpaperItems.append(ModelData.init(dict: dictDataResult))
                        print(dictDataResult.allValues)
                        print("mudra item \(wallpaperItems.count)")
                    }
                    print("mudra \(wallpaperItems.count)")
                    
                }
            } catch let error {
                error.localizedDescription
                print("Error : \(error.localizedDescription)")
            }
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
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
           //
        print("purchase: \(transactions.description)")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        var isBuyed = false
   
        if #available(iOS 13.0, *) {
            print("purchase \(#function): \(queue.storefront.debugDescription.description)")
        } else {
            // Fallback on earlier versions
        }
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            print("purchase: \(t.payment.productIdentifier)")
            let prodID = t.payment.productIdentifier as String
            if t.transactionState == .restored || t.transactionState == .purchased {
                switch prodID {
                case InAppProducts.proVersion:
                    if let date1 = t.transactionDate?.add(years: 1, months: 0, days: 0, hours: 0, minutes: 0, seconds: 0) {
                        if self.compare(date1) {
                            isBuyed = true
                        }
                    }
                    print("purchase: \(t.transactionDate)")
//                case Config().sub30DaysId:
//                    if let date1 = t.transactionDate?.add(years: 0, months: 1, days: 0, hours: 0, minutes: 0, seconds: 0) {
//                        if self.compare(date1) {
//                            isBuyed = true
//                        }
//                    }
                default:
                    print("purchase: paymentQueueRestoreCompletedTransactionsFinished error")
                }
            }
        }
        
        UserDefaults.standard.set(isBuyed, forKey: UserdefultConfig.isAdsFree)
        if(!isBuyed){
            presentPurchaseController()
        }
        
        if isBuyed {
                   primBtn.isHidden = true
               }
        print("purchase: queue \(isBuyed)")
    }
    
    func compare(_ date: Date) -> Bool {
        let comp = Date().compare(date)
        print("compare: \(comp == .orderedAscending)")
        return comp == .orderedAscending
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().add(self)
        if (SKPaymentQueue.canMakePayments()) {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
}
