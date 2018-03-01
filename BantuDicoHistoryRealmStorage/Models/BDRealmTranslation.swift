//
//  BDRealmTranslation.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

/// Represents a translation saved in data base.
public struct BDRealmTranslation {
    
    /// Identifier of the translation. Its format is: word-language-translationLanguage
    public let identifier: String
    
    /// The translated word.
    public let word: String
    
    /// Language of the word.
    public let language: String
    
    /// Language of the translation.
    public let translationLanguage: String
    
    /// The translation is favorite or not.
    public var isFavorite: Bool {
        didSet {
            favoriteDate = isFavorite ? Date() : nil
        }
    }
    
    /// Translations of word.
    public let translations: [String]
    
    // The date the translation is saved.
    public var saveDate: Date?
    
    // The date the translation became favorite.
    public private(set) var favoriteDate: Date?
}

//MARK: Initialization

extension BDRealmTranslation {
    
    /// Create an instance of BDRealmTranslation.
    ///
    /// - Parameters:
    ///   - word: translated word.
    ///   - language: language of word.
    ///   - translationLanguage: translation language.
    ///   - isFavorite: translation is favorite or not.
    ///   - translations: translations of word.
    public init(word: String, language: String, translationLanguage: String, isFavorite: Bool, translations: [String]) throws {
        
        guard word.isValidWord() else {
            throw BDRealmTranslationError.invalidWord(word)
        }
        
        guard language.isValidLanguage() else {
            throw BDRealmTranslationError.invalidLanguage(language)
        }
        
        guard language.isValidLanguage() else {
            throw BDRealmTranslationError.invalidLanguage(language)
        }
        
        guard !translations.isEmpty else {
            throw BDRealmTranslationError.invalidTranslations(translations)
        }
        
        identifier = "\(word)-\(language)-\(translationLanguage)"
        self.word = word
        self.language = language
        self.translationLanguage = translationLanguage
        self.isFavorite = isFavorite
        self.translations = translations
        favoriteDate = isFavorite ? Date() : nil
    }
    
    init(realmTranslation: RealmTranslation) throws {
        try self.init(word: realmTranslation.word, language: realmTranslation.language, translationLanguage: realmTranslation.translationLanguage, isFavorite: realmTranslation.isFavorite, translations: Array(realmTranslation.translations).sorted())
    }
}

public extension BDRealmTranslation {
    
    mutating func updateWithTranslation(_ translation: BDRealmTranslation) {
        self = translation
    }
}

