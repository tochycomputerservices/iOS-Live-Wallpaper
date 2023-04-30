//
//  BuildViewController.swift
//  iLiveWallpapers
//
//  Created by Apps4World on 12/4/19.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

// This is the build mode that user can select videos from library to build live photos
class BuildViewController: LibraryAccessViewController {

    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    private let manager = LivePhotoManager()
    private var livePhotoView: PHLivePhotoView!
    private var didSaveWallpaper = false
    var videoURL: URL!
    
    /// Initial logic when the screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView = PHLivePhotoView(frame: view.frame)
        view.addSubview(livePhotoView)
        view.bringSubviewToFront(closeButton)
        view.bringSubviewToFront(saveButton)
        saveButton.applyCornerRadius()
        loadVideoWithVideoURL(videoURL)
    }
    
    /// Close build mode and go back to home/main screen
    @IBAction func closeBuild(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Save custom built live photo to library
    @IBAction func saveAction(_ sender: UIButton) {
        manager.saveLivePhoto { (success) in
            DispatchQueue.main.async {
                if success { self.presentLivePhotoSavedAlert() }
                else { self.presentGenericErrorAlert() }
            }
        }
    }
    
    /// Hide/Show save button
    @IBAction private func showHideSaveButton(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.saveButton.alpha = self.saveButton.alpha == 0 ? 1 : 0
            self.closeButton.alpha = self.saveButton.alpha
        }
    }
    
    /// Load video from URL and prepare the live photo
    private func loadVideoWithVideoURL(_ videoURL: URL) {
        manager.loadVideoWithVideoURL(videoURL) { (livePhoto) in
            DispatchQueue.main.async {
                LoadingView.removeLoadingView()
                if let photo = livePhoto {
                    self.livePhotoView.livePhoto = photo
                    self.livePhotoView.startPlayback(with: .full)
                }
            }
        }
    }
}
