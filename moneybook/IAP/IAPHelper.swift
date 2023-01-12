//
//  IAPHelper.swift
//  gifviewer
//
//  Created by jedmin on 2021/12/19.
//

import Foundation
import StoreKit
import TPInAppReceipt

public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void
public typealias ProductIdentifier = String
public typealias ProductWithExpireDate = [ProductIdentifier: Date]
public typealias ValidateHandler = (_ statusCode: Int?, _ products: ProductWithExpireDate?, _ json: [String: Any]?) -> ()

public enum ReceiptStatus: Int {
    case noRecipt = -999
    case valid = 0
    case testReceipt = 21007
}

extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
}

class IAPHelper: NSObject  {
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    private var buyResultCompletion: ((Bool, String?) -> Void)?
    
    public init(productIds: Set<String>) {
        productIdentifiers = productIds
        
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        
        super.init()
        SKPaymentQueue.default().add(self)
        
        InAppReceipt.refresh { (error) in
            if let err = error {
                print(err)
            } else {
                let receipt = try! InAppReceipt.localReceipt()
                if let _ = receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: InAppProducts.product, forDate: Date()) {
                    UserDefaults.standard.set(true, forKey: InAppProducts.product)
                    self.purchasedProductIdentifiers.insert(InAppProducts.product)
                } else {
                    UserDefaults.standard.set(false, forKey: InAppProducts.product)
                    if let index = self.purchasedProductIdentifiers.firstIndex(of: InAppProducts.product) {
                        self.purchasedProductIdentifiers.remove(at: index)
                    }
                }
            }
        }
    }
    
    // App Store Connect에서 등록한 인앱결제 상품들을 가져올 때
    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self    // 추후 delegate 추가
        productsRequest!.start()
    }
    
    // 인앱결제 상품을 구입할 때
    public func buyProduct(_ product: SKProduct, completion: @escaping (Bool, String?) -> Void) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        buyResultCompletion = completion
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    // 구입 내역을 복원할 때
    public func restorePurchases(completion: @escaping (Bool, String?) -> Void) {
        SKPaymentQueue.default().restoreCompletedTransactions()
        buyResultCompletion = completion
    }
    
    
}

extension IAPHelper: SKProductsRequestDelegate {
    // 인앱결제 상품 리스트를 가져온다
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    // 상품 리스트 가져오기 실패할 경우
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

extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished \(queue.transactions)")
        
