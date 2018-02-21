//
//  BantuDicoHistoryRealmStorage.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

public typealias BDFetchTranslationCompletionHandler = (BDTranslationHistory?, Error?) -> Void
public typealias BDFetchAllTranslationsCompletionHandler = ([BDTranslationHistory]?, Error?) -> Void
public typealias BDSaveTranslationCompletionHandler = (Bool, Error?) -> Void
public typealias BDAddTranslationToFavoritesCompletionHandler = (Bool, Error?) -> Void
public typealias BDRemoveTranslationFromFavoritesCompletionHandler = (Bool, Error?) -> Void
public typealias BDFetchFavoritesCompletionHandler = ([BDTranslationHistory]?) -> Void
private typealias BDFetchRealmTranslationCompletionHandler = ([ThreadSafeReference<BDRealmTranslationHistory>]) -> Void
private typealias BDCreateOrUpdateCompletionHandler = (Bool, Error?) -> Void

public class BantuDicoHistoryRealmStorage {
    
    public enum StoreType {
        case inMemory
        case persistent
    }
    
    private let operationQueue: OperationQueue
    
    init(storeName: String, storeType: StoreType = .persistent) {
        
        var config = Realm.Configuration()
        if storeType == .inMemory {
            config.inMemoryIdentifier = "BantuDicoHistoryRealmInMemoryStorage"
        } else {
            config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(storeName).realm")
        }
        Realm.Configuration.defaultConfiguration = config
        
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
    }
}

//MARK: - API

public extension BantuDicoHistoryRealmStorage {
    
    /// Fetch a translation result from the data base.
    ///
    /// - Parameters:
    ///   - sourceWord: the word to translate.
    ///   - sourceLanguage: the language of the sourceWord.
    ///   - destinationLanguage: the language to which the sourceWord will be translated.
    ///   - queue: the queue on which the compleetion will be called.
    ///   - completion: closure called when task is finished.
    func fetchTranslation(sourceWord: String,
                                sourceLanguage: String,
                                destinationLanguage: String,
                                queue: DispatchQueue = DispatchQueue.main,
                                completion: @escaping BDFetchTranslationCompletionHandler) {
        
        let predicate = NSPredicate(format: "sourceWord == %@ AND sourceLanguage == %@ AND destinationLanguage == %@", sourceWord, sourceLanguage, destinationLanguage)
        fetchRealmTranslations(predicate: predicate, completion: { realmTranslationRefs in
            
            let realm = try! Realm()
            guard realmTranslationRefs.count > 0, let realmTranslation = realm.resolve(realmTranslationRefs.first!) else {
                queue.async { completion(nil, nil) }
                return
            }
            queue.async { completion(BDTranslationHistory(realmTranslationResult: realmTranslation), nil) }
        })
    }
    
    func fetchAllTranslations(queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDFetchAllTranslationsCompletionHandler) {
        operationQueue.addOperation {
            let realm = try! Realm()
            let result = Array(realm.objects(BDRealmTranslationHistory.self)).map({ BDTranslationHistory(realmTranslationResult: $0) })
            queue.async {
                completion(result, nil)
            }
        }
    }
    
    /// Saves a translation history or updates it if it already exists.
    ///
    /// - Parameters:
    ///   - sourceWord: the word to translate.
    ///   - sourceLanguage: the language of the sourceWord.
    ///   - destinationLanguage: the language to which the sourceWord will be translated.
    ///   - queue: the queue on which the completion will be called.
    ///   - translations: the translations of the sourceWord.
    ///   - completion: closure called when task is finished.
    func saveTranslation(sourceWord: String,
                         sourceLanguage: String,
                         destinationLanguage: String,
                         translations: [String],
                         queue: DispatchQueue = DispatchQueue.main,
                         completion: @escaping BDSaveTranslationCompletionHandler) {
        
        self.createOrUpdateTranslationHistory(sourceWord: sourceWord, sourceLanguage: sourceLanguage, destinationLanguage: destinationLanguage, isFavorite: false, translations: translations, completion: { (success, error) in
            queue.async {
                completion(success, error)
            }
        })
    }
    
    /// Saves a translation or updates it if it already exists.
    ///
    /// - Parameters:
    ///   - translation: translation to save or update.
    ///   - completion: closure called when task is finished.
    func saveTranslation(_ translation: BDTranslationHistory,
                         queue: DispatchQueue = DispatchQueue.main,
                         completion: @escaping BDSaveTranslationCompletionHandler) {
        self.saveTranslation(sourceWord: translation.sourceWord, sourceLanguage: translation.sourceLanguage, destinationLanguage: translation.destinationLanguage, translations: translation.translations, queue: queue, completion: completion)
    }
}

