//
//  TranslationWord.swift
//  BantuDicoHistoryRealmStorageTests
//
//  Created by Mohamed Aymen Landolsi on 06/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
@testable import BantuDicoHistoryRealmStorage

struct TranslationWord: WordRepresentable {
    
    var identifier: String
    var word: String
    var soundURL: String
    
    init() {
    }
}
