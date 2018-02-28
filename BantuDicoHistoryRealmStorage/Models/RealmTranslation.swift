//
//  RealmTranslation.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

class RealmTranslation: Object {
    
    @objc public dynamic var identifier: String = ""
    @objc dynamic var word = ""
    @objc dynamic var language = ""
    @objc dynamic var translationLanguage = ""
    @objc dynamic var isFavorite = false {
        didSet {
            favoriteDate = isFavorite ? Date() : nil
        }
    }
    @objc dynamic var saveDate: Date = Date()
    @objc dynamic var favoriteDate: Date?
    var translations = List<String>()
    
    convenience init(word: String, language: String, translationLanguage: String, isFavorite: Bool, translations: [String]) {
        self.init()
        setCompoundWord(word: word)
        setCompoundLanguage(language: language)
        setCompoundTranslationLanguage(translationLanguage: translationLanguage)
        self.isFavorite = isFavorite
        
        self.translations = List<String>()
        self.translations.append(objectsIn: translations.sorted())
    }
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

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
