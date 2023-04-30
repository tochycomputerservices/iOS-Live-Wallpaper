//
//  Model.swift
//  iLiveWallpapers
//
//  Created by siddharth on 20/08/20.
//  Copyright © 2020 Kayla Tucker. All rights reserved.
//

import Foundation

//MARK: - ModelAnimal
public class ModelData{
    var name: String = ""
    var video: String = ""
    var image: String = ""
    var isPremium: Bool = false
        
    init(dict: NSDictionary) {
        self.name = dict["Name"] as! String
        self.video = dict["Video"] as! String
        self.image = dict["Image"] as! String
          self.isPremium = dict["isPremium"] as! Bool
    }
    
    init(name:String,video:String,image:String,isPremium:Bool) {
        self.name = name
        self.video = video
        self.image = image
        self.isPremium = isPremium
    }
}
