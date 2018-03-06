//
//  BantuDicoHistoryRealmStorage.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift
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
    public func tanslationsBeginningWith<T: Translatable>(_ beginning: String, model: T.Type, language: String, translationLanguage: String, queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<[T]>) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else { return }
            let realm = try! Realm()
            let predicate = NSPredicate(format: "word BEGINSWITH[c] %@ AND language == %@ AND translationLanguage == %@", beginning, language, translationLanguage)
            let result = self.realmTranslations(predicate: predicate, realm: realm).map({ $0.translatableFrom(model: model) }).sorted(by: { $0.word <= $1.word })
            queue.async { completion(.success(result)) }
        }
    }
    
    /// Fetch all translations including favorites.
    ///
    /// - Parameters:
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func allTranslations<T: Translatable>(model: T.Type, queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<[T]>) -> Void) {
        dispatchQueue.async {
            let realm = try! Realm()
            let result = Array(realm.objects(Translation.self).map({ $0.translatableFrom(model: model) }))
            queue.async { completion(.success(result)) }
        }
    }
    
    /// Fetches all favorites.
    ///
    /// - Parameters:
    ///   - model: model representing the translation.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func allFavorites<T: Translatable>(model: T.Type, queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<[T]>) -> Void) {
        dispatchQueue.async { [weak self] in
            
            guard let `self` = self else { return }
            let realm = try! Realm()
            let predicate = NSPredicate(format: "isFavorite == true")
            let favorites = self.realmTranslations(predicate: predicate, realm: realm).map({ $0.translatableFrom(model: model) })
                
            queue.async { completion(.success(favorites)) }
        }
    }
}

//MARK: - Save

public extension BantuDicoHistoryRealmStorage {
    
    /// Saves a translation or updates it if already exists.
    ///
    /// - Parameters:
    ///   - translation: translation to save.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    public func saveTranslation<T: Translatable>(_ translation: T,
                                queue: DispatchQueue = DispatchQueue.main,
                                completion: @escaping (Result<T>) -> Void) {
        createOrUpdateTranslation(translation) { result in
            queue.async { completion(result) }
        }
    }
}

//MARK: - Delete

extension BantuDicoHistoryRealmStorage {
    
    /// Delete a translation.
    ///
    /// - Parameters:
    ///   - identifiers: identifiers of the translations to delete.
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
                    
                    let translationsToDelete = List<Translation>()
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
    
    
    /// Delete translations from data base.
    ///
    /// - Parameters:
    ///   - translations: translations to delete.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    func deleteTranslations<T: Translatable>(_ translations: [T], queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<Void>) -> Void) {
        
        dispatchQueue.async { [weak self] in
            
            guard let `self` = self else { return }
            let identifiers = translations.map({ $0.identifier })
            
            self.deleteTranslations(identifiers, queue: queue, completion: completion)
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
    
    /// Fetches BDRealmTranslationResult object from data base.
    ///
    /// - Parameters:
    ///   - word: the translated word.
    ///   - language: the language of word.
    ///   - translationLanguage: the language to which the word is translated.
    ///   - completion: closure called when task is finished.
    private func realmTranslations(predicate: NSPredicate, realm: Realm) -> [Translation] {
        return Array(realm.objects(Translation.self).filter(predicate))
    }
    
    private func realmTranslation(predicate: NSPredicate, realm: Realm) -> Translation? {
        return realm.objects(Translation.self).filter(predicate).first
    }
    
    /// Insert a new translation in data base or updates it if it already exists.
    ///
    /// - Parameters:
    ///   - translation: Translatable object.
    ///   - completion: closure called when task is finished.
    private func createOrUpdateTranslation<T: Translatable>(_ translation: T,
                                           completion: @escaping (Result<T>) -> Void) {
        dispatchQueue.async { [weak self] in
            
            guard let `self` = self else { return }
            let realm = try! Realm()
            do {
                try realm.write {
                    
                    let predicate = NSPredicate(format: "identifier == %@", translation.identifier)
                    
                    let translationExixts = self.realmTranslation(predicate: predicate, realm: realm) != nil
                    
                    let translationToUpdate = Translation(translation: translation)
                    realm.add(translationToUpdate, update: translationExixts)
                    
                    let translatable = translationToUpdate.translatableFrom(model: T.self)
                    completion(.success(translatable))
                }
            } catch let error {
                completion(.failure(BDRealmStorageError.dataBaseAccessFailed(reason: .writeFailed(error))))
            }
        }
    }
}

