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
public typealias BDFetchTranslationsCompletionHandler = ([BDRealmTranslation]?, Error?) -> Void
public typealias BDSaveTranslationCompletionHandler = (Bool, Error?) -> Void
public typealias BDDeleteTranslationsCompletionHandler = (Bool, Error?) -> Void
public typealias BDAddTranslationToFavoritesCompletionHandler = (Bool, Error?) -> Void
public typealias BDRemoveTranslationFromFavoritesCompletionHandler = (Bool, Error?) -> Void

public class BantuDicoHistoryRealmStorage {
    
    public enum StoreType {
        case inMemory
        case persistent
    }
    
    private let operationQueue: OperationQueue
    
    public init(storeName: String, storeType: StoreType = .persistent) {
        
        var config = Realm.Configuration()
        if storeType == .inMemory {
            config.inMemoryIdentifier = storeName
        } else {
            config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(storeName).realm")
        }
        Realm.Configuration.defaultConfiguration = config
        
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
    }
}

//MARK: - Fetch translations

public extension BantuDicoHistoryRealmStorage {
    
    /// Fetch a translation result from the data base.
    ///
    /// - Parameters:
    ///   - word: the word to translate.
    ///   - language: the language of the word.
    ///   - translationLanguage: the language to which the word will be translated.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func fetchTranslation(word: String, language: String,translationLanguage: String,
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
    
    /// Fetche translations which word property begins with `beginning`
    ///
    /// - Parameters:
    ///   - beginning: the string that translation's word begins with.
    ///   - language: language of the translated word.
    ///   - translationLanguage: language of the translation.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func fetchTanslationsBeginningWith(_ beginning: String, language: String, translationLanguage: String, queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDFetchTranslationsCompletionHandler) {
        
        let predicate = NSPredicate(format: "word BEGINSWITH[c] %@ AND language == %@ AND translationLanguage == %@", beginning, language, translationLanguage)
        fetchRealmTranslations(predicate: predicate, completion: { realmTranslationRefs in
            
            let realm = try! Realm()
            guard realmTranslationRefs.count > 0 else {
                queue.async { completion(nil, nil) }
                return
            }
            
            let result = realmTranslationRefs.map({ realmRef -> BDRealmTranslation? in
                
                guard let realmRef = realm.resolve(realmRef) else {
                    return nil
                }
                return BDRealmTranslation(realmTranslation: realmRef)
                
            }).flatMap({ $0 }).sorted(by: { $0.word <= $1.word })
            
            queue.async { completion(result, nil) }
        })
    }
    
    /// Fetches all history.
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func fetchAllTranslations(queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDFetchTranslationsCompletionHandler) {
        operationQueue.addOperation {
            let realm = try! Realm()
            let result = Array(realm.objects(RealmTranslation.self)).map({ BDRealmTranslation(realmTranslation: $0) })
            queue.async { completion(result, nil) }
        }
    }
}

//MARK: - Save translation

extension BantuDicoHistoryRealmStorage {
    
    /// Saves a translation history or updates it if it already exists.
    ///
    /// - Parameters:
    ///   - word: the word to translate.
    ///   - language: the language of the word.
    ///   - translationLanguage: the language to which the word will be translated.
    ///   - queue: the queue on which the completion will be called.
    ///   - translations: the translations of the word.
    ///   - completion: closure called when task is finished.
    public func saveTranslation(word: String,
                                language: String,
                                translationLanguage: String,
                                translations: [String],
                                queue: DispatchQueue = DispatchQueue.main,
                                completion: @escaping BDSaveTranslationCompletionHandler) {
        createOrUpdateTranslationHistory(word: word, language: language, translationLanguage: translationLanguage, isFavorite: false, translations: translations, completion: { (success, error) in
            queue.async { completion(success, error) }
        })
    }
    
    /// Saves a translation or updates it if it already exists.
    ///
    /// - Parameters:
    ///   - translation: translation to save or update.
    ///   - completion: closure called when task is finished.
    public func saveTranslation(_ translation: BDRealmTranslation,
                                queue: DispatchQueue = DispatchQueue.main,
                                completion: @escaping BDSaveTranslationCompletionHandler) {
        saveTranslation(word: translation.word, language: translation.language, translationLanguage: translation.translationLanguage, translations: translation.translations, queue: queue, completion: completion)  
    }
}

//MARK: - Delete translation

extension BantuDicoHistoryRealmStorage {
    
