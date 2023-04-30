//
//  FacebookAds.swift
//  WeightLosingYoga
//
//  Created by siddharth on 28/08/19.
//  Copyright © 2019 siddharth. All rights reserved.
//

import Foundation
import FBAudienceNetwork
import AdSupport

//422193978641492_422198365307720 // interstitial
//422193978641492_422194571974766 //banner

class FacebookAds:NSObject, FBInterstitialAdDelegate, FBAdViewDelegate ,FBNativeAdDelegate{
    
    //MARK: - Shared Instance
    static let sharedInstance : FacebookAds = {
        let instance = FacebookAds()
        return instance
    }()
    
    var interstitialAds: FBInterstitialAd!
    var interstitialAds1: FBInterstitialAd!
    
    var bannerView: FBAdView!
    var uiBannerView:UIView! = nil
    
    var nativeAd: FBNativeAd!
    var coverMediaView: FBMediaView!
    var nativeAdsCover:UIView!
    
    var uiviewController: UIViewController!
    
    func isAdLive() -> Bool {
        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
            return false
        }
        
        let isAdLive = UserDefaults.standard.string(forKey: UserdefultConfig.isFbads) ?? "true"
        return Bool.init(isAdLive) ?? true
    }
    
    //MARK: - initbanner just call this method
    @objc public func initBannerView(view : UIView){
        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
            hideBanner(view);
            return
        }
        
        print("FACEBOOK : create banner \(isAdLive())")
        if UIApplication.shared.keyWindow?.rootViewController == nil {
            //            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(createBannerView), object: nil)
            //            self.perform(#selector(createBannerView), with: nil, afterDelay: 0.5)
        } else {
            bannerView = FBAdView(placementID: UserDefaults.standard.string(forKey:UserdefultConfig.fbBannerAds) ?? FacebookUnit.Live.fbBannerId, adSize: kFBAdSizeHeight50Banner,rootViewController: UIApplication.shared.keyWindow?.rootViewController)
            
            //            FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
            self.bannerView.delegate = self
            self.uiBannerView = view;
            self.bannerView.backgroundColor = .white
            //            self.bannerView.mediaCachePolicy = FBNativeAdsCachePolicy;
            print("FACEBOOK : loaded \(isAdLive()) :: \(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree))")
            
            if(isAdLive()){
                self.bannerView.loadAd()
            }else {
                GoogleAdMob.sharedInstance.initBannerView(view: uiBannerView)
            }
            
            print("FACEBOOK : loaded")
            //            UIApplication.shared.keyWindow?.addSubview(bannerView)
        }
        
    }
    
    func showBanner(_ banner: UIView) {
        print("fb SHow Banner")
        UIView.beginAnimations("showBanner", context: nil)
        
        uiBannerView.isHidden = false
        uiBannerView.translatesAutoresizingMaskIntoConstraints = false
        let contrain = NSLayoutConstraint(
            item: uiBannerView,
            attribute: .height,
            relatedBy: .equal,
            toItem: uiBannerView,
            attribute: .height,
            multiplier: 1.0,
            constant: banner.frame.height)
        
        //        uiBannerView.addConstraint(contrain)
        NSLayoutConstraint.activate([uiBannerView.heightAnchor.constraint(equalToConstant: 50)])
        
        //        uiBannerView.autoSetDimension(.height, toSize: 128)
        //        stackView.addArrangedSubview(view)
        //        banner.frame = CGRect(x: uiBannerView.frame.size.width/2 - banner.frame.size.width/2, y: uiBannerView.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        
        banner.frame = CGRect(x:0, y: 0, width: BannerViewSize.screenWidth, height: BannerViewSize.height)
        
        uiBannerView.addSubview(banner)
        uiBannerView.translatesAutoresizingMaskIntoConstraints = false;
        uiBannerView.frame.size.height = banner.frame.size.height
        
        UIView.commitAnimations()
        uiBannerView.translatesAutoresizingMaskIntoConstraints = false
        uiBannerView.isHidden = false
        
    }
    
    func hideBanner(_ banner: UIView) {
        print("FACEBOOK Hide Banner")
        UIView.beginAnimations("hideBanner", context: nil)
        self.uiBannerView = banner;
        GoogleAdMob.sharedInstance.initBannerView(view: uiBannerView)
        //        uiBannerView.frame.size.height = banner.frame.size.height
        //        banner.frame = CGRect(x: uiBannerView.frame.size.width/2 - banner.frame.size.width/2, y: uiBannerView.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        //        UIView.commitAnimations()
        //        NSLayoutConstraint.activate([uiBannerView.heightAnchor.constraint(equalToConstant: 0)])
        //        uiBannerView.isHidden = true
    }
    
    
    func adViewDidLoad(_ adView: FBAdView) {
        if(uiBannerView != nil){
            showBanner(adView)
        }
        print("FACEBOOK banner loaded fb Banner")
    }
    
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        if(uiBannerView != nil){
            //            hideBanner(bannerView)
            GoogleAdMob.sharedInstance.initBannerView(view:uiBannerView)
        }
        
        if(uiBannerView?.isHidden ?? true){
            uiBannerView?.isHidden = true
        }
        print("FACEBOOK banner failed")
        print(error)
    }
    
    
    //MARK: - Interstitial load & init
    public func createInterstitial() {
        print("Fb create Interstitial")
        interstitialAds = FBInterstitialAd(placementID: UserDefaults.standard.string(forKey: UserdefultConfig.fbInterstitialAds) ?? FacebookUnit.Live.fbInterstitialId)
        interstitialAds.delegate = self
        print("ides \(ASIdentifierManager.shared().advertisingIdentifier)")
        if(isAdLive()){
            interstitialAds.load()
        }
        initInterstitial();
        
    }
    
    public func initInterstitial(){
        interstitialAds1 = FBInterstitialAd(placementID: UserDefaults.standard.string(forKey: UserdefultConfig.fbInterstitialAds) ?? FacebookUnit.Live.fbInterstitialId)
        interstitialAds1.delegate = self
        print("ides \(ASIdentifierManager.shared().advertisingIdentifier)")
        
        if(isAdLive()){
            interstitialAds1.load()
        }
    }
    
    //MARK: - Show Interstitial Ads
    func showInterstitial() {
        
        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
            return
        }