        if queue.transactions.isEmpty {
            buyResultCompletion?(false, "fail_restore_not_purchased".localized())
        } else {
            buyResultCompletion?(true, "success_restore_remove_ads_message".localized())
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("restoreCompletedTransactionsFailedWithError")
        buyResultCompletion?(false, error.localizedDescription)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred, .purchasing:
                break
            @unknown default:
                fatalError()
            }
        }
    }
    
    // 구입 성공
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        buyResultCompletion?(true, "success_remove_ads_message".localized())
    }
    
    // 복원 성공
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        buyResultCompletion?(true, "success_restore_remove_ads_message".localized())
    }
    
    // 구매 실패
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        
        var message = "unknown_iap_error".localized()
        if let transactionError = transaction.error as NSError?,
           let localizedDescription = transaction.error?.localizedDescription,
           transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
            message = localizedDescription
            
            if transactionError.code != SKError.paymentCancelled.rawValue {
                buyResultCompletion?(false, message)
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // 구매한 인앱 상품 키를 UserDefaults로 로컬에 저장
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
    }
    
    func purchasedProduct(identifier: String) {
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
    }
    
    func expiredProduct(identifier: String) {
        purchasedProductIdentifiers.removeAll()
        UserDefaults.standard.set(false, forKey: identifier)
    }
    
    public func validateReceipt(_ password: String? = nil, handler: @escaping ValidateHandler) {
        validateReceiptInternal(true, password: password) { (statusCode, products, json) in
            
            if let statusCode = statusCode , statusCode == ReceiptStatus.testReceipt.rawValue {
                self.validateReceiptInternal(false, password: password, handler: { (statusCode, products, json) in
                    handler(statusCode, products, json)
                })
                
            } else {
                handler(statusCode, products, json)
            }
        }
    }
    
    fileprivate func validateReceiptInternal(_ isProduction: Bool, password: String?, handler: @escaping ValidateHandler) {
        
        let serverURL = isProduction
        ? "https://buy.itunes.apple.com/verifyReceipt"
        : "https://sandbox.itunes.apple.com/verifyReceipt"
        
        let appStoreReceiptURL = Bundle.main.appStoreReceiptURL
        guard let receiptData = receiptData(appStoreReceiptURL, password: password), let url = URL(string: serverURL) else {
            handler(ReceiptStatus.noRecipt.rawValue, nil, nil)
            return
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = receiptData
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard let data = data, error == nil else {
                handler(nil, nil, nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any]
                
                let statusCode = json?["status"] as? Int
                let products = self.parseValidateResultJSON(json)
                handler(statusCode, products, json)
                
            } catch {
                handler(nil, nil, nil)
            }
        }
        task.resume()
    }
    
    internal func parseValidateResultJSON(_ json: [String: Any]?) -> ProductWithExpireDate? {
        
        var products = ProductWithExpireDate()
        var canceledProducts = ProductWithExpireDate()
        var productDateDict = [String: [ProductDateHelper]]()
        let dateOf5000 = Date(timeIntervalSince1970: 95617584000) // 5000-01-01
        
        var totalInAppPurchaseList = [[String: Any]]()
        if let receipt = json?["receipt"] as? [String: Any],
           let inAppPurchaseList = receipt["in_app"] as? [[String: Any]] {
            totalInAppPurchaseList += inAppPurchaseList
        }
        if let inAppPurchaseList = json?["latest_receipt_info"] as? [[String: Any]] {
            totalInAppPurchaseList += inAppPurchaseList
        }
        
        for inAppPurchase in totalInAppPurchaseList {
            if let productID = inAppPurchase["product_id"] as? String,
               let purchaseDate = parseDate(inAppPurchase["purchase_date_ms"] as? String) {
                
                let expiresDate = parseDate(inAppPurchase["expires_date_ms"] as? String)
                let cancellationDate = parseDate(inAppPurchase["cancellation_date_ms"] as? String)
                
                let productDateHelper = ProductDateHelper(purchaseDate: purchaseDate, expiresDate: expiresDate, canceledDate: cancellationDate)
                if productDateDict[productID] == nil {
                    productDateDict[productID] = [productDateHelper]
                } else {
                    productDateDict[productID]?.append(productDateHelper)
                }
                
                if let cancellationDate = cancellationDate {
                    if let lastCanceledDate = canceledProducts[productID] {
                        if lastCanceledDate.timeIntervalSince1970 < cancellationDate.timeIntervalSince1970 {
                            canceledProducts[productID] = cancellationDate
                        }
                    } else {
                        canceledProducts[productID] = cancellationDate
                    }
                }
            }
        }
        
        for (productID, productDateHelpers) in productDateDict {
            var date = Date(timeIntervalSince1970: 0)
            let lastCanceledDate = canceledProducts[productID]
            
            for productDateHelper in productDateHelpers {
                let validDate = productDateHelper.getValidDate(lastCanceledDate: lastCanceledDate, unlimitedDate: dateOf5000)
                if date.timeIntervalSince1970 < validDate.timeIntervalSince1970 {
                    date = validDate
                }
            }
            
            products[productID] = date
        }
        
        return products.isEmpty ? nil : products
    }
    
    private func parseDate(_ str: String?) -> Date? {
        guard let str = str, let msTimeInterval = TimeInterval(str) else {
            return nil
        }
        
        return Date(timeIntervalSince1970: msTimeInterval / 1000)
    }
    
    private func receiptData(_ appStoreReceiptURL: URL?, password: String?) -> Data? {
        guard let receiptURL = appStoreReceiptURL, let receipt = try? Data(contentsOf: receiptURL) else {
            return nil
        }
        
        do {
            let receiptData = receipt.base64EncodedString()
            var requestContents = ["receipt-data": receiptData]
            if let password = password {
                requestContents["password"] = password
            }
            let requestData = try JSONSerialization.data(withJSONObject: requestContents, options: [])
            return requestData
            
        } catch let error {
            NSLog("\(error)")
        }
        
        return nil
    }
}

extension IAPHelper {
    
    // 구매이력 영수증 가져오기 - 검증용
    public func getReceiptData() -> String? {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                return receiptString
            }
            catch {
                print("Couldn't read receipt data with error: " + error.localizedDescription)
                return nil
            }
        }
        return nil
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? "\(price)"
    }
}

internal struct ProductDateHelper {
    var purchaseDate = Date(timeIntervalSince1970: 0)
    var expiresDate: Date? = nil
    var canceledDate: Date? = nil
    
    func getValidDate(lastCanceledDate: Date?, unlimitedDate: Date) -> Date {
        if let lastCanceledDate = lastCanceledDate {
            return (purchaseDate.timeIntervalSince1970 > lastCanceledDate.timeIntervalSince1970)
            ? (expiresDate ?? unlimitedDate)
            : lastCanceledDate
        }
        
        if let canceledDate = canceledDate {
            return canceledDate
        } else if let expiresDate = expiresDate {
            return expiresDate
        } else {
            return unlimitedDate
        }
    }
}
