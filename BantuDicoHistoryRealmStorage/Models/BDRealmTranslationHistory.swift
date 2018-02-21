//
//  BDRealmTranslationResult.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

class BDRealmTranslationHistory: Object {
    
    @objc dynamic var sourceWord = ""
    @objc dynamic var sourceLanguage = ""
    @objc dynamic var destinationLanguage = ""
    @objc dynamic var isFavorite = false
    @objc public dynamic var identifier: String = ""
    var translations = List<String>()
    
    convenience init(sourceWord: String, sourceLanguage: String, destinationLanguage: String,
                     isFavorite: Bool, translations: [String]) {
        self.init()
        setCompoundSourceWord(sourceWord: sourceWord)
        setCompoundSourceLanguage(sourceLanguage: sourceLanguage)
        setCompoundDestinationLanguage(destinationLanguage: destinationLanguage)
        self.isFavorite = isFavorite
        
        self.translations = List<String>()
        self.translations.append(objectsIn: translations)
    }
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

extension BDRealmTranslationHistory {
    
    func setCompoundSourceWord(sourceWord: String) {
        self.sourceWord = sourceWord
        identifier = identifierValue()
    }
    
    func setCompoundSourceLanguage(sourceLanguage: String) {
        self.sourceLanguage = sourceLanguage
        identifier = identifierValue()
    }
    
    func setCompoundDestinationLanguage(destinationLanguage: String) {
        self.destinationLanguage = destinationLanguage
        identifier = identifierValue()
    }
    
    private func identifierValue() -> String {
        return "\(sourceWord)-\(sourceLanguage)-\(destinationLanguage)"
    }
}
