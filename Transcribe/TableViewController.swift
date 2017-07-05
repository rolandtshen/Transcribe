//
//  TableViewController.swift
//  Transcribe
//
//  Created by Roland Shen on 5/27/17.
//  Copyright © 2017 Ansail. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

class TableViewController: UITableViewController {
    
    var recordingTitles: [String]?
    var recordings: [URL]?
    
    override func viewDidLoad() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            
            // if you want to filter the directory contents you can do like this:
            let mp3Files = directoryContents.filter{ $0.pathExtension == "m4a" }
            print("mp3 urls:",mp3Files)
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            print("mp3 list:", mp3FileNames)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell") as! RecordingCell
        cell.card.layer.cornerRadius = 5
        cell.card.clipsToBounds = true
        cell.card.backgroundColor = UIColor.init(gradientStyle: .leftToRight, withFrame: view.frame, andColors: [UIColor.flatSkyBlue(), UIColor.flatBlue()])
        cell.titleLabel.text = ""
        cell.lengthDateLabel.text = "length | date"
        cell.descriptionLabel.text = "desc"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //play recording
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
