//
//  RemoteConfig.swift
//  QRReader
//
//  Created by jedmin on 2021/12/29.
//  Copyright © 2021 mck. All rights reserved.
//

import Foundation
import Firebase

class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    private var remoteConfig: RemoteConfig!
    var enabledInterstitial = false
    
    private func setupRemoteConfig() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }
    
    func fetch() {
        setupRemoteConfig()
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(1)) { (status, error) -> Void in
            guard status == .success else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
                return
            }
            
            print("Config fetched!")
            self.remoteConfig.activate { [weak self] (success, error) in
                guard let self = self else { return }
                let enabled = self.remoteConfig.configValue(forKey: "enabled_interstitial").dataValue
                guard let result = try? JSONDecoder().decode(Bool.self, from: enabled) else { return }
                print("Config fetched! \(result)")
                self.enabledInterstitial = result
            }
        }
    }
    
    func fetchRemoteConfig(currentAppId: String, completion: (([FeaturedApp]) -> Void)?) {
        remoteConfig.fetch(withExpirationDuration: TimeInterval(1)) { (status, error) -> Void in
            guard status == .success else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
                return
            }
            
            print("Config fetched!")
            self.remoteConfig.activate { (success, error) in
                let featured = self.remoteConfig.configValue(forKey: "featured").dataValue
                guard let result = try? JSONDecoder().decode(Featured.self, from: featured) else { return }
                print("result \(result)")
                let apps = result.apps.filter {
                    if $0.appid == currentAppId {
                        return false
                    } else {
                        if let allows = $0.allowLocalized {
                            let currentCode = Locale.current.languageCode ?? ""
                            return allows.contains(currentCode)
                        }
                        
                        return true
                    }
                }
                
                completion?(apps)
            }
        }
    }
}

struct Localized: Codable {
    let ko: String?
    let en: String?
    let ja: String?
    let fr: String?
    let it: String?
    let de: String?
    let es: String?
    
    var localiedString: String? {
        let code = Locale.current.languageCode ?? "en"
        if code == "en" {
            return en
        } else if code == "ko" {
            return ko ?? en
        } else if code == "ja" {
            return ja ?? en
        } else if code == "fr" {
            return fr ?? en
        } else if code == "it" {
            return it ?? en
        } else if code == "de" {
            return de ?? en
        } else if code == "es" {
            return es ?? en
        } else {
            return en
        }
    }
}

struct FeaturedApp: Codable {
    let appname: Localized
    let description: Localized
    let icon: String
    let appid: String
    let allowLocalized: [String]?
}

struct Featured: Codable {
    let apps: [FeaturedApp]
}
