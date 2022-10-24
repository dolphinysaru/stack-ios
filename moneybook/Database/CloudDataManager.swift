//
//  CloudManager.swift
//  moneybook
//
//  Created by jedmin on 2022/10/24.
//

import Foundation
import CloudKit

class CloudDataManager {
    
    static let sharedInstance = CloudDataManager() // Singleton
    
    struct DocumentsDirectory {
        static let localDocumentsURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName)!
//        static let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
        static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    
    // Return the Document directory (Cloud OR Local)
    // To do in a background thread
    
    func getDocumentDiretoryURL() -> URL {
        if isCloudEnabled()  {
            return DocumentsDirectory.iCloudDocumentsURL!
        } else {
            return DocumentsDirectory.localDocumentsURL
        }
    }
    
    // Return true if iCloud is enabled
    
    func isCloudEnabled() -> Bool {
        if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
        else { return false }
    }
    
    // Delete All files at URL
    
    func deleteFilesInDirectory(url: URL?) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: url!.path)
        while let file = enumerator?.nextObject() as? String {
            
            do {
                try fileManager.removeItem(at: url!.appendingPathComponent(file))
                print("Files deleted")
            } catch let error as NSError {
                print("Failed deleting files : \(error)")
            }
        }
    }
    
    func createDirICloud() {
        do {
            let fileManager = FileManager.default
            try fileManager.createDirectory(at: DocumentsDirectory.iCloudDocumentsURL!, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
    }
    
    // Copy local files to iCloud
    // iCloud will be cleared before any operation
    // No data merging
    
    func copyFileToCloud() {
        if isCloudEnabled() {
            deleteFilesInDirectory(url: DocumentsDirectory.iCloudDocumentsURL!) // Clear all files in iCloud Doc Dir
            
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL.path)
            while let file = enumerator?.nextObject() as? String {
                
                do {
                    try fileManager.copyItem(at: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file), to: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))
                    print("Files deleted")
                } catch let error as NSError {
                    print("Failed deleting files : \(error)")
                }
            }
        }
    }
    
    // Copy iCloud files to local directory
    // Local dir will be cleared
    // No data merging
    
    func copyFileToLocal() {
        if isCloudEnabled() {
            deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL)
            
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
            while let file = enumerator?.nextObject() as? String {
                
                do {
                    try fileManager.copyItem(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file), to: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file))

                    print("Files deleted")
                } catch let error as NSError {
                    print("Failed deleting files : \(error)")
                }
            }
        }
    }
    
    func isExistCloudFile() -> Bool {
        let path = DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent("db.sqlite").path
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }
}
