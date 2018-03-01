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
public typealias BDSaveTranslationCompletionHandler = (Bool, BDRealmTranslation?, Error?) -> Void
public typealias BDDeleteTranslationsCompletionHandler = (Bool, Error?) -> Void
public typealias BDAddTranslationToFavoritesCompletionHandler = (Bool, Error?) -> Void
public typealias BDRemoveTranslationFromFavoritesCompletionHandler = (Bool, Error?) -> Void

/// Handles translations persisted Realm in data base.
public class BantuDicoHistoryRealmStorage {
    
    /// Type of the store.
    ///
    /// - inMemory: Translations will be persisted only during application lifetime.
    /// - persistent: Tanslations will be persisted between application laaunches.
    public enum StoreType {
        case inMemory
        case persistent
    }
    
    private let dispatchQueue = DispatchQueue(label: "com.BDRealmStorage.queue")
    
    /// Creates an instance of BantuDicoHistoryRealmStorage.
    ///
    /// - Parameters:
    ///   - storeName: name of the data base. Default value is 'BantuDicoHistoryRealmStorage'
    ///   - storeType: type of the store (in memory or persistent). Default value is 'persistent'
    public init(storeName: String = "BantuDicoHistoryRealmStorage", storeType: StoreType = .persistent) throws {
        
        guard storeName.isValidFileName() else {
            throw BDRealmStorageError.dataBaseCreationFailed(reason: .invalidStoreName(storeName))
        }
        var config = Realm.Configuration()
        if storeType == .inMemory {
            config.inMemoryIdentifier = storeName
        } else {
            config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(storeName).realm")
        }
        Realm.Configuration.defaultConfiguration = config
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
    public func translation(word: String, language: String, translationLanguage: String,
                            queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDFetchTranslationCompletionHandler) {
        
        dispatchQueue.async {
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "word == %@ AND language == %@ AND translationLanguage == %@", word, language, translationLanguage)
            guard let realmTranslation = self.realmTranslation(predicate: predicate, realm: realm) else {
                queue.async { completion(nil, nil) }
                return
            }
            
            queue.async { completion(try! BDRealmTranslation(realmTranslation: realmTranslation), nil) }
        }
    }
    
    /// Fetche translations which word property begins with `beginning`. Translations will be sorted by 'word' ascending.
    ///
    /// - Parameters:
    ///   - beginning: the string that translation's word begins with.
    ///   - language: language of the translated word.
    ///   - translationLanguage: language of the translation.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func tanslationsBeginningWith(_ beginning: String, language: String, translationLanguage: String, queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDFetchTranslationsCompletionHandler) {
        dispatchQueue.async {
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "word BEGINSWITH[c] %@ AND language == %@ AND translationLanguage == %@", beginning, language, translationLanguage)
            
            guard let realmTranslations = self.realmTranslations(predicate: predicate, realm: realm) else {
                queue.async { completion(nil, nil) }
                return
            }
            
            let result = realmTranslations.map({ try! BDRealmTranslation(realmTranslation: $0) }).sorted(by: { $0.word <= $1.word })
            
            queue.async { completion(result, nil) }
        }
    }
    
    /// Fetch all translations including favorites.
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func allTranslations(queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDFetchTranslationsCompletionHandler) {
        dispatchQueue.async {
            let realm = try! Realm()
            let result = Array(realm.objects(RealmTranslation.self)).map({ try! BDRealmTranslation(realmTranslation: $0) })
            queue.async { completion(result, nil) }
        }
    }
    
    /// Fetches all favorites.
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func allFavorites(queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDFetchTranslationsCompletionHandler) {
        dispatchQueue.async {
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "isFavorite == true")
            
            guard let realmTranslations = self.realmTranslations(predicate: predicate, realm: realm) else {
                queue.async { completion(nil, nil) }
                return
            }
            
            let favorites = realmTranslations.map({ try! BDRealmTranslation(realmTranslation: $0) }).sorted(by: { $0.word <= $1.word })
            
            queue.async { completion(favorites, nil) }
        }
    }
}

//MARK: - Save translation

extension BantuDicoHistoryRealmStorage {
    
