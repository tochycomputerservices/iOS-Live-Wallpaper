//
//  StoreReviewHelper.swift
//  Template1
//
//  Created by Appworldking on 17/07/19.
//  Copyright © 2017 Appworldking. All rights reserved.
//

import Foundation
import StoreKit
let Defaults = UserDefaults.standard
struct UserDefaultsKeys {
    static let APP_OPENED_COUNT = "APP_OPENED_COUNT"
}
struct StoreReviewHelper {
    static func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        guard var appOpenCount = Defaults.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
        appOpenCount += 1
        Defaults.set(appOpenCount, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
    }
    static func checkAndAskForReview() { // call this whenever appropriate
        incrementAppOpenedCount()
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        guard let appOpenCount = Defaults.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
        
        switch appOpenCount {
        case 6,10,15,20,25,30,35:
            StoreReviewHelper().requestReview()
        case _ where appOpenCount%100 == 0 :
            StoreReviewHelper().requestReview()
        default:
            print("App run count is : \(appOpenCount)")
            break;
        }
        
    }
    fileprivate func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
            // Try any other 3rd party or manual method here.
        }
    }
}
