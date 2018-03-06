//
//  WordRepresentable.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 06/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

public protocol WordRepresentable {
    
    var identifier: String {get set}
    var word: String {get set}
    var soundURL: String {get set}
    
    init()
}
