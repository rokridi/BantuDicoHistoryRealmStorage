//
//  Translatable.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 06/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

public protocol Translatable {
    
    associatedtype Word: WordRepresentable
    
    /// Identifier of the translation.
    var identifier: String {get set}
    
    /// The translated word.
    var word: String {get set}
    
    /// Language of the word.
    var language: String {get set}
    
    /// Language of the translation.
    var translationLanguage: String {get set}
    
    /// The URL to a mp3 file representing the sound of the word.
    var soundURL: String {get set}
    
    /// The translation is favorite or not.
    var isFavorite: Bool {get set}
    
    /// Translations of word.
    var translations: [Word] {get set}
    
    // The date the translation is saved.
    var saveDate: Date? {get set}
    
    // The date the translation became favorite.
    var favoriteDate: Date? {get set}
    
    init()    
}
