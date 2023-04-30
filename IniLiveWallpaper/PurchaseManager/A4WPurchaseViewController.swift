//
//  A4WPurchaseViewController.swift
//  AnimatedStories
//
//  Created by Apps4World on 2/19/20.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import UIKit

// This class represents the in-app purchase controller
class A4WPurchaseViewController: UIViewController {
    
    @IBOutlet weak private var purchaseTitle: UILabel!
    @IBOutlet weak private var purchaseDescription: UILabel!
    @IBOutlet weak private var buyProductButton: UIButton!
    @IBOutlet weak private var legalDisclaimer: UILabel!
    @IBOutlet weak private var closeButton: UIButton!
    var didPurchaseProduct: ((_ success: Bool) -> Void)? = nil
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    /// Initial logic when this screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoundedCornerButtons()
        setupLabelsContent()
        let number = Int.random(in: 0...9)
        imgView.image = UIImage.init(named: "\(number).JPG")
    }
    
    /// Setup rounded corners for close and buy buttons
    private func setupRoundedCornerButtons() {
        closeButton.layer.cornerRadius = 12.5
        buyProductButton.layer.cornerRadius = 10
    }
    
    /// Setup content for all labels
    private func setupLabelsContent() {
        purchaseTitle.text = "Unlock PRO Version"
        purchaseDescription.text = "- Unlock all Wallpaper \n- Remove ads"
        legalDisclaimer.text = "∙ Payment will be charged to your iTunes Account at confirmation of purchase.\n∙ Subscriptions may be managed by the user by going to the user's Account Settings after purchase.\n∙ Any unused portions of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable."
        
        A4WPurchaseManager.productDetails{ (success) in
            self.priceLabel.text = "Join pro to unlock all the templates.\nkeep udateing new resource !\n\(success.priceLocale.currencySymbol! + success.price.description(withLocale: success.priceLocale)) / Year"
            
            print("price \(success.localizedDescription) \(success.price) \(success.priceLocale.currencySymbol!) \(success.price.description(withLocale: success.priceLocale))")
        }
        
    }
    
    /// Buy PRO Version
    @IBAction func buyPROVersion(_ sender: UIButton) {
        A4WPurchaseManager.buyProVersion { (success) in
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserdefultConfig.didPurchasePRO), object: nil)
                self.didPurchaseProduct?(success)
            }
        }
    }
    
    /// Restore purchases
    @IBAction func restorePurchase(_ sender: UIButton) {
        A4WPurchaseManager.restorePurchases { (success) in
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserdefultConfig.didPurchasePRO), object: nil)
                self.didPurchaseProduct?(success)
            }
        }
    }
    
    /// Open Terms of Use URL
    @IBAction func seeTermsOfUse(_ sender: UIButton) {
        UIApplication.shared.open(AppConfig.termsURL, options: [:], completionHandler: nil)
    }
    
    /// Open Privacy Policy URL
    @IBAction func seePrivacyPolicy(_ sender: UIButton) {
        UIApplication.shared.open(AppConfig.privacyURL, options: [:], completionHandler: nil)
    }
    
    /// Dismiss purchase screen
    @IBAction func closePurchaseScreen(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
