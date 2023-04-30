//
//  FirebaseData.swift
//  Green VPN
//
//  Created by Alexey on 23.04.2020.
//  Copyright © 2020 voronoff. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseRemoteConfig

public class FirebaseManager {
    static var shared = FirebaseManager()
    private init() {}
    
    lazy var ref = Database.database().reference()
    
    func loadWallpaper(comletion: @escaping ([ModelData])->()) {
         LoadingView.showLoadingView()
        print("wallpaperItems \(#function) ")
        Database.database().isPersistenceEnabled = true
        let ref1 = ref.child("live")
        print("wallpaperItems \(ref1.key)")
        
        ref1.observe(.value) { (snapshot) in
            print("wallpaperItems \(snapshot.children.allObjects)")
            var vpns: [ModelData] = []
            for object in snapshot.children.allObjects {
                guard let dataObj = object as? DataSnapshot else { continue }
                let name = dataObj.key
                guard let namedata = dataObj.childSnapshot(forPath: "Name").value as? String else { continue }
                guard let image = dataObj.childSnapshot(forPath: "Image").value as? String else { continue }
                guard let video = dataObj.childSnapshot(forPath: "Video").value as? String else { continue }
                guard let premium = dataObj.childSnapshot(forPath: "isPremium").value as? Bool else { continue }
                
                //                let vpn = ModelData(ip: address, psk: PSK, password: password, username: username, name: name, flag: flag, country: country, premium: premium)
                let model = ModelData(name:namedata,video:video,image:image,isPremium:premium)
                wallpaperItems.append(model)
                 LoadingView.removeLoadingView()
                print("wallpaperItems \(namedata) \(image) \(wallpaperItems.count) \(wallpaperItems[0].name)")
                //                vpns.append(vpn)
            }
            comletion(vpns)
        }
    }
    
    func loadItems(){
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
            remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true);
      let wallpaper = remoteConfig.configValue(forKey: "livewallpaper")
          
        remoteConfig.fetch() { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
        
        let livewallpaper = remoteConfig["livewallpaper"].stringValue
         print("Config fetched! !! \(wallpaper) ::  \(livewallpaper)")
        do {
            let data = livewallpaper!.data(using: .utf8)!
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
}
