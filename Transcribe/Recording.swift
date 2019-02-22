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
    @objc dynamic var name: String?
    @objc dynamic var url: String?
    @objc dynamic var duration: String?
    @objc dynamic var date: String?
    @objc dynamic var transcription: String?
}
