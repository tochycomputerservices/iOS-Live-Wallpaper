//
//  A4WPurchaseManager.swift
//  AnimatedStories
//
//  Created by Apps4World on 2/19/20.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import UIKit
import StoreKit

/// Aliases for completion blocks and product id
public typealias ProductID = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void
public typealias ProductPurchaseCompletionHandler = (_ success: Bool, _ productId: ProductID?) -> Void



/// IMPORTANT: Replace the proVersion identifier with the one from App Store connect
/// Also you must replace `com.a4w.Quiz` with your App's Bundle Identifier


/// Resource name for product id
public func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

// Main Purchase Manager class to handle in-app purchases
public class A4WPurchaseManager: NSObject {
    
    static let shared = A4WPurchaseManager(productIDs: InAppProducts.productIDs)
    private let productIDs: Set<ProductID>
    private var purchasedProductIDs: Set<ProductID>
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    private var productPurchaseCompletionHandler: ProductPurchaseCompletionHandler?
    private static var inAppProducts: [SKProduct]?
    var didPurchaseProduct: Bool = false
    
    public init(productIDs: Set<ProductID>) {
        self.productIDs = productIDs
        self.purchasedProductIDs = productIDs.filter { productID in
            let purchased = UserDefaults.standard.bool(forKey: productID)
            if purchased {
                print("Previously purchased: \(productID)")
                UserDefaults.standard.set(true,forKey: UserdefultConfig.isAdsFree)
            } else {
                print("Not purchased: \(productID)")
                UserDefaults.standard.set(false,forKey:UserdefultConfig.isAdsFree)
            }
            
            return purchased
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    /// Get the value from userDefaults to see if user purchased the pro version before
    var didPurchaseProVersion: Bool {
        return didPurchaseProduct || UserDefaults.standard.bool(forKey: UserdefultConfig.isAdsFree)
    }
    
    /// Initialize the purchase manager
    func initialize() {
        if didPurchaseProVersion {
            print("PRO Version has been purchased before")
        }
        InAppProducts.store.requestProducts { (success, products) in
            A4WPurchaseManager.inAppProducts = products
        }
        if(!isProductPurchased(InAppProducts.proVersion)){
            UserDefaults.standard.set(false,forKey: UserdefultConfig.isAdsFree)
        }
    }
    
    /// Static function to buy pro version
    static func buyProVersion(completion: @escaping (_ success: Bool) -> Void) {
        if let firstProduct = A4WPurchaseManager.inAppProducts?.first {
            A4WPurchaseManager.shared.buyProduct(firstProduct) { (didPurchase, _) in
                completion(didPurchase)
            }
        } else {
            //            completion(false)
        }
    }
    
    /// Static function to restore purchases
    static func restorePurchases(completion: @escaping (_ success: Bool) -> Void) {
        
        A4WPurchaseManager.shared.restorePurchases { (didRestore, _) in
            completion(didRestore)
        }
    }
    
    static func productDetails(completion: @escaping (_ success: SKProduct) -> Void) {
        
        //       A4WPurchaseManager.inAppProducts?.forEach({print($0.productIdentifier)})
        if let product1 = self.inAppProducts?.first(where: {$0.productIdentifier == InAppProducts.proVersion}) {
            //                            self.purchasingProduct1 = product1
            //                return \(product1.priceLocale.currencySymbol! + product1.price.description(withLocale: product1.priceLocale))
            
            completion(product1)
            //                            self.description1.text = "3 days free trial"
        }
        
    }
    
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
        (UIApplication.shared.delegate as? AppDelegate)?.window?.addSubview(mainView)
    }
    
    /// Static function to remove the loading/spinner view
    static func removeLoadingView() {
        (UIApplication.shared.delegate as? AppDelegate)?.window?.viewWithTag(1991)?.removeFromSuperview()
    }
}

// MARK: - StoreKit API
extension A4WPurchaseManager {
    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIDs)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct, _ completionHandler: @escaping ProductPurchaseCompletionHandler) {
        A4WPurchaseManager.showLoadingView()
        productPurchaseCompletionHandler = completionHandler
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productID: ProductID) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases(completionHandler: @escaping ProductPurchaseCompletionHandler) {
        A4WPurchaseManager.showLoadingView()
        productPurchaseCompletionHandler = completionHandler
        SKPaymentQueue.default().restoreCompletedTransactions()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            A4WPurchaseManager.removeLoadingView()
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension A4WPurchaseManager: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        guard !products.isEmpty else {
            print("Product list is empty...!")
            print("Did you configure the project and set up the IAP?")
            productsRequestCompletionHandler?(false, nil)
            return
        }
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        for p in products {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .currency
            currencyFormatter.locale = Locale.current
            print("Found product: \(p.priceLocale.currencySymbol!) \(p.productIdentifier) \(p.localizedTitle) \(String(describing: currencyFormatter.string(from: p.price)))")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver
extension A4WPurchaseManager: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
                
            case .failed:
                fail(transaction: transaction)
                UserDefaults.standard.set(false, forKey: UserdefultConfig.isAdsFree)
                
                break
            case .restored:
                restore(transaction: transaction)
                
                break
            case .deferred:
                UserDefaults.standard.set(false, forKey: UserdefultConfig.isAdsFree)
                
                break
            case .purchasing:
                break
                
            default: break
            }
        }
    }
    
    private func expirationDateFor(_ identifier : String) -> Date?{
        return UserDefaults.standard.object(forKey: identifier) as? Date
    }
    
    
    
    
    func compare(_ date: Date) {
        let comp = Date().compare(date)
        print("compare: \(comp == .orderedAscending)")
        if (comp == .orderedAscending) {
            self.complitePurchase()
        }
        
    }
    
    func complitePurchase() {
        UserDefaults.standard.set(true, forKey: "isBuyed")
        
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        productPurchaseCompleted(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        
        //        transaction.transactionDate?.addingTimeInterval()
        //        let compareDate = transaction.transactionDate?.compare(Date())
        
        if let date1 = transaction.transactionDate?.add(years: 0, months: 0, days: 0, hours: 0, minutes: 10, seconds: 0) {
            //          self.compare(date1)
            let comp = Date().compare(date1)
            print("compare: \(comp == .orderedAscending)")
            if (comp == .orderedAscending) {
//                self.complitePurchase()
                UserDefaults.standard.set(true, forKey: InAppProducts.proVersion)
            }
        }
        print("complete -- ")
        A4WPurchaseManager.removeLoadingView()
        
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier) \(productIdentifier.description)")
        productPurchaseCompleted(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        A4WPurchaseManager.removeLoadingView()
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        
        print("fail...\(transaction.error?.localizedDescription)")
        
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        productPurchaseCompletionHandler?(false, nil)
        SKPaymentQueue.default().finishTransaction(transaction)
        clearHandler()
        A4WPurchaseManager.removeLoadingView()
        UserDefaults.standard.set(false, forKey: UserdefultConfig.isAdsFree)
        
    }
    
    
    private func productPurchaseCompleted(identifier: ProductID?) {
        guard let identifier = identifier else { return }
        purchasedProductIDs.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        UserDefaults.standard.set(true, forKey: UserdefultConfig.isAdsFree)
        UserDefaults.standard.synchronize()
        didPurchaseProduct = true
        productPurchaseCompletionHandler?(true, identifier)
        clearHandler()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserdefultConfig.isAdsFree), object: nil)
        A4WPurchaseManager.removeLoadingView()
    }
    
    private func clearHandler() {
        productPurchaseCompletionHandler = nil
    }
}
