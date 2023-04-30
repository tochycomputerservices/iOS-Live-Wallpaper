//
//  LibraryAccessViewController.swift
//  iLiveWallpapers
//
//  Created by Apps4World on 12/4/19.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

// Generic controller class to determine and request photo library access and present tutorial screen
class LibraryAccessViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func requestPhotoLibraryAuthorization(completion: @escaping (_ success: Bool) -> Void) {
        DispatchQueue.main.async {
            if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .denied || status == .restricted {
                        self.presentAuthorizationAlert()
                    } else if status == .authorized { completion(true) }
                })
            } else if PHPhotoLibrary.authorizationStatus() == .denied || PHPhotoLibrary.authorizationStatus() == .restricted {
                self.presentAuthorizationAlert()
            } else if PHPhotoLibrary.authorizationStatus() == .authorized { completion(true) }
        }
    }
    
    func presentLivePhotoSavedAlert() {
        let alert = UIAlertController(title: "Saved successfully", message: "This live wallpaper has been saved into your photo library.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "See instructions", style: .default, handler: { (_) in
            if let howTo = self.storyboard?.instantiateViewController(withIdentifier: "howto") {
                howTo.modalTransitionStyle = .crossDissolve
                self.present(howTo, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentGenericErrorAlert() {
        let alert = UIAlertController(title: "Oops", message: "Something went wrong, please try again later.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentAuthorizationAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Access required", message: "To save live wallpapers into your photo library, this app needs photo library access. Select 'Settings' to allow Photos access.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
