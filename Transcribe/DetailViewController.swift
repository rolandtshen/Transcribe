//
//  DetailViewController.swift
//  Transcribe
//
//  Created by Roland Shen on 8/6/17.
//  Copyright © 2017 Ansail. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import AVFoundation

class DetailViewController: UIViewController, UINavigationControllerDelegate, AVAudioPlayerDelegate {
        
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var transcriptionTextView: UITextView!
    
    var recording: Recording?
    var player: AVAudioPlayer!
    var url: URL?

    override func viewDidLoad() {
        self.titleTextView.text = recording?.name
        self.transcriptionTextView.text = recording?.transcription
        self.automaticallyAdjustsScrollViewInsets = false
        url = URL(string: (recording?.url!)!)
        try! AVAudioSession.sharedInstance().setCategory(convertFromAVAudioSessionCategory(AVAudioSession.Category.playback))
        try! AVAudioSession.sharedInstance().setActive(true)

//        do {
//            player = try AVAudioPlayer(contentsOf: url!)
//        }
//        catch {
//            print("not playing")
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let newRecording = Recording()
        newRecording.date = dateFormatter.string(from: Date())
        newRecording.duration = recording?.duration
        newRecording.name = titleTextView.text
        newRecording.transcription = transcriptionTextView.text
        newRecording.url = recording?.url
        RealmHelper.update(recording!, newRecording: newRecording)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func play(_ sender: Any) {
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            player.prepareToPlay()
            player.delegate = self
            player.play()
        } catch let error as NSError {
            //self.player = nil
            print("error: " + error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
