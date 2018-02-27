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
    public let isFavorite: Bool
    
    /// Translations of word.
    public let translations: [String]
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
