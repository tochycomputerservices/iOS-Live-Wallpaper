import UIKit
import GoogleMobileAds


//MARK: - Banner View Size
struct BannerViewSize {
    static var screenWidth = UIScreen.main.bounds.size.width
    static var screenHeight = UIScreen.main.bounds.size.height
    static var height = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 50 : 50))
}

//MARK: - Create GoogleAdMob Class
class GoogleAdMob:NSObject, GADInterstitialDelegate, GADBannerViewDelegate ,GADUnifiedNativeAdDelegate,GADUnifiedNativeAdLoaderDelegate  {
    
    //MARK: - Shared Instance
    static let sharedInstance : GoogleAdMob = {
        let instance = GoogleAdMob()
        return instance
    }()
    
    //MARK: - Variable Declaration
    private var isBannerViewDisplay = false
    
    private var isInitializeBannerView = false
    private var isInitializeInterstitial = false
    
    private var isBannerLiveID = true
    
    private var isInterstitialLiveID = true
    
    private var interstitialAdsList: [GADInterstitial] = []
    private var interstitialAds: GADInterstitial!
    
    private var bannerView: GADBannerView!
    var adLoader: GADAdLoader!
    
    var uiBannerView:UIView! = nil
    
    var admobNativeAdsContainer:UIView! = nil
    
    var nativeAdView:GADUnifiedNativeAdView!
    var readyNativeAds:GADUnifiedNativeAd!
    
    var uicontroller:UIViewController!
    
    
    public func isAdLive() -> Bool {
        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
            return false
        }
        