//MARK: - Favorites

public extension BantuDicoHistoryRealmStorage {
    
    /// Fetch favorite translations
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    func fetchFavoriteTranslations(queue: DispatchQueue = DispatchQueue.main,
                                   completion: @escaping BDFetchFavoritesCompletionHandler) {
        
        let predicate = NSPredicate(format: "isFavorite == true")
        self.fetchRealmTranslations(predicate: predicate, completion: { realmTranslationRefs in
            let realm = try! Realm()
            let result = realmTranslationRefs.map({ BDTranslationHistory(realmTranslationResult: realm.resolve($0)!) })
            queue.async {
                completion(result)
            }
        })
    }
    
    /// Add or remove a translation from favorites.
    ///
    /// - Parameters:
    ///   - translation: translation to add or remove from favorites.
    ///   - isFavorite: if true then translation will be added to favories. If false then translation will be removed from favorites.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    func addTranslationToFavorites(_ translation: BDTranslationHistory,
                                   queue: DispatchQueue = DispatchQueue.main,
                                   completion: @escaping BDAddTranslationToFavoritesCompletionHandler) {
        self.createOrUpdateTranslationHistory(sourceWord: translation.sourceWord, sourceLanguage: translation.sourceLanguage, destinationLanguage: translation.destinationLanguage, isFavorite: true, translations: translation.translations, completion: { (success, error) in
            queue.async {
                completion(success, error)
            }
        })
    }
    
    /// Remove a translation from favorites. If a translation is not favorite or does not exist then operation will finish with success.
    ///
    /// - Parameters:
    ///   - translation: translation to remove from favorites.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    func removeTranslationFromFavorites(_ translation: BDTranslationHistory,
                                        queue: DispatchQueue = DispatchQueue.main,
                                        completion: @escaping BDRemoveTranslationFromFavoritesCompletionHandler) {
        let predicate = NSPredicate(format: "sourceWord == %@ AND sourceLanguage == %@ AND destinationLanguage == %@ AND isFavorite == true", translation.sourceWord, translation.sourceLanguage, translation.destinationLanguage)
        fetchRealmTranslations(predicate: predicate) { realmTranslationRefs in
            let realm = try! Realm()
            
            guard let realmTranslationRef = realmTranslationRefs.first else {
                completion(true, nil)
                return
            }
            
            do {
                try realm.write {
                    guard let realmTranslation = realm.resolve(realmTranslationRef) else {
                        queue.async {
                            completion(false, nil)
                        }
                        return
                    }
                    realmTranslation.isFavorite = false
                    queue.async {
                        completion(true, nil)
                    }
                }
            } catch let error {
                completion(false, error)
            }
        }
    }
}

//MARK: - Data base access

private extension BantuDicoHistoryRealmStorage {
    
    /// Fetches BDRealmTranslationResult object from data base.
    ///
    /// - Parameters:
    ///   - sourceWord: the translated word.
    ///   - sourceLanguage: the language of sourceWord.
    ///   - destinationLanguage: the language to which the sourceWord is translated.
    ///   - completion: closure called when task is finished.
    func fetchRealmTranslations(predicate: NSPredicate, completion: @escaping BDFetchRealmTranslationCompletionHandler) {
        operationQueue.addOperation {
            let realm = try! Realm()
            let result = realm.objects(BDRealmTranslationHistory.self).filter(predicate)
            completion(result.map({ ThreadSafeReference(to: $0) }))
        }
    }
    
    /// Insert a new translation in data base or update the existing one.
    ///
    /// - Parameters:
    ///   - sourceWord: the translated word.
    ///   - sourceLanguage: the language of sourceWord.
    ///   - destinationLanguage: the language to which the sourceWord is translated.
    ///   - translations: the translations of sourceWord.
    ///   - completion: closure called when task is finished.
    func createOrUpdateTranslationHistory(sourceWord: String, sourceLanguage: String,
                                          destinationLanguage: String, isFavorite: Bool,
                                          translations: [String],
                                          completion: @escaping BDCreateOrUpdateCompletionHandler) {
        operationQueue.addOperation {
            let realm = try! Realm()
            do {
                try realm.write {
                    let translation = BDRealmTranslationHistory(sourceWord: sourceWord, sourceLanguage: sourceLanguage, destinationLanguage: destinationLanguage, isFavorite: isFavorite, translations: translations)
                    realm.add(translation, update: true)
                    completion(true, nil)
                }
            } catch let error {
                completion(false, error)
            }
        }
    }
}
