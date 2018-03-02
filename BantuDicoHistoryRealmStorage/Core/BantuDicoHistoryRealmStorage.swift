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
    
    /// Fetch translations which word property begins with `beginning`. Translations will be sorted by 'word' ascending.
    ///
    /// - Parameters:
    ///   - beginning: the string that translation's word begins with.
    ///   - language: language of the translated word.
    ///   - translationLanguage: language of the translation.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func tanslationsBeginningWith(_ beginning: String, language: String, translationLanguage: String, queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<[BDRealmTranslation]>) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else { return }
            let realm = try! Realm()
            let predicate = NSPredicate(format: "word BEGINSWITH[c] %@ AND language == %@ AND translationLanguage == %@", beginning, language, translationLanguage)
            let result = self.realmTranslations(predicate: predicate, realm: realm).map({ BDRealmTranslation(realmTranslation: $0) }).sorted(by: { $0.word <= $1.word })
            queue.async { completion(.success(result)) }
        }
    }
    
    /// Fetch all translations including favorites.
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func allTranslations(queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<[BDRealmTranslation]>) -> Void) {
        dispatchQueue.async {
            let realm = try! Realm()
            let result = Array(realm.objects(RealmTranslation.self).map({BDRealmTranslation(realmTranslation: $0)}))
            queue.async { completion(.success(result)) }
        }
    }
    
    /// Fetches all favorites.
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func allFavorites(queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<[BDRealmTranslation]>) -> Void) {
        dispatchQueue.async { [weak self] in
            
            guard let `self` = self else { return }
            let realm = try! Realm()
            let predicate = NSPredicate(format: "isFavorite == true")
            let favorites = self.realmTranslations(predicate: predicate, realm: realm)
                .map({BDRealmTranslation(realmTranslation: $0)})
                .sorted(by: { $0.word <= $1.word })
            queue.async { completion(Result.success(favorites)) }
        }
    }
}

//MARK: - Save

public extension BantuDicoHistoryRealmStorage {
    
    /// Saves a translation or updates it if already exists.
    /// N.B: if the translation already exists then the property 'isFavorite' is not changed.
    ///
    /// - Parameters:
    ///   - identifier: identifier of the translation.
    ///   - word: the translated word.
    ///   - language: the language of 'word'.
    ///   - soundURL: the URL to a mp3 file representing the sound of the word.
    ///   - translationLanguage: the language of the translation.
    ///   - translations: translations of 'word'.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func saveTranslation(identifier: String, word: String,
                                language: String, translationLanguage: String,
                                soundURL: String,
                                translations: [String],
                                queue: DispatchQueue = DispatchQueue.main,
                                completion: @escaping (Result<BDRealmTranslation>) -> Void) {
        createOrUpdateTranslation(identifier: identifier, word: word, language: language, translationLanguage: translationLanguage, soundURL: soundURL, translations: translations, completion: completion)
    }
}

//MARK: - Favorites

public extension BantuDicoHistoryRealmStorage {
    
    /// Add or remove translation from favorites.
    ///
    /// - Parameters:
    ///   - translationIdentifier: identifier of the translation.
    ///   - isFavorite: if 'true' then the translation is added to favorites. Otherwise, it is removed from favorites.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    private func addRemoveFavorite(translationIdentifier: String, isFavorite: Bool,
                                   queue: DispatchQueue = DispatchQueue.main,
                                   completion: @escaping (Result<BDRealmTranslation>) -> Void) {
        dispatchQueue.async {
            let realm = try! Realm()
            let predicate = NSPredicate(format: "identifier == %@", translationIdentifier)
            
            guard let realmTranslation = self.realmTranslation(predicate: predicate, realm: realm) else {
                completion(.failure(BDRealmStorageError.dataBaseOperationFailed(reason: .translationNotFound(identifier: translationIdentifier))))
                return
            }
            
            do {
                try realm.write {
                    realmTranslation.isFavorite = true
                    realm.add(realmTranslation, update: true)
                    let translation = BDRealmTranslation(realmTranslation: realmTranslation)
                    queue.async { completion(.success(translation)) }
                }
            } catch let error {
                queue.async {
                    completion(.failure(BDRealmStorageError.dataBaseAccessFailed(reason: .writeFailed(error))))
                }
            }
        }
    }
}

