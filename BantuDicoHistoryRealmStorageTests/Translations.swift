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
    
    static let addFavoriteTranslation = BDRealmTranslation(identifier: "add-en-fr", word: "add", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["ajouter"])
    static let removeFavoriteTranslation = BDRealmTranslation(identifier: "remove-en-fr", word: "remove", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["enlever"])
    static let fetchTranslation = BDRealmTranslation(identifier: "fetch-en-fr", word: "fetch", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["rechercher"])
    static let saveTranslation = BDRealmTranslation(identifier: "save-en-fr", word: "save", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["sauvegarder"])
    
}