//        if(GoogleAdMob.sharedInstance.readyNativeAds != nil){
//            GoogleAdMob.sharedInstance.showNativeInterstitialAds(parentController: (UIApplication.shared.keyWindow?.rootViewController!)!)
//        }else{
//            GoogleAdMob.sharedInstance.loadOnlyNativeAds()
//        }
        
        if interstitialAds?.isAdValid == true {
            interstitialAds.show(fromRootViewController: UIApplication.shared.keyWindow?.rootViewController)
            print("FB First initialize Interstitial")
            createInterstitial()
            return
        }
        
        if interstitialAds1?.isAdValid == true {
            interstitialAds1.show(fromRootViewController: UIApplication.shared.keyWindow?.rootViewController)
            print("FB First initialize Interstitial")
            createInterstitial()
            return
        }
        
        GoogleAdMob.sharedInstance.showInterstitial()
        
    }
    
    func showInterstitial(viewcontroll:UIViewController) {
        print("FB First\(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)) ")
        
        //        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
        //            return
        //        }
        //        print("FB First \(GoogleAdMob.sharedInstance.readyNativeAds != nil)")
        //        if(GoogleAdMob.sharedInstance.readyNativeAds != nil){
        //            GoogleAdMob.sharedInstance.showNativeInterstitialAds(parentController: viewcontroll)
        //        }else{
        //            GoogleAdMob.sharedInstance.loadOnlyNativeAds()
        //        }
        
        if interstitialAds?.isAdValid == true {
            interstitialAds.show(fromRootViewController: UIApplication.shared.keyWindow?.rootViewController)
            print("FB First initialize Interstitial")
            createInterstitial()
            return
        }
        
        if interstitialAds1?.isAdValid == true {
            interstitialAds1.show(fromRootViewController: UIApplication.shared.keyWindow?.rootViewController)
            print("FB First initialize Interstitial")
            createInterstitial()
            return
        }
        
        //        GoogleAdMob.sharedInstance.showInterstitial()
        
    }
    
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        if(self.interstitialAds.isAdValid){
            self.interstitialAds1 = interstitialAd
        }
        self.interstitialAds = interstitialAd
        print("Fb interstitial ready !!!")
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        print("Fb interstitial Failed !!!")
    }
    
    
    //MARK:- FBNATIVEADS
    public func initNativeAds(nativeAdsCover:UIView,uiviewcontroller:UIViewController){
        self.nativeAdsCover = nativeAdsCover
        self.uiviewController = uiviewcontroller
        //        FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
        nativeAd = FBNativeAd(placementID: UserDefaults.standard.string(forKey: UserdefultConfig.fbNativeAds) ?? FacebookUnit.Live.fbNativeId)
        nativeAd.delegate = self
        if(isAdLive()){
            nativeAd.loadAd()
        }
    }
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        addNativeAdonBaseView(nativeAd: nativeAd)
        //        handleLoadedNativeAdUsingTemplate(nativeAd: nativeAd);
        print("\(#function) called \(nativeAd.placementID)")
    }
    
    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        print("\(#function) called \(nativeAd.placementID)")
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        print("fbads nativeAd \(error)")
    }
    
    
    private func nativeAd(nativeAd: FBNativeAd, didFailWithError error: NSError) {
        print("fbads \(error)")
        print("\(#function) called \(nativeAd.placementID) \(error.code)")
    }
    
    
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        print("fbads \(nativeAd.placementID)")
        print("\(#function) called \(nativeAd.placementID)")
    }
    
    func nativeAdDidDownloadMedia(_ nativeAd: FBNativeAd) {
        print("fbads doenload\(nativeAd.placementID)")
    }
    
    func addNativeAdonBaseView(nativeAd: FBNativeAd){
        print("fbads baseview \(nativeAd.placementID)")
        nativeAdsCover.subviews.map({ $0.removeFromSuperview() })
        
        let nativeAdView = FBNativeAdView(nativeAd: nativeAd, with: FBNativeAdViewType.genericHeight300)
        nativeAdView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 0, height: 300.0)
        let adChoicesView = FBAdChoicesView(nativeAd: nativeAd)
        nativeAdsCover.addSubview(adChoicesView)
        adChoicesView.updateFrameFromSuperview()
        //        nativeAd.registerView(forInteraction: nativeAdsCover, mediaView: coverMediaView, iconView: nil, viewController: uiviewController, clickableViews: [nativeAdsCover.self])
        self.nativeAdsCover.addSubview(nativeAdView)
        
    }
    
    func handleLoadedNativeAdUsingTemplate(nativeAd: FBNativeAd) {
        let nativeAdView = FBNativeAdView(nativeAd: nativeAd, with: FBNativeAdViewType.genericHeight300)
        nativeAdView.frame = CGRect(x: 20.0, y: 100.0, width: UIScreen.main.bounds.size.width - 40.0, height: 300.0)
        self.nativeAdsCover.addSubview(nativeAdView)
        self.nativeAdsCover.isHidden = false
        
        print("fbads baseview \(nativeAd.placementID)")
        //                nativeAd.regi(nativeAdView, withViewController: uiviewController)
    }
    
    
    //    func setupFacebookAds () {
    //        FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
    //        if Singleton.shared.appAdsData != nil {
    //            //                nativeAd = FBNativeAd(placementID: "941665819503521_1013663665637069")
    //            nativeAd = FBNativeAd(placementID: Singleton.shared.appAdsData!.fb_native!)
    //            nativeAd.delegate = self
    //            nativeAd.loadAd()
    //        }
    //
    //    }
    
}