//MARK: - Delete

extension BantuDicoHistoryRealmStorage {
    
    /// Delete specific translations.
    ///
    /// - Parameters:
    ///   - translations: translations to delete.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    func deleteTranslations(_ identifiers: [String], queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<Void>) -> Void) {
        
        dispatchQueue.async { [weak self] in
            
            guard let `self` = self else { return }
            let predicate = NSPredicate(format: "identifier IN %@", identifiers)
            
            let realm = try! Realm()
            
            let realmTranslations = self.realmTranslations(predicate: predicate, realm: realm)
            
            do {
                try realm.write {
                    
                    let translationsToDelete = List<RealmTranslation>()
                    translationsToDelete.append(objectsIn: realmTranslations)
                    realm.delete(translationsToDelete)
                    queue.async { completion(.success(())) }
                }
            } catch let error {
                queue.async {
                    completion(.failure(BDRealmStorageError.dataBaseAccessFailed(reason: .writeFailed(error))))
                }
            }
        }
    }
    
    /// Delete all translations including favorites.
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: losure called when task is finished.
    func deleteAllTranslations(queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<Void>) -> Void) {
        
        dispatchQueue.async {
            let realm = try! Realm()
            do {
                try realm.write {
                    realm.deleteAll()
                    queue.async { completion(.success(())) }
                }
            } catch let error {
                queue.async { completion(.failure(BDRealmStorageError.dataBaseAccessFailed(reason: .writeFailed(error))))}
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
    private func realmTranslations(predicate: NSPredicate, realm: Realm) -> [RealmTranslation] {
        return Array(realm.objects(RealmTranslation.self).filter(predicate))
    }
    
    private func realmTranslation(predicate: NSPredicate, realm: Realm) -> RealmTranslation? {
        return realm.objects(RealmTranslation.self).filter(predicate).first
    }
    
    /// Insert a new translation in data base or updates it if it already exists.
    ///
    /// - Parameters:
    ///   - identifier: identifier of the translation.
    ///   - word: the translated word.
    ///   - language: the language of 'word'.
    ///   - translationLanguage: the language of the translation.
    ///   - soundURL: the URL to a mp3 file representing the sound of the word.
    ///   - translations: the translations of 'word'.
    ///   - completion: closure called when task is finished.
    private func createOrUpdateTranslation(identifier: String, word: String,
                                           language: String, translationLanguage: String,
                                           soundURL: String,
                                           translations: [String],
                                           completion: @escaping (Result<BDRealmTranslation>) -> Void) {
        dispatchQueue.async { [weak self] in
            
            guard let `self` = self else { return }
            let realm = try! Realm()
            do {
                try realm.write {
                    
                    let predicate = NSPredicate(format: "word == %@ AND language == %@ AND translationLanguage == %@", word, language, translationLanguage)
                    
                    var translationToUpdate: RealmTranslation
                    // In this case the object already exists in data base.
                    if let realmTranslation = self.realmTranslation(predicate: predicate, realm: realm) {
                        
                        realmTranslation.saveDate = Date()
                        
                        let translations = List<String>()
                        translations.append(objectsIn: translations.sorted())
                        realmTranslation.translations = translations
                        
                        translationToUpdate = realmTranslation
                    } else {
                        translationToUpdate = RealmTranslation(identifier: identifier, word: word, language: language, translationLanguage: translationLanguage, soundURL: soundURL, isFavorite: false, translations: translations)
                    }
                    
                    realm.add(translationToUpdate, update: true)
                    completion(.success(BDRealmTranslation(realmTranslation: translationToUpdate)))
                }
            } catch let error {
                completion(.failure(BDRealmStorageError.dataBaseAccessFailed(reason: .writeFailed(error))))
            }
        }
    }
}

