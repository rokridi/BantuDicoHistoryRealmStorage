//
//  Translations.swift
//  BantuDicoHistoryRealmStorageTests
//
//  Created by Mohamed Aymen Landolsi on 23/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
@testable import BantuDicoHistoryRealmStorage

struct Translations {
    
    static let addFavoriteTranslation = BDTranslationHistory(identifier: "add-en-fr", word: "add", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["ajouter"])
    static let removeFavoriteTranslation = BDTranslationHistory(identifier: "remove-en-fr", word: "remove", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["enlever"])
    static let fetchTranslation = BDTranslationHistory(identifier: "fetch-en-fr", word: "fetch", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["rechercher"])
    static let saveTranslation = BDTranslationHistory(identifier: "save-en-fr", word: "save", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["sauvegarder"])
    
}
