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
    
    /// The URL to a mp3 file representing the sound of the word.
    public let soundURL: String
    
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
    
    /// Create an instance of BDRealmTranslation.
    ///
    /// - Parameters:
    ///   - word: translated word.
    ///   - language: language of word.
    ///   - translationLanguage: translation language.
    ///   - soundURL: the URL to a mp3 file representing the sound of the word.
    ///   - isFavorite: translation is favorite or not.
    ///   - translations: translations of word.
    init(identifier: String, word: String, language: String, translationLanguage: String, soundURL: String, isFavorite: Bool, translations: [String]) {
        self.identifier = identifier
        self.word = word
        self.language = language
        self.translationLanguage = translationLanguage
        self.soundURL = soundURL
        self.isFavorite = isFavorite
        self.translations = translations
        favoriteDate = isFavorite ? Date() : nil
    }
}