    /// Delete specific translations.
    ///
    /// - Parameters:
    ///   - translations: translations to delete.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: losure called when task is finished.
    func deleteTranslations(_ translations: [BDRealmTranslation], queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDDeleteTranslationsCompletionHandler) {
        
        operationQueue.addOperation { [weak self] in
            
            let identifiers = translations.map({ $0.identifier })
            let predicate = NSPredicate(format: "identifier IN %@", identifiers)
            
            //fetch the references of realm objects to delete.
            self?.fetchRealmTranslations(predicate: predicate, completion: { realmTranslationRefs in
                
                let realm = try! Realm()
                
                //transform the real references to realm translations.
                let realmTranslations = realmTranslationRefs.map({ realm.resolve($0) }).flatMap({ $0 })
                
                guard translations.count > 0 else {
                    queue.async { completion(true, nil) }
                    return
                }
                
                do {
                    try realm.write {
                        realm.delete(realmTranslations)
                        queue.async { completion(true, nil) }
                    }
                } catch let error {
                    completion(false, error)
                }
            })
        }
    }
    
    /// Delete all translations including favorites.
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: losure called when task is finished.
    func deleteAllTranslations(queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDDeleteTranslationsCompletionHandler) {
        
        operationQueue.addOperation {
            
            let realm = try! Realm()
            
            do {
                try realm.write {
                    realm.deleteAll()
                    queue.async { completion(true, nil) }
                }
            } catch let error {
                queue.async { completion(false, error) }
            }
        }
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
    public func addTranslationToFavorites(_ translation: BDRealmTranslation,
                                   queue: DispatchQueue = DispatchQueue.main,
                                   completion: @escaping BDAddTranslationToFavoritesCompletionHandler) {
        operationQueue.addOperation { [weak self] in
            self?.addTranslationToFavorites(word: translation.word, language: translation.language, translationLanguage: translation.translationLanguage, translations: translation.translations, queue: queue, completion: completion)
        }
        
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
    public func addTranslationToFavorites(word: String, language: String,
                                   translationLanguage: String, translations: [String],
                                   queue: DispatchQueue = DispatchQueue.main,
                                   completion: @escaping BDAddTranslationToFavoritesCompletionHandler) {
        createOrUpdateTranslationHistory(word: word, language: language, translationLanguage: translationLanguage, isFavorite: true, translations: translations, completion: { (success, error) in
            queue.async { completion(success, error) }
        })
    }
    
    /// Remove a translation from favorites. If a translation is not favorite or does not exist then operation will finish with success.
    ///
    /// - Parameters:
    ///   - translation: translation to remove from favorites.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func removeTranslationFromFavorites(_ translation: BDRealmTranslation,
                                        queue: DispatchQueue = DispatchQueue.main,
                                        completion: @escaping BDRemoveTranslationFromFavoritesCompletionHandler) {
        let predicate = NSPredicate(format: "word == %@ AND language == %@ AND translationLanguage == %@ AND isFavorite == true", translation.word, translation.language, translation.translationLanguage)
        fetchRealmTranslations(predicate: predicate) { realmTranslationRefs in
            let realm = try! Realm()
            
            guard let realmTranslationRef = realmTranslationRefs.first else {
                queue.async { completion(true, nil) }
                return
            }
            
            guard let realmTranslation = realm.resolve(realmTranslationRef) else {
                queue.async { completion(false, nil) }
                return
            }
            
            do {
                try realm.write {
                    realmTranslation.isFavorite = false
                    queue.async { completion(true, nil) }
                }
            } catch let error {
                queue.async { completion(false, error) }
            }
        }
    }
}

//MARK: - Data base access

private extension BantuDicoHistoryRealmStorage {
    
    private typealias BDFetchRealmTranslationCompletionHandler = ([ThreadSafeReference<RealmTranslation>]) -> Void
    private typealias BDCreateOrUpdateCompletionHandler = (Bool, Error?) -> Void
    
    /// Fetches BDRealmTranslationResult object from data base.
    ///
    /// - Parameters:
    ///   - word: the translated word.
    ///   - language: the language of word.
    ///   - translationLanguage: the language to which the word is translated.
    ///   - completion: closure called when task is finished.
    private func fetchRealmTranslations(predicate: NSPredicate, completion: @escaping BDFetchRealmTranslationCompletionHandler) {
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
    private func createOrUpdateTranslationHistory(word: String, language: String,
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