    /// Saves a translation or updates it if already exists.
    ///
    /// - Parameters:
    ///   - translation: translation to save or update.
    ///   - completion: closure called when task is finished.
    public func saveTranslation(_ translation: BDRealmTranslation,
                                queue: DispatchQueue = DispatchQueue.main,
                                completion: @escaping BDSaveTranslationCompletionHandler) {
        createOrUpdateTranslation(translation) { success, translation, error in
            queue.async { completion(success, translation, error) }
        }
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
        
        dispatchQueue.async { [weak self] in
            
            let identifiers = translations.map({ $0.identifier })
            let predicate = NSPredicate(format: "identifier IN %@", identifiers)
            
            let realm = try! Realm()
            
            guard let realmTranslations = self?.realmTranslations(predicate: predicate, realm: realm), realmTranslations.count > 0 else {
                queue.async { completion(true, nil) }
                return
            }
            
            do {
                try realm.write {
                    
                    let translationsToDelete = List<RealmTranslation>()
                    translationsToDelete.append(objectsIn: realmTranslations)
                    realm.delete(translationsToDelete)
                    queue.async { completion(true, nil) }
                }
            } catch let error {
                completion(false, BDRealmStorageError.dataBaseOperationFailed(reason: .realmWriteFailed(error)))
            }
        }
    }
    
    /// Delete all translations including favorites.
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: losure called when task is finished.
    func deleteAllTranslations(queue: DispatchQueue = DispatchQueue.main, completion: @escaping BDDeleteTranslationsCompletionHandler) {
        
        dispatchQueue.async {
            let realm = try! Realm()
            do {
                try realm.write {
                    realm.deleteAll()
                    queue.async { completion(true, nil) }
                }
            } catch let error {
                queue.async { completion(false, BDRealmStorageError.dataBaseOperationFailed(reason: .realmWriteFailed(error))) }
            }
        }
    }
}

//MARK: - Data base access

private extension BantuDicoHistoryRealmStorage {
    
    private typealias BDCreateOrUpdateCompletionHandler = (Bool, BDRealmTranslation?, Error?) -> Void
    
    /// Fetches BDRealmTranslationResult object from data base.
    ///
    /// - Parameters:
    ///   - word: the translated word.
    ///   - language: the language of word.
    ///   - translationLanguage: the language to which the word is translated.
    ///   - completion: closure called when task is finished.
    private func realmTranslations(predicate: NSPredicate, realm: Realm) -> [RealmTranslation]? {
        
        guard realm.objects(RealmTranslation.self).filter(predicate).count > 0 else {
            return nil
        }
        
        return Array(realm.objects(RealmTranslation.self).filter(predicate))
    }
    
    private func realmTranslation(predicate: NSPredicate, realm: Realm) -> RealmTranslation? {
        return realm.objects(RealmTranslation.self).filter(predicate).first
    }
    
    private func createOrUpdateTranslation(_ translation: BDRealmTranslation, completion: @escaping BDCreateOrUpdateCompletionHandler) {
        
        dispatchQueue.async { [weak self] in
            let realm = try! Realm()
            do {
                try realm.write {
                    
                    let predicate = NSPredicate(format: "word == %@ AND language == %@ AND translationLanguage == %@", translation.word, translation.language, translation.translationLanguage)
                    
                    var translationToUpdate: RealmTranslation
                    // In this case the object already exists in data base.
                    if let realmTranslation = self?.realmTranslation(predicate: predicate, realm: realm) {
                        
                        //In this case, it means that save date should be updated.
                        if realmTranslation.isFavorite == translation.isFavorite {
                            realmTranslation.saveDate = Date()
                        }
                        
                        realmTranslation.isFavorite = translation.isFavorite
                        
                        let translations = List<String>()
                        translations.append(objectsIn: translation.translations.sorted())
                        realmTranslation.translations = translations
                        
                        translationToUpdate = realmTranslation
                    } else {
                        translationToUpdate = RealmTranslation(word: translation.word, language: translation.language, translationLanguage: translation.translationLanguage, isFavorite: translation.isFavorite, translations: translation.translations)
                    }
                    
                    realm.add(translationToUpdate, update: true)
                    completion(true, try! BDRealmTranslation(realmTranslation: translationToUpdate), nil)
                }
            } catch let error {
                completion(false, nil, BDRealmStorageError.dataBaseOperationFailed(reason: .realmWriteFailed(error)))
            }
        }
    }
}

