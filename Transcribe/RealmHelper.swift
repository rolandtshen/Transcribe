//
//  RealmHelper.swift
//  Transcribe
//
//  Created by Roland Shen on 7/28/17.
//  Copyright © 2017 Ansail. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {
    static func add(_ recording: Recording) {
        let realm = try! Realm()
        try! realm.write() {
            realm.add(recording)
        }
    }
    
    static func deleteRecording(_ recording: Recording) {
        let realm = try! Realm()
        try! realm.write() {
            realm.delete(recording)
        }
    }
    
    static func update(_ recordingToBeUpdated: Recording, newRecording: Recording) {
        let realm = try! Realm()
        try! realm.write() {
            recordingToBeUpdated.name = newRecording.name
            recordingToBeUpdated.transcription = newRecording.transcription
        }
    }
    
    static func retrieve() -> Results<Recording> {
        let realm = try! Realm()
        return realm.objects(Recording.self).sorted(byKeyPath: "date", ascending: true)
    }
}
