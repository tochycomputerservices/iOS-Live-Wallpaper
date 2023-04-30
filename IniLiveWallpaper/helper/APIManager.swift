//
//  ApiManager.swift
//  AnimatedStories
//
//  Created by siddharth on 02/07/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}

class APIManager: NSObject {
    
    static let sharedInstance = APIManager()
    
    func getAdsData() {
        var urlRequest = URLRequest(url: URL(string: AppConfig.liveApi)!)
        URLCache.shared.removeCachedResponse(for: urlRequest)
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        
        Alamofire.request(AppConfig.liveApi).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do{
                    if let data = response.result.value as? NSDictionary {
                                       let objc = AppDataAds(dic: data)
                                       Singleton.shared.appAdsData = objc
                                       self.setUserDefualtValue(localModel: objc)
                                       print("API RESPONSE SUCCESS \(objc.admob) \(objc.fb_ads)")
                                   }
                    
                }catch let e{e.localizedDescription}
               
            case .failure(let error):
                print(error)
                self.setUserDefualtValue(localModel: AppDataAds())
            }
        }
    }
    
   
     func setUserDefualtValue(localModel : AppDataAds) {
         print("API SET DATA")
          do {
        if(localModel.admob != nil || localModel.fb_ads != nil){
             print("API \(localModel.admob) \(localModel.fb_ads) \(localModel.admob_banner)")
                      //Mark :- GOD
                      UserDefaults.standard.set(localModel.admob, forKey: UserdefultConfig.isAdmobAds)
                      UserDefaults.standard.set(localModel.admob_banner, forKey: UserdefultConfig.admobBannerAds)
                      UserDefaults.standard.set(localModel.admob_interstitial, forKey: UserdefultConfig.admobInterstitialAds)
                      UserDefaults.standard.set(localModel.admob_native_banner, forKey: UserdefultConfig.admobNativeAds)
                      
                      print("set API \(localModel.fb_ads) \(String(describing: localModel.fb_banner))")
                      
                      //Mark :- fbads
                      UserDefaults.standard.set(localModel.fb_ads, forKey: UserdefultConfig.isFbads)
                      UserDefaults.standard.set(localModel.fb_banner, forKey: UserdefultConfig.fbBannerAds)
                      UserDefaults.standard.set(localModel.fb_native, forKey: UserdefultConfig.fbNativeAds)
                      UserDefaults.standard.set(localModel.fb_interstitial, forKey: UserdefultConfig.fbInterstitialAds)
                      UserDefaults.standard.set(localModel.fb_native_banner, forKey: UserdefultConfig.fbNativeBannerAds)
                      print("set API \(String(describing: localModel.fb_ads)) \(String(describing: UserDefaults.standard.string(forKey: UserdefultConfig.isFbads)))")
            
        }else{
            
              print("API --- nil ")
            UserDefaults.standard.set(GoogleAdsUnitID.Live.isAdmobAds, forKey: UserdefultConfig.isAdmobAds)
                       UserDefaults.standard.set(GoogleAdsUnitID.Live.strBannerAdsID, forKey: UserdefultConfig.admobBannerAds)
                       UserDefaults.standard.set(GoogleAdsUnitID.Live.strInterstitialAdsID, forKey: UserdefultConfig.admobInterstitialAds)
                       UserDefaults.standard.set(GoogleAdsUnitID.Live.strNativeAdsID, forKey: UserdefultConfig.admobNativeAds)
                       
                       UserDefaults.standard.set(FacebookUnit.Live.isFbAds, forKey: UserdefultConfig.isFbads)
                       UserDefaults.standard.set(FacebookUnit.Live.fbBannerId, forKey: UserdefultConfig.fbBannerAds)
                       UserDefaults.standard.set(FacebookUnit.Live.fbNativeId, forKey: UserdefultConfig.fbNativeAds)
                       UserDefaults.standard.set(FacebookUnit.Live.fbInterstitialId, forKey: UserdefultConfig.fbInterstitialAds)
                       UserDefaults.standard.set(FacebookUnit.Live.fbNativeBannerId, forKey: UserdefultConfig.fbNativeBannerAds)
        }
       
                   
         } catch let e {
             e.localizedDescription
              print("API Exception")
           
         }
         
     }
}
