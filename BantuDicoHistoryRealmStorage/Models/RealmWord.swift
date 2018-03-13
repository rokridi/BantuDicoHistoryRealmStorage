//
//  RealmWord.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 05/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

/// Represents a translation of a word.
class RealmWord: Object {
    
    /// Identifier of the translation.
    @objc dynamic var identifier: String = ""
    
    /// The translated word.
    @objc dynamic var word = ""
    
    /// The URL to a mp3 file representing the sound of the word.
    @objc dynamic var soundURL: String = ""
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

//MARK: - Initialization

extension RealmWord {
    
    /// Create an instance of RealmWord.
    ///
    /// - Parameters:
    ///   - identifier: identifier of the word.
    ///   - word: translated word.
    ///   - soundURL: the URL to a mp3 file representing the sound of the word.
    convenience init(identifier: String, word: String, soundURL: String) {
        self.init()
        self.identifier = identifier
        self.word = word
        self.soundURL = soundURL
    }
}

