//
//  Recording.swift
//  Transcribe
//
//  Created by Roland Shen on 7/14/17.
//  Copyright © 2017 Ansail. All rights reserved.
//

import Foundation
import RealmSwift

class Recording: Object {
    
    dynamic var name: String? = nil
    dynamic var audioFile: Data? = nil
    dynamic var transcription: String? = nil
    
}