        let isAdLive = UserDefaults.standard.string(forKey: UserdefultConfig.isAdmobAds) ?? "true"
        return Bool.init(isAdLive) ?? true
        //        return true
    }
    
    //MARK: -
    
    func showNativeInterstitialAds (parentController:UIViewController){
//        let controller = AdsVC()
        //                 controller.didPurchaseProduct = { success in
        //                     if !success {
        //                         let alertController = UIAlertController(title: "Oops! Something went wrong.",
        //                                                                 message: "Failed to complete transaction. Try again later.",
        //                                                                 preferredStyle: .alert)
        //                         alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        //                         parentController.present(alertController, animated: true, completion: nil)
        //                     }
        //                 }
        
        if isAdLive(){
            parentController.present(AdsVC(), animated: true, completion: nil)
            loadOnlyNativeAds()
        }
 
    }
    
    
    
    //MARK: - CALL FOR NATIVE ADS
    func loadOnlyNativeAds() {
        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree) || !isAdLive()){
            return
        }
        
        let nativeAds =  UserDefaults.standard.string(forKey: UserdefultConfig.admobNativeAds)
        
        if nativeAds != nil {
            if isAdLive() == true {
                adLoader = GADAdLoader(adUnitID:  nativeAds ?? GoogleAdsUnitID.Live.strNativeAdsID, rootViewController: uicontroller,
                                       adTypes: [ .unifiedNative ], options: nil)
                adLoader.load(GADRequest())
                adLoader.delegate = self
            }
        }
    }
    
    func loadNativeAds (placeholder:UIView, controller:UIViewController) {
        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
            placeholder.isHidden = true
            return
        }
        
        self.admobNativeAdsContainer = placeholder
        self.uicontroller = controller
        //Google Ads
        guard let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADUnifiedNativeAdView else {
                assert(false, "Could not load nib file for adView")
                return
        }
        
        let nativeAds =  UserDefaults.standard.string(forKey: UserdefultConfig.admobNativeAds)
        
        if nativeAds != nil {
            if isAdLive() == true {
                adLoader = GADAdLoader(adUnitID: nativeAds ?? GoogleAdsUnitID.Live.strNativeAdsID, rootViewController: uicontroller,
                                       adTypes: [ .unifiedNative ], options: nil)
                adLoader.load(GADRequest())
                adLoader.delegate = self
            }
        }
        //        setAdView()
    }
    
    func setAdView() {
        guard let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
            let view = nibObjects.first as? GADUnifiedNativeAdView else {
                assert(false, "Could not load nib file for adView")
                return
        }
        print("SetAdView Admob")
        // Remove the previous ad view.
        nativeAdView = view
        admobNativeAdsContainer.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for positioning the native ad view to stretch the entire width and height
        // of the nativeAdPlaceholder.
        let viewDictionary = ["_nativeAdView": nativeAdView]
        self.uicontroller.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_nativeAdView]|",
                                                                             options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
        self.uicontroller.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_nativeAdView]|",
                                                                             options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
    }
    
    
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
        
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
        
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
    
    
    func videoControllerDidEndVideoPlayback(_ videoController: Any!) {
        // Here apps can take action knowing video playback is finished.
        // This is handy for things like unmuting audio, and so on.
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
       
        readyNativeAds = nativeAd
        
//        if(readyNativeAds == nil){
//            readyNativeAds = nativeAd
//        }
//        else if(admobNativeAdsContainer != nil){
//             setAdView()
//                   setAdsOnNativeAds(nativeAd: nativeAd)
//               }
               
    }
    
    //MARK: -siddharth w
    func setAdsOnNativeAds( nativeAd: GADUnifiedNativeAd){
        
        nativeAdView.isHidden = false
        nativeAdView.nativeAd = nativeAd
        
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self
        
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
        
        self.admobNativeAdsContainer.isHidden = false
        
        
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
    
    func setGoogleAds () {
        //Google Ads
        guard let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADUnifiedNativeAdView else {
                assert(false, "Could not load nib file for adView")
                return
        }
        setAdView()
        let nativeAds =  UserDefaults.standard.string(forKey: UserdefultConfig.admobNativeAds)
        if nativeAds != nil {
            adLoader = GADAdLoader(adUnitID: nativeAds ?? GoogleAdsUnitID.Live.strNativeAdsID, rootViewController: uicontroller,
                                   adTypes: [ .unifiedNative ], options: nil)
            adLoader.delegate = self
            adLoader.load(GADRequest())
        }
        //          sponserCollectionView.reloadData()
    }
    
    
    //MARK: - Create Native Ads
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("admob Native Ads FAILED \(#function) \(error)")
//        FacebookAds.sharedInstance.initNativeAds(nativeAdsCover: admobNativeAdsContainer, uiviewcontroller: uicontroller)
    }
    
    //MARK: - INIT BANNER WITH VIEW
    @objc  func initBannerView(view : UIView){
        self.uiBannerView = view
        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
            uiBannerView?.isHidden = true
            hideBanner(uiBannerView);
            return
        }
        
        let bannerid = UserDefaults.standard.string(forKey: UserdefultConfig.admobBannerAds) ?? GoogleAdsUnitID.Live.strBannerAdsID;
        
        print("GoogleAdMobINIT : create \(bannerid)")
        
        if UIApplication.shared.keyWindow?.rootViewController == nil {
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(initBannerView), object: nil)
            self.perform(#selector(initBannerView), with: nil, afterDelay: 0.5)
            
        } else {
            
            isBannerViewDisplay = true
            bannerView = GADBannerView(frame: CGRect(
                x:0 ,
                y:BannerViewSize.screenHeight - BannerViewSize.height ,
                width:BannerViewSize.screenWidth-20 ,
                height:BannerViewSize.height))
            bannerView = GADBannerView(adSize:kGADAdSizeBanner)
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
            self.bannerView.adUnitID = bannerid
            self.bannerView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
            self.bannerView.delegate = self
            self.bannerView.backgroundColor = .white
            
            //                  GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
            [ "b6ddc3b1cc813685852993b20d670dcc" ]
            
            if isAdLive(){
                self.bannerView.load(GADRequest())
            }
            
            //            uiBannerView.addSubview(bannerView)
            
            //            uiBannerView.addSubview(bannerView)
        }
        
        self.uiBannerView = view;
        
    }
    
    func showBanner(_ banner: UIView) {
        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
            uiBannerView?.isHidden = true
            hideBanner(uiBannerView);
            return
        }
        
        print("admob uibannerview show banner")
        print("GoogleAdMobINIT : create \(banner.frame.height)")
        
        UIView.beginAnimations("showBanner", context: nil)
        if(uiBannerView != nil){
            
            uiBannerView.translatesAutoresizingMaskIntoConstraints = false
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
        
    }
    
    func hideBanner(_ banner: UIView) {
        //        UIView.beginAnimations("hideBanner", context: nil)
        //        uiBannerView.frame.size.height = banner.frame.size.height
        //        banner.frame = CGRect(x: uiBannerView.frame.size.width/2 - banner.frame.size.width/2, y: uiBannerView.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        //        UIView.commitAnimations()
        //        NSLayoutConstraint.activate([uiBannerView.heightAnchor.constraint(equalToConstant: 0)])
        
        //        FacebookAds.sharedInstance.initBannerView(view: banner)
        if(uiBannerView != nil ){
//            UIView.beginAnimations("hideBanner", context: nil)
//            uiBannerView?.frame.size.height = banner.frame.size.height
            banner.frame = CGRect(x: uiBannerView.frame.size.width/2 - banner.frame.size.width/2, y: uiBannerView.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
            UIView.commitAnimations()
            NSLayoutConstraint.activate([uiBannerView.heightAnchor.constraint(equalToConstant: 0)])
            uiBannerView.isHidden = true
        }
        
        print("admob Hide show")
        //        uiBannerView.frame.size.height = 0;
        //        uiBannerView.isHidden = true
        
    }
    
    //MARK: - GADBannerView Delegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("admob banner show \(isAdLive())")
        if(uiBannerView != nil && isAdLive()){
            print("admob not nill")
            showBanner(bannerView)
        }
        print("admob adViewDidReceiveAd")
    }
    
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        
        print("adViewDidDismissScreen")
    }
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        
        print("adViewWillDismissScreen")
    }
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        
        print("adViewWillPresentScreen")
    }
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        
        print("adViewWillLeaveApplication")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        if(uiBannerView != nil){
            hideBanner(bannerView)
        }
        //        FacebookAds.sharedInstance.initBannerView(view: uiBannerView)
        if(uiBannerView?.isHidden ?? true){
            uiBannerView?.isHidden = true
        }
        
        print("admob \(error)")
        
    }
    
    //MARK: - Create Interstitial Ads
    func initializeInterstitial() {
        self.isInitializeInterstitial = true
        self.isInterstitialLiveID = isAdLive()
        self.createInterstitial()
    }
    
    func createInterstitial() {
        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
            return
        }
        
        loadOnlyNativeAds()
        
        let GoogleIds = UserDefaults.standard.string(forKey: UserdefultConfig.admobInterstitialAds) ?? GoogleAdsUnitID.Live.strInterstitialAdsID
        print("Admob Create \(interstitialAdsList.count) \(GoogleIds) \(isAdLive())")
        
        interstitialAds = GADInterstitial(adUnitID: GoogleIds)
        
        interstitialAds.delegate = self
        
        if isAdLive() {
            interstitialAds.load(GADRequest())
        }
        
        //        FacebookAds.sharedInstance.createInterstitial()
        
    }
    
    //MARK: - Show Interstitial Ads
    func showInterstitial() {
        if(UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)){
            return
        }
        
        print("Admob Show Interstitial \(interstitialAdsList.count)")
        
        if(interstitialAdsList.count > 0 ){
            for item in interstitialAdsList {
                print("Admob Create \(item.isReady)")
                if item.isReady {
                    item.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
                    self.createInterstitial()
                    return
                }
            }
            //                for(n,interstiti) in interstitialAds.enumerated() {
            //                    interstiti.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
            //                    interstitialAds.remove(at: n)
            //                    return
            //                }
        }
        
    }
    
    //MARK: - GADInterstitial Delegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        interstitialAdsList.append(ad)
        print("interstitialDidReceiveAd")
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        
        print("interstitialDidDismissScreen")
        self.createInterstitial()
    }
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        
        print("interstitialWillDismissScreen")
        //        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showBanner), object: nil)
        //        self.perform(#selector(showBanner), with: nil, afterDelay: 0.1)
    }
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        
        print("interstitialWillPresentScreen")
        
    }
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        
        print("interstitialWillLeaveApplication")
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        
        print("interstitialDidFail")
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        
        print("interstitial \(error)")
    }
}
