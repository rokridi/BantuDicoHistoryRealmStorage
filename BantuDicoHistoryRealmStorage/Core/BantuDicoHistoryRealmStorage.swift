//
//  BantuDicoHistoryRealmStorage.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

public typealias BDFetchHistoryCompletionHandler = (BDTranslationHistory?, Error?) -> Void
public typealias BDSaveHistoryCompletionHandler = (Bool, Error?) -> Void
public typealias BDFavoriteHistoryCompletionHandler = (Bool, Error?) -> Void
private typealias BDFetchRealmTranslationCompletionHandler = (BDRealmTranslationResult?) -> Void
private typealias BDCreateOrUpdateCompletionHandler = (Bool, Error?) -> Void

public class BantuDicoHistoryRealmStorage {
    
    private let queue: OperationQueue
    
    init(storeName: String) {
        
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(storeName).realm")
        Realm.Configuration.defaultConfiguration = config
        
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
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
    func fetchTranslationResult(sourceWord: String,
                                sourceLanguage: String,
                                destinationLanguage: String,
                                queue: DispatchQueue = DispatchQueue.main,
                                completion: @escaping BDFetchHistoryCompletionHandler) {
        self.queue.addOperation { [weak self] in
            self?.fetchRealmTranslation(sourceWord: sourceLanguage, sourceLanguage: sourceLanguage, destinationLanguage: destinationLanguage, completion: { realmTranslation in
                queue.async {
                    completion(realmTranslation != nil ? BDTranslationHistory(realmTranslationResult: realmTranslation!) : nil, nil)
                }
            })
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
                         completion: @escaping BDSaveHistoryCompletionHandler) {
        
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
                         completion: @escaping BDSaveHistoryCompletionHandler) {
        
        self.saveTranslation(sourceWord: translation.sourceWord, sourceLanguage: translation.sourceLanguage, destinationLanguage: translation.destinationLanguage, translations: translation.translations, queue: queue, completion: completion)
    }
    
    /// Add translation to favorites.
    ///
    /// - Parameters:
    ///   - sourceWord: translated word.
    ///   - sourceLanguage: language of the translated word.
    ///   - destinationLanguage: the language to which the sourceWord will be translated.
    ///   - isFavorite: if true then translation will be added to favories. If false then translation will be removed from favorites.
    ///   - translations: he translations of sourceWord.
    ///   - queue: the queue on which the completion will be called.
    ///   - completion: closure called when task is finished.
    func favoriteTranslation(sourceWord: String,
                             sourceLanguage: String,
                             destinationLanguage: String,
                             isFavorite: Bool,
                             translations: [String],
                             queue: DispatchQueue = DispatchQueue.main,
                             completion: @escaping BDFavoriteHistoryCompletionHandler) {
        
        self.createOrUpdateTranslationHistory(sourceWord: sourceWord, sourceLanguage: sourceLanguage, destinationLanguage: destinationLanguage, isFavorite: false, translations: translations, completion: { (success, error) in
            queue.async {
                completion(success, error)
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
    func favoriteTranslation(_ translation: BDTranslationHistory,
                             isFavorite: Bool,
                             queue: DispatchQueue = DispatchQueue.main,
                             completion: @escaping BDFavoriteHistoryCompletionHandler) {
        self.favoriteTranslation(sourceWord: translation.sourceWord, sourceLanguage: translation.sourceLanguage, destinationLanguage: translation.destinationLanguage, isFavorite: isFavorite, translations: translation.translations, queue: queue, completion: completion)
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
    func fetchRealmTranslation(sourceWord: String,
                               sourceLanguage: String,
                               destinationLanguage: String,
                               completion: @escaping BDFetchRealmTranslationCompletionHandler) {
        
        self.queue.addOperation {
            let realm = try! Realm()
            let result = realm.objects(BDRealmTranslationResult.self).filter("sourceWord = \(sourceWord) AND sourceLanguage = \(sourceLanguage) AND destinationLanguage = \(destinationLanguage)").first
            completion(result)
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
    func createOrUpdateTranslationHistory(sourceWord: String,
                                          sourceLanguage: String,
                                          destinationLanguage: String,
                                          isFavorite: Bool,
                                          translations: [String],
                                          completion: @escaping BDCreateOrUpdateCompletionHandler) {
        self.queue.addOperation { [weak self] in
            
            self?.fetchRealmTranslation(sourceWord: sourceLanguage, sourceLanguage: sourceLanguage, destinationLanguage: destinationLanguage, completion: { realmTranslation in
                let realm = try! Realm()
                
                do {
                    try realm.write {
                        let translation = realmTranslation ?? BDRealmTranslationResult()
                        translation.sourceWord = sourceWord
                        translation.sourceLanguage = sourceLanguage
                        translation.destinationLanguage = destinationLanguage
                        translation.isFavorite = isFavorite
                        translation.translations = List<String>()
                        translation.translations.append(objectsIn: translations)
                        realm.add(translation, update: true)
                        
                        completion(true, nil)
                    }
                } catch let error {
                    completion(false, error)
                }
            })
        }
    }
}
