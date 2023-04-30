//
//  AlertInfo.swift
//  IniLiveWallpaper
//
//  Created by siddharth on 28/08/20.
//  Copyright © 2020 Kayla Tucker. All rights reserved.
//

import Foundation
import UIKit

func showInstruction(uicontroll:UIViewController){
    let alert = UIAlertController(title: "CHANGE Wallpaper !!", message: "SWIPE LEFT - RIGHT to change Wallpaper", preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: {action in
        
    }));
    
    // show the alert
    uicontroll.present(alert, animated: true, completion: nil)
}

func showLastWallpaperInstruction(uicontroll:UIViewController){
    let alert = UIAlertController(title: "Free Wallpaper !!", message: "You are end of free wallpaper Collection !", preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: {action in
        
    }));
    
    // show the alert
    uicontroll.present(alert, animated: true, completion: nil)
}
