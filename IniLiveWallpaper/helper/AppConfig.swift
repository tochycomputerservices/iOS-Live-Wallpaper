//
//  AppConfig.swift
//  IniLiveWallpaper
//
//  Created by siddharth on 21/08/20.
//  Copyright © 2020 Kayla Tucker. All rights reserved.
//

import Foundation

public struct InAppProducts {
    public static let proVersion = "proversion"
    public static let store = A4WPurchaseManager(productIDs: InAppProducts.productIDs)
    public static let productIDs: Set<ProductID> = [InAppProducts.proVersion]
}

class AppConfig {
    public static var APPID = "";
    public static var SHARE_TEXT = "";
    /// Settings screen details
    static let privacyURL: URL = URL(string: "https://sites.google.com/view/menworkout/privacy-policy")!
    static let termsURL: URL = URL(string: "https://sites.google.com/view/menworkout/term-condition")!
    
    public static let adsDisplayInterval = 2
    
}

struct FacebookUnit {
  
    //SET FACEBOOK ANALYTICS
    //FACEBOOK Live admob Unit ID
    struct Live {
        static var isFbAds = "true"
        static var fbBannerId = "YOUR_PLACEMENT_ID" //"YOUR_PLACEMENT_ID"//
        static var fbInterstitialId = "YOUR_PLACEMENT_ID" //"422193978641492_422198365307720"
        static var fbNativeBannerId = "YOUR_PLACEMENT_ID" //"422193978641492_422198365307720"
        static var fbNativeId = "YOUR_PLACEMENT_ID" //"422193978641492_422198365307720"
    }
    
}

//MARK: - Google Ads Unit ID
struct GoogleAdsUnitID {
    
    //    //Google Test Unit ID
    struct Test {
        static var strBannerAdsID = "ca-app-pub-3940256099942544/6300978111"
        static var strInterstitialAdsID = "ca-app-pub-3940256099942544/1033173712"
        static var strNativeAdsID = "ca-app-pub-3940256099942544/1044960115"
    }
    
    //Google Live admob Unit ID
    struct Live {
        static var isAdmobAds = "true"
        static var strBannerAdsID = "ca-app-pub-3940256099942544/6300978111"
        static var strInterstitialAdsID = "ca-app-pub-3940256099942544/1033173712"
        static var strNativeAdsID = "ca-app-pub-3940256099942544/1044960115"
    }
}


struct UserdefultConfig {
    
    public static var isFbads = "isFbads"
    public static var fbBannerAds = "fbBannerAds"
    public static var fbInterstitialAds = "fbInterstitialAds"
    public static var fbNativeBannerAds = "fbNativeBannerAds"
    public static var fbNativeAds = "fbNativeAds"
    
    public static var isAdmobAds = "isAdmobAds"
    public static var admobBannerAds = "admobBannerAds"
    public static var admobInterstitialAds = "admobInterstitialAds"
    public static var admobNativeAds = "admobNativeAds"
    
    public static var scanCounter = "scanCount"
    public static var translateCounter = "translateCount"
    
    public static var isAdsFree = "isAdsFree"
    public static var didPurchasePRO = "didPurchasePRO"
    public static var expireTime = "expireTime"
    
    //    public static var didPurchasePROVersion = "isAdsFree"
    
}
