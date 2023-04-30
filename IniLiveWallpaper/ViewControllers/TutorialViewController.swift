//
//  TutorialViewController.swift
//  iLiveWallpapers
//
//  Created by Apps4World on 12/4/19.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import UIKit

// Tutorial screen to show users how to set the live wallpaper
class TutorialViewController: UIViewController {

    @IBOutlet weak private var instructionsLabel: UILabel!
    @IBOutlet weak private var dismissButton: UIButton!
    
    /// Initial logic when the screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsLabel.text = "1. Select the live photo in the Photos app\n\n2. Use as wallpaper\n\n3. Make sure the 'Live' option is selected"
        dismissButton.layer.cornerRadius = 10
        dismissButton.layer.borderColor = UIColor.white.cgColor
        dismissButton.layer.borderWidth = 1.5
    }

    /// Dismiss tutorial screen
    @IBAction private func dismissIntructionsController(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
