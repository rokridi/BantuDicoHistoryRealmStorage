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
    public var identifier: String
    
    /// The translated word.
    public let word: String
    
    /// Language of the word.
    public let language: String
    
    /// Language of the translation.
    public let translationLanguage: String
    
    /// The translation is favorite or not.
    public let isFavorite: Bool
    
    /// Translations of word.
    public let translations: [String]
    
    /// Create an instance of BDRealmTranslation.
    ///
    /// - Parameters:
    ///   - word: translated word.
    ///   - language: language of word.
    ///   - translationLanguage: translation language.
    ///   - isFavorite: translation is favorite or not.
    ///   - translations: translations of word.
    public init(word: String, language: String, translationLanguage: String, isFavorite: Bool, translations: [String]) {
        
        identifier = "\(word)-\(language)-\(translationLanguage)"
        self.word = word
        self.language = language
        self.translationLanguage = translationLanguage
        self.isFavorite = isFavorite
        self.translations = translations
    }
}

extension BDRealmTranslation {
    init(realmTranslation: RealmTranslation) {
        identifier = realmTranslation.identifier
        word = realmTranslation.word
        language = realmTranslation.language
        translationLanguage = realmTranslation.translationLanguage
        isFavorite = realmTranslation.isFavorite
        translations = Array(realmTranslation.translations).sorted()
    }
}
