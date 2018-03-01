//
//  RealmTranslation.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

/// Represents a translation in Realm data base.
class RealmTranslation: Object {
    
    /// Identifier of the translation.
    @objc public dynamic var identifier: String = ""
    
    /// The translated word.
    @objc dynamic var word = ""
    
    /// The language of word.
    @objc dynamic var language = ""
    
    /// The translation language.
    @objc dynamic var translationLanguage = ""
    
    /// Translation is favorite or not.
    @objc dynamic var isFavorite = false {
        didSet {
            favoriteDate = isFavorite ? Date() : nil
        }
    }
    
    /// The date at which the translation is saved.
    @objc dynamic var saveDate: Date = Date()
    
    // The date at which the translation became favorite.
    @objc dynamic var favoriteDate: Date?
    var translations = List<String>()
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

//MARK: - Initialization

extension RealmTranslation {
    
    /// Create an instance of RealmTranslation.
    ///
    /// - Parameters:
    ///   - word: translated word.
    ///   - language: language of word.
    ///   - translationLanguage: the translation language.
    ///   - isFavorite: translation is favorite or not.
    ///   - translations: translations of the word.
    convenience init(word: String, language: String, translationLanguage: String, isFavorite: Bool, translations: [String]) {
        self.init()
        setCompoundWord(word: word)
        setCompoundLanguage(language: language)
        setCompoundTranslationLanguage(translationLanguage: translationLanguage)
        self.isFavorite = isFavorite
        self.translations = List<String>()
        self.translations.append(objectsIn: translations.sorted())
    }
}

//MARK: - Translation identifier.

extension RealmTranslation {
    
    func setCompoundWord(word: String) {
        self.word = word
        identifier = identifierValue()
    }
    
    func setCompoundLanguage(language: String) {
        self.language = language
        identifier = identifierValue()
    }
    
    func setCompoundTranslationLanguage(translationLanguage: String) {
        self.translationLanguage = translationLanguage
        identifier = identifierValue()
    }
    
    private func identifierValue() -> String {
        return "\(word)-\(language)-\(translationLanguage)"
    }
}
