//
//  AppDelegate.swift
//  iLiveWallpapers
//
//  Created by Apps4World on 12/4/19.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        GADMobileAds.sharedInstance().start(completionHandler: nil)
         A4WPurchaseManager.shared.initialize()
        FacebookAds.sharedInstance.createInterstitial()
        GoogleAdMob.sharedInstance.createInterstitial()
        FirebaseApp.configure()
        
        
        StoreReviewHelper.incrementAppOpenedCount()
               StoreReviewHelper.checkAndAskForReview()
               
             if #available(iOS 13.0, *) {
                   window?.overrideUserInterfaceStyle = .light
               }
               sleep(1)
        
        return true
    }
}

