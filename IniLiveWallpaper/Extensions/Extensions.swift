//
//  Extensions.swift
//  iLiveWallpapers
//
//  Created by Apps4World on 12/4/19.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import UIKit
import Photos

var wallpaperItems = [ModelData]()
var livePhotoArray = [PHLivePhoto]()
var videoURLArray = [String]()

var currentWallpaper: Int {
    set {
        UserDefaults.standard.set(newValue, forKey: "currentWallpaper")
        UserDefaults.standard.synchronize()
    }
    get {
        if let _ = UserDefaults.standard.object(forKey: "currentWallpaper") {
            return   UserDefaults.standard.integer(forKey: "currentWallpaper")
        } else {
            return 0
        }
    }
}

/// Extension to show/hide loading view
class LoadingView {
    /// Static function to present a loading/spinner view when purchasing is in progress
    static func showLoadingView() {
        removeLoadingView()
        let mainView = UIView(frame: UIScreen.main.bounds)
        mainView.backgroundColor = .clear
        let darkView = UIView(frame: mainView.frame)
        darkView.backgroundColor = UIColor.black
        darkView.alpha = 0.7
        mainView.addSubview(darkView)
        let spinnerView = UIActivityIndicatorView(style: .whiteLarge)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(spinnerView)
        spinnerView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        spinnerView.startAnimating()
        mainView.tag = 1991
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as? AppDelegate)?.window?.addSubview(mainView)
        }
    }
    
    /// Static function to remove the loading/spinner view
    static func removeLoadingView() {
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as? AppDelegate)?.window?.viewWithTag(1991)?.removeFromSuperview()
        }
    }
}

/// UIView extension to apply rounded corners
extension UIView {
    func applyCornerRadius() {
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = frame.height/2
    }
}

extension Date {
    
    /// Returns a Date with the specified amount of components added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    /// Returns a Date with the specified amount of components subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
    
}
