//
//  AdsVC.swift
//  AnimatedStories
//
//  Created by siddharth on 10/07/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import FBAudienceNetwork

class AdsVC : UIViewController {
    
    //    self.admobNativeAdsContainer = placeholder
    //    self.uicontroller = controller
    @IBOutlet var adsplaceholder: UIView!
    var adLoader: GADAdLoader!
    @IBOutlet weak var nativeAdView: GADUnifiedNativeAdView!
    
    // FBADS
    var nativeAd: FBNativeAd!
    var coverMediaView: FBMediaView!
    var nativeAdsCover:UIView!
    
    //MARK: - Shared Instance
    static let sharedInstance : AdsVC = {
        let instance = AdsVC()
        return instance
    }()
    
    override func viewDidLoad() {
//        loadNativeAds(placeholder: adsplaceholder, controller: self)
        setAdsOnNativeAds(nativeAd: GoogleAdMob.sharedInstance.readyNativeAds)
         view.translatesAutoresizingMaskIntoConstraints = false
        GoogleAdMob.sharedInstance.readyNativeAds = nil
        GoogleAdMob.sharedInstance.loadOnlyNativeAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension AdsVC {
    
    //MARK: -siddharth
    func setAdsOnNativeAds( nativeAd: GADUnifiedNativeAd){
        
        nativeAdView.isHidden = false
        nativeAdView.nativeAd = nativeAd
//        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        // Set ourselves as the native ad delegate to be notified of native ad events.
//        nativeAd.delegate = self
        
        // Deactivate the height constraint that was set when the previous video ad loaded.
        
        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        
        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from:nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        self.adsplaceholder.isHidden = false
        
      
        
    }
    
    /// if the star rating is less than 3.5 stars.
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
    
//    func setGoogleAds () {
//        //Google Ads
//        //         guard let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
//        //             let adView = nibObjects.first as? GADUnifiedNativeAdView else {
//        //                 assert(false, "Could not load nib file for adView")
//        //                 return
//        //         }
//        //         setAdView()
//        let nativeAds =  UserDefaults.standard.string(forKey: UserdefultConfig.admobNativeAds)
//        if nativeAds != nil {
//            adLoader = GADAdLoader(adUnitID: nativeAds ?? GoogleAdsUnitID.Live.strNativeAdsID, rootViewController: self,
//                                   adTypes: [ .unifiedNative ], options: nil)
//            adLoader.delegate = self
//            adLoader.load(GADRequest())
//        }
//        //          sponserCollectionView.reloadData()
//    }
//
//        public func isAdLive() -> Bool {
//            if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
//                return false
//            }
//
//            let isAdLive = UserDefaults.standard.string(forKey: UserdefultConfig.isAdmobAds) ?? "true"
//            return Bool.init(isAdLive) ?? true
//            //        return true
//        }
//
//        func loadNativeAds (placeholder:UIView, controller:UIViewController) {
//            if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
//                placeholder.isHidden = true
//                return
//            }
//
//            let nativeAds =  UserDefaults.standard.string(forKey: UserdefultConfig.admobNativeAds)
//            adLoader = GADAdLoader(adUnitID: GoogleAdsUnitID.Live.strNativeAdsID, rootViewController: controller,
//                                   adTypes: [ .unifiedNative ], options: nil)
//            adLoader.load(GADRequest())
//            adLoader.delegate = self
//        }
//
//    //    func setAdView() {
//    //
//    //        print("SetAdView Admob")
//    //        // Remove the previous ad view.
//    //        //         nativeAdsView = view
//    //        adsplaceholder.addSubview(view)
//    //        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
//    //
//    //        // Layout constraints for positioning the native ad view to stretch the entire width and height
//    //        // of the nativeAdPlaceholder.
//    //        let viewDictionary = ["_nativeAdView": nativeAdView]
//    //        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_nativeAdView]|",
//    //                                                                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
//    //        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_nativeAdView]|",
//    //                                                                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
//    //    }
//
//        //MARK: - Create Native Ads Delegate
//        func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
//            print("\(#function) called")
//
//        }
//
//        func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
//            print("\(#function) called")
//
//        }
//
//        func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
//            print("\(#function) called")
//        }
//
//        func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
//            print("\(#function) called")
//        }
//
//        func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
//            print("\(#function) called")
//        }
//
//        func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
//            print("\(#function) called")
//        }
//
//
//        func videoControllerDidEndVideoPlayback(_ videoController: Any!) {
//            // Here apps can take action knowing video playback is finished.
//            // This is handy for things like unmuting audio, and so on.
//        }
//
//        func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
//            print("\(#function) called")
//            //         setAdView()
//            setAdsOnNativeAds(nativeAd: nativeAd)
//        }
//
//        func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
//            print("admob Native Ads FAILED \(#function) \(error)")
//    //        initNativeAds(nativeAdsCover: adsplaceholder, uiviewcontroller: self)
//        }
        
}

//
//extension AdsVC : FBNativeAdDelegate{
//    //MARK:- FBNATIVEADS
//    
//    public func isFbAdLive() -> Bool {
//           if(UserDefaults.standard.bool(forKey: UserdefultConfig.isFbads)){
//               return false
//           }
//           
//           let isAdLive = UserDefaults.standard.string(forKey: UserdefultConfig.isFbads) ?? "true"
//           return Bool.init(isAdLive) ?? true
//           //        return true
//       }
//    
//    public func initNativeFBAds(nativeAdsCover:UIView,uiviewcontroller:UIViewController){
//        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
//            nativeAdsCover.isHidden = true
//            return
//        }
//        
//        self.nativeAdsCover = nativeAdsCover
//        //           self.uiviewController = uiviewcontroller
//        FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
//        
//        nativeAd = FBNativeAd(placementID: "YOUR_PLACEMENT_ID")
//        nativeAd.delegate = self
//        if(isAdLive()){
//            nativeAd.loadAd()
//        }
//    }
//    
//    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
//        adsplaceholder.subviews.map({ $0.removeFromSuperview() })
//        
//        addNativeAdonBaseView(nativeAd: nativeAd)
//        //        handleLoadedNativeAdUsingTemplate(nativeAd: nativeAd);
//        print("\(#function) called \(nativeAd.placementID)")
//    }
//    
//    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
//        print("\(#function) called \(nativeAd.placementID)")
//    }
//    
//    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
//        print("fbads nativeAd \(error)")
//    }
//    
//    private func nativeAd(nativeAd: FBNativeAd, didFailWithError error: NSError) {
//        print("fbads \(error)")
//        print("\(#function) called \(nativeAd.placementID) \(error.code)")
//    }
//    
//    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
//        print("fbads \(nativeAd.placementID)")
//        print("\(#function) called \(nativeAd.placementID)")
//    }
//    
//    func nativeAdDidDownloadMedia(_ nativeAd: FBNativeAd) {
//        print("fbads doenload\(nativeAd.placementID)")
//    }
//    
//    func addNativeAdonBaseView(nativeAd: FBNativeAd){
//        print("fbads baseview \(nativeAd.placementID)")
//        adsplaceholder.subviews.map({ $0.removeFromSuperview() })
//        
//        let nativeAdView = FBNativeAdView(nativeAd: nativeAd, with: FBNativeAdViewType.genericHeight400)
//        nativeAdView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 0, height: 500.0)
//        let adChoicesView = FBAdChoicesView(nativeAd: nativeAd)
//        nativeAdsCover.addSubview(adChoicesView)
//        adChoicesView.updateFrameFromSuperview()
//        //        nativeAd.registerView(forInteraction: nativeAdsCover, mediaView: coverMediaView, iconView: nil, viewController: uiviewController, clickableViews: [nativeAdsCover.self])
//        self.nativeAdsCover.addSubview(nativeAdView)
////        self.adsplaceholder.addSubview(nativeAdsCover)
//        
//    }
//    
//    func handleLoadedNativeAdUsingTemplate(nativeAd: FBNativeAd) {
//        let nativeAdView = FBNativeAdView(nativeAd: nativeAd, with: FBNativeAdViewType.genericHeight300)
//        nativeAdView.frame = CGRect(x: 20.0, y: 100.0, width: UIScreen.main.bounds.size.width - 40.0, height: 300.0)
//        self.nativeAdsCover.addSubview(nativeAdView)
//        self.nativeAdsCover.isHidden = false
//        
//        print("fbads baseview \(nativeAd.placementID)")
//        //                nativeAd.regi(nativeAdView, withViewController: uiviewController)
//    }
//}
