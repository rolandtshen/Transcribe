//
//  Recording.swift
//  Transcribe
//
//  Created by Roland Shen on 7/28/17.
//  Copyright © 2017 Ansail. All rights reserved.
//

import Foundation
import RealmSwift

class Recording: Object {
    dynamic var name: String?
    dynamic var url: String?
    dynamic var duration: String?
    dynamic var date: String?
    dynamic var transcription: String?
}
