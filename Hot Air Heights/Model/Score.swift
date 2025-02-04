//
//  Score.swift
//  Hot Air Heights
//
//  Created by Ola Adeoba on 2024-08-05.
//

import Foundation

struct Score : Codable{
    var Currentlevel: Int
    var saveLevel: Int
    
    init(Currentlevel: Int, saveLevel: Int) {
        self.Currentlevel = Currentlevel
        self.saveLevel = saveLevel
    }
}


