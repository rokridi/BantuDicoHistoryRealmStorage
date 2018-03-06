//
//  Translation.swift
//  BantuDicoHistoryRealmStorageTests
//
//  Created by Mohamed Aymen Landolsi on 06/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
@testable import BantuDicoHistoryRealmStorage

struct Translation: Translatable {
    
    typealias Word = TranslationWord
    
    var identifier: String
    
    var word: String
    
    var language: String
    
    var translationLanguage: String
    
    var soundURL: String
    
    var isFavorite: Bool
    
    var translations: [TranslationWord]
    
    var saveDate: Date?
    
    var favoriteDate: Date?
    
    init() {
    }
    
}
