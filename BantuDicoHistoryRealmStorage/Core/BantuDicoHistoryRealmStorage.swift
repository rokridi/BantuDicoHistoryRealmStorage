//
//  BantuDicoHistoryRealmStorage.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

public typealias BDFetchTranslationCompletionHandler = (BDRealmTranslation?, Error?) -> Void
public typealias BDFetchAllTranslationsCompletionHandler = ([BDRealmTranslation]?, Error?) -> Void
public typealias BDSaveTranslationCompletionHandler = (Bool, Error?) -> Void
public typealias BDAddTranslationToFavoritesCompletionHandler = (Bool, Error?) -> Void
public typealias BDRemoveTranslationFromFavoritesCompletionHandler = (Bool, Error?) -> Void
public typealias BDFetchFavoritesCompletionHandler = ([BDRealmTranslation]?) -> Void
private typealias BDFetchRealmTranslationCompletionHandler = ([ThreadSafeReference<RealmTranslation>]) -> Void
private typealias BDCreateOrUpdateCompletionHandler = (Bool, Error?) -> Void

public class BantuDicoHistoryRealmStorage {
    
    public enum StoreType {
        case inMemory
        case persistent
    }
    
    private let operationQueue: OperationQueue
    
    public init(storeName: String, storeType: StoreType = .persistent) {
        
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
    ///   - word: the word to translate.
    ///   - language: the language of the word.
    ///   - translationLanguage: the language to which the word will be translated.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    func fetchTranslation(word: String, language: String,translationLanguage: String,
                          queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDFetchTranslationCompletionHandler) {
        
        let predicate = NSPredicate(format: "word == %@ AND language == %@ AND translationLanguage == %@", word, language, translationLanguage)
        fetchRealmTranslations(predicate: predicate, completion: { realmTranslationRefs in
            
            let realm = try! Realm()
            guard let realmTranslationRef = realmTranslationRefs.first, let realmTranslation = realm.resolve(realmTranslationRef) else {
                queue.async { completion(nil, nil) }
                return
            }
            queue.async { completion(BDRealmTranslation(realmTranslation: realmTranslation), nil) }
        })
    }
    
    /// Fetches all history.
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    func fetchAllTranslations(queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDFetchAllTranslationsCompletionHandler) {
        operationQueue.addOperation {
            let realm = try! Realm()
            let result = Array(realm.objects(RealmTranslation.self)).map({ BDRealmTranslation(realmTranslation: $0) })
            queue.async {
                completion(result, nil)
            }
        }
    }
    
    /// Saves a translation history or updates it if it already exists.
    ///
    /// - Parameters:
    ///   - word: the word to translate.
    ///   - language: the language of the word.
    ///   - translationLanguage: the language to which the word will be translated.
    ///   - queue: the queue on which the completion will be called.
    ///   - translations: the translations of the word.
    ///   - completion: closure called when task is finished.
    func saveTranslation(word: String,
                         language: String,
                         translationLanguage: String,
                         translations: [String],
                         queue: DispatchQueue = DispatchQueue.main,
                         completion: @escaping BDSaveTranslationCompletionHandler) {
        
        self.createOrUpdateTranslationHistory(word: word, language: language, translationLanguage: translationLanguage, isFavorite: false, translations: translations, completion: { (success, error) in
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
    func saveTranslation(_ translation: BDRealmTranslation,
                         queue: DispatchQueue = DispatchQueue.main,
                         completion: @escaping BDSaveTranslationCompletionHandler) {
        self.saveTranslation(word: translation.word, language: translation.language, translationLanguage: translation.translationLanguage, translations: translation.translations, queue: queue, completion: completion)
    }
}

//MARK: - Favorites

public extension BantuDicoHistoryRealmStorage {
    
    /// Add translation to favorites and saves it to history.
    ///
    /// - Parameters:
    ///   - translation: translation to add or remove from favorites.
    ///   - isFavorite: if true then translation will be added to favories. If false then translation will be removed from favorites.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    func addTranslationToFavorites(_ translation: BDRealmTranslation,
                                   queue: DispatchQueue = DispatchQueue.main,
                                   completion: @escaping BDAddTranslationToFavoritesCompletionHandler) {
        addTranslationToFavorites(word: translation.word, language: translation.language, translationLanguage: translation.translationLanguage, translations: translation.translations, queue: queue, completion: completion)
    }
    
    /// Add translation from favorites and saves it to history.
    ///
    /// - Parameters:
    ///   - word: the word to translate.
    ///   - language: the language of the word.
    ///   - translationLanguage: the language to which the word is translated.
    ///   - queue: the queue on which the completion will be called.
    ///   - translations: the translations of the word.
    ///   - completion: closure called when task is finished.
    func addTranslationToFavorites(word: String, language: String,
                                   translationLanguage: String, translations: [String],
                                   queue: DispatchQueue = DispatchQueue.main,
                                   completion: @escaping BDAddTranslationToFavoritesCompletionHandler) {
        createOrUpdateTranslationHistory(word: word, language: language, translationLanguage: translationLanguage, isFavorite: true, translations: translations, completion: { (success, error) in
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
    func removeTranslationFromFavorites(_ translation: BDRealmTranslation,
                                        queue: DispatchQueue = DispatchQueue.main,
                                        completion: @escaping BDRemoveTranslationFromFavoritesCompletionHandler) {
        let predicate = NSPredicate(format: "word == %@ AND language == %@ AND translationLanguage == %@ AND isFavorite == true", translation.word, translation.language, translation.translationLanguage)
        fetchRealmTranslations(predicate: predicate) { realmTranslationRefs in
            let realm = try! Realm()
            
            guard let realmTranslationRef = realmTranslationRefs.first else {
                completion(true, nil)
                return
            }
            
            guard let realmTranslation = realm.resolve(realmTranslationRef) else {
                queue.async {
                    completion(false, nil)
                }
                return
            }
            
            do {
                try realm.write {
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
    ///   - word: the translated word.
    ///   - language: the language of word.
    ///   - translationLanguage: the language to which the word is translated.
    ///   - completion: closure called when task is finished.
    func fetchRealmTranslations(predicate: NSPredicate, completion: @escaping BDFetchRealmTranslationCompletionHandler) {
        operationQueue.addOperation {
            let realm = try! Realm()
            let result = realm.objects(RealmTranslation.self).filter(predicate)
            completion(result.map({ ThreadSafeReference(to: $0) }))
        }
    }
    
    /// Insert a new translation in data base or update the existing one.
    ///
    /// - Parameters:
    ///   - word: the translated word.
    ///   - language: the language of word.
    ///   - translationLanguage: the language to which the word is translated.
    ///   - translations: the translations of word.
    ///   - completion: closure called when task is finished.
    func createOrUpdateTranslationHistory(word: String, language: String,
                                          translationLanguage: String, isFavorite: Bool,
                                          translations: [String],
                                          completion: @escaping BDCreateOrUpdateCompletionHandler) {
        operationQueue.addOperation {
            let realm = try! Realm()
            do {
                try realm.write {
                    let translation = RealmTranslation(word: word, language: language, translationLanguage: translationLanguage, isFavorite: isFavorite, translations: translations)
                    realm.add(translation, update: true)
                    completion(true, nil)
                }
            } catch let error {
                completion(false, error)
            }
        }
    }
}
