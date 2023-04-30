//
//  APIModel.swift
//  AnimatedStories
//
//  Created by siddharth on 02/07/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import Foundation

class Singleton : NSObject {
    
    static let shared = Singleton()
    
    var localDataTon = [LocalDataModel]()
    var appAdsData : AppDataAds?
    
}

class AppDataAds {
    
    var fb_ads : String?
    var fb_interstitial : String?
    var fb_banner : String?
    var fb_native_banner : String?
    var fb_native : String?
    
    var admob : String?
    var admob_appid : String?
    var admob_interstitial : String?
    var admob_banner : String?
    var admob_native_banner : String?
    
    var apps = [Apps]()
    
    init () {
    }
    
    init (dic : NSDictionary){
        self.fb_ads = dic.value(forKey: "fb_ads") as? String
        self.fb_interstitial = dic.value(forKey: "fb_interstitial") as? String
        self.fb_banner = dic.value(forKey: "fb_banner") as? String
        self.fb_native_banner = dic.value(forKey: "fb_native_banner") as? String
        self.fb_native = dic.value(forKey: "fb_native") as? String
        
        self.admob = dic.value(forKey: "admob") as? String
        self.admob_appid = dic.value(forKey: "admob_appid") as? String
        self.admob_interstitial = dic.value(forKey: "admob_interstitial") as? String
        self.admob_banner = dic.value(forKey: "admob_banner") as? String
        self.admob_native_banner = dic.value(forKey: "admob_native_banner") as? String
        
        if let apps = dic.value(forKey: "apps") as? NSArray {
            print(apps)
            for (index, element) in apps.enumerated() {
                print(index, ":", element)
                if let data = element as? NSDictionary{
                    let objc = Apps(dic: data)
                    self.apps.append(objc)
                }
            }
        }
    }
}

class Apps {
    var appname : String?
    var packagename : String?
    var link : String?
    var image : String?
    var description : String?
    
    init () {
        
    }
    
    init (dic : NSDictionary) {
        self.appname = dic.value(forKey: "appname") as? String
        self.packagename = dic.value(forKey: "packagename") as? String
        self.link = dic.value(forKey: "link") as? String
        self.image = dic.value(forKey: "image") as? String
        self.description = dic.value(forKey: "description") as? String
    }
}
//Local Data Model
class LocalDataModel {
    var english: String!
    var hindi: String!
    var fav: String!
    var id : String
    init(english: String, hindi: String!, fav: String!, id: String!) {
        self.english = english
        self.hindi = hindi
        self.fav = fav
        self.id = id
    }
}
