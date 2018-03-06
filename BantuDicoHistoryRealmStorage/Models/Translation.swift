//
//  Translation.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

/// Represents a translation in Realm data base.
class Translation: Object {
    
    /// Identifier of the translation.
    @objc dynamic var identifier: String = ""
    
    /// The translated word.
    @objc dynamic var word = ""
    
    /// The language of word.
    @objc dynamic var language = ""
    
    /// The translation language.
    @objc dynamic var translationLanguage = ""
    
    /// The URL to a mp3 file representing the sound of the word.
    @objc dynamic var soundURL: String = ""
    
    /// Translation is favorite or not.
    @objc dynamic var isFavorite = false {
        didSet {
            favoriteDate = isFavorite ? Date() : nil
        }
    }
    
    /// The date at which the translation is saved.
    @objc dynamic var saveDate: Date? = nil
    
    // The date at which the translation became favorite.
    @objc dynamic var favoriteDate: Date? = nil
    
    /// Translations of word.
    var translations = List<Word>()
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

extension Translation {
    
    convenience init<T: Translatable>(translation: T) {
        self.init()
        identifier = translation.identifier
        word = translation.word
        language = translation.language
        translationLanguage = translation.translationLanguage
        isFavorite = translation.isFavorite
        favoriteDate = translation.isFavorite ? Date() : nil
        saveDate = translation.favoriteDate
        translations = List<Word>()
        translations.append(objectsIn: translation.translations.map({ Word(word: $0) }))
    }
}

extension Translation {
    
    func translatableFrom<T: Translatable>(model: T.Type) -> T {
        
        var translation = model.init()
        translation.identifier = identifier
        translation.language = language
        translation.translationLanguage = translationLanguage
        translation.isFavorite = isFavorite
        translation.saveDate = saveDate
        translation.favoriteDate = favoriteDate
        translation.translations = translations.map { $0.wordRepresentableFrom(model: T.Word.self) }
        return translation
    }
}
